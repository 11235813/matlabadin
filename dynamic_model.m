%dynamic_model handles dynamic enchants and proc effects

clear proc
proc.dps=0;
proc.hps=0;
proc.tps=0;
proc.dodge=0;

%generate ids from weapon and weapon enchant spots; this corrects for empty
%procid elments 
if isempty(egs(15).procid)
    tmp.weap=0;
else
    tmp.weap=egs(15).procid;
end

if isempty(egs(35).procid)
    tmp.wench=0;
else
    tmp.wench=egs(35).procid;
end

%% Rotation/input handling

%This module requires a cps input.  This will either be supplied by the sim
%(in the case of calc_rot_st) or be part of the rotation variable generated
%by rotation_momdel.  This section makes sure we have the appropriate cps
%values.


%If rotation_model hasn't been run, do so now
if exist('rot','var')==0 
    rotation_model;
end

%If we're calling from one of the rotation sims, this flag should be set
if isfield(rot,'single')
    pseq=rot;
%If we need to manually override, the override field should exist
elseif isfield(rot,'override')
    pseq=rot(rot(1).override);
%If the rotation is defined in the cfg variable, use that
elseif exist('cfg','var') && exist('c','var') && isfield(cfg(c),'rot')  %c always used as config index variable
    pseq=rot(cfg(c).rot);tmpemod.rot=1;
else
%Otherwise, default to the rotation defined in exec (should default to 9C9)
    warning(['rotation defaulted to ' rot(exec.pseq).tag]);
    pseq=rot(exec.pseq);tmpemod.rot=0;
end

%collect cps for different triggers
tmp.cps.SotR=sum(pseq.cps(strncmp('SotR',val.fsmlabel,4)));
tmp.cps.CS=sum(pseq.cps(strncmp('CS',val.fsmlabel,2)));
tmp.cps.HotR=sum(pseq.cps(strncmp('HotR',val.fsmlabel,4)));
tmp.cps.AS=sum(pseq.cps(strncmp('AS',val.fsmlabel,2)));
tmp.cps.J=sum(pseq.cps(strncmp('J',val.fsmlabel,1)));
tmp.cps.WoG=sum(pseq.cps(strncmp('WoG',val.fsmlabel,3)));
tmp.cps.HW=sum(pseq.cps(strncmp('HW',val.fsmlabel,2)));

%% Weapon Enchants

switch tmp.wench
    
    
    %% Windwalk
    case 74244
        %formulation
        ww.pc=gear.swing./60;ww.pd=10;
        %output
        dtrack=[];dstore=gear.dodge;
        for dloop=0:600:600
            gear.dodge=gear.dodge+dloop;
            stat_model;
            dtrack=[dtrack player.dodge];
        end
        %average effectiveness
        ww.q=(1-ww.pc.*mdf.mehit).^(ww.pd.*tmp.cps.SotR) ...    	%SotR
            .*(1-ww.pc.*mdf.mehit).^(ww.pd.*tmp.cps.CS) ...         %CS
            .*(1-ww.pc.*mdf.mehit).^(ww.pd.*tmp.cps.HotR) ...       %HotR
            .*(1-ww.pc.*mdf.rahit).^(ww.pd.*tmp.cps.AS) ...         %AS
            .*(1-ww.pc.*mdf.rahit).^(ww.pd.*tmp.cps.J) ...          %J
            .*(1-ww.pc.*mdf.mehit).^(ww.pd./player.phs.*(1+player.reck.*(1-ww.pc.*mdf.mehit))); %AA
        ww.p=1-ww.q;
        ww.dodge=ww.p.*(dtrack(2)-dtrack(1));
        %cleanup
        gear.dodge=dstore;
        clear dtrack dstore
        
        proc.dodge=proc.dodge+ww.dodge;

    %% Landslide
    case 74246
        %formulation
        ls.pc=gear.swing./60;ls.pd=12;
        %reference output
%         stat_model;ability_model;rotation_model;
        ls.base=pseq.totdps;
        %proc-based output
        astore=gear.ap;gear.ap=gear.ap+1000;
        stat_model;ability_model;rotation_model;
        %average effectiveness
        ls.q=(1-ls.pc.*mdf.mehit).^(ls.pd.*tmp.cps.SotR) ...      	%SotR
            .*(1-ls.pc.*mdf.mehit).^(ls.pd.*tmp.cps.CS) ...         %CS
            .*(1-ls.pc.*mdf.mehit).^(ls.pd.*tmp.cps.HotR) ...       %HotR
            .*(1-ls.pc.*mdf.rahit).^(ls.pd.*tmp.cps.AS) ...         %AS
            .*(1-ls.pc.*mdf.rahit).^(ls.pd.*tmp.cps.J) ...          %J
            .*(1-ls.pc.*mdf.mehit).^(ls.pd./player.phs.*(1+player.reck.*(1-ls.pc.*mdf.mehit))); %AA
        ls.p=1-ls.q;
        ls.dps=(rot(exec.pseq).totdps-ls.base).*ls.p;
        if tmpemod.rot~=0
            ls.dps=(rot(cfg(c).rot).totdps-ls.base).*ls.p;
        else
            ls.dps=(rot(exec.pseq).totdps-ls.base).*ls.p;
        end
        %cleanup
        gear.ap=astore;
        clear astore
        proc.dps=proc.dps+ls.dps;
        proc.tps=proc.tps+ls.dps.*mdf.RFury;
        
        
    %% Avalanche
    case 74197
        %formulation
        av.ppc=5.*gear.swing./60;av.spc=0.2;av.sicd=10;
        av.dpp=500.*mdf.spdmg.*mdf.spcrit.*target.resrdx;
        %trigger rates
%         stat_model;ability_model;
        av.ptps=mdf.mehit.*tmp.cps.SotR ... %SotR
            +mdf.mehit.*tmp.cps.CS ...      %CS
            +mdf.mehit.*tmp.cps.HotR ...    %HotR
            +mdf.rahit.*tmp.cps.AS ...      %AS
            +mdf.rahit.*tmp.cps.J ...       %J
            +mdf.mehit./player.wswing;      %AA
        av.stps=tmp.cps.WoG ...             %WoG
            +mdf.sphit.*tmp.cps.HW ...      %HW
            +1./cens.NetTick;               %Cens
        %effective cooldown/proc chance for spell-based triggers
        av.effsicd=ceil(av.sicd.*av.stps)./av.stps;
        av.effspc=1./(av.stps.*(av.effsicd+1./(av.stps.*av.spc)));
        %output
        av.pps=av.ptps.*av.ppc+av.stps.*av.effspc;
        av.dps=av.dpp.*av.pps;
        av.tps=av.dps.*mdf.RFury;
        
        proc.dps=proc.dps+av.dps;
        proc.tps=proc.tps+av.tps;
    
    %% Hurricane   
    case 74223
        %formulation
        hu.ppc=gear.swing./60;hu.spc=0.15;hu.pd=12;hu.sicd=45;
        %output
        htrack=zeros(4,val.length,6);hstore=gear.haste;
        for j=1:1:5
            gear.haste=hstore+450.*sum(htrack(2:3,:,j));
            stat_model;ability_model;
            hu.p=zeros(1,val.length);hu.q=hu.p;
            hu.q(1,:)=(1-hu.ppc.*mdf.mehit).^(hu.pd.*tmp.cps.SotR) ...    	%SotR
                .*(1-hu.ppc.*mdf.mehit).^(hu.pd.*tmp.cps.CS) ...            %CS
                .*(1-hu.ppc.*mdf.mehit).^(hu.pd.*tmp.cps.HotR) ...          %HotR
                .*(1-hu.ppc.*mdf.rahit).^(hu.pd.*tmp.cps.AS) ...            %AS
                .*(1-hu.ppc.*mdf.rahit).^(hu.pd.*tmp.cps.J) ...             %J
                .*(1-hu.ppc.*mdf.mehit).^(hu.pd./player.phs.*(1+player.reck.*(1-hu.ppc.*mdf.mehit))); %AA
            hu.p(1,:)=1-hu.q(1,:);
            hu.q(2,:)=(1-hu.spc).^(hu.pd.*tmp.cps.WoG) ...          %WoG
                .*(1-hu.spc.*mdf.sphit).^(hu.pd.*tmp.cps.HW) ...    %HW
                .*(1-hu.spc).^(hu.pd./cens.NetTick);                %Cens
            hu.p(2,:)=1-hu.q(2,:);
            hu.tm=zeros(4,4,val.length);hu.dd=hu.tm;hu.upt=zeros(4,val.length);
            hu.tm(1,1,:)=hu.q(1,:).*hu.q(2,:);hu.tm(1,2,:)=hu.p(1,:);hu.tm(1,3,:)=hu.p(2,:).*hu.q(1,:);
            hu.tm(2,1,:)=hu.q(1,:);hu.tm(2,2,:)=hu.p(1,:);
            hu.tm(3,1,:)=hu.q(1,:);hu.tm(3,4,:)=hu.p(1,:);
            hu.tm(4,1,:)=hu.q(1,:);hu.tm(4,4,:)=hu.p(1,:);
            for k=1:val.length hu.dd(:,:,k)=hu.tm(:,:,k)^100;hu.upt(:,k)=hu.dd(1,:,k);end;
            hu.upt=(hu.upt.*hu.pd+vertcat([hu.q(1,:);hu.p(1,:)],zeros(2,val.length)).*hu.sicd)./(hu.pd+hu.sicd);
            htrack(:,:,j+1)=hu.upt;
            gear.haste=hstore+900.*htrack(4,:,j);
            stat_model;ability_model;
            hu.p=zeros(1,val.length);hu.q=hu.p;
            hu.q(1,:)=(1-hu.ppc.*mdf.mehit).^(hu.pd.*tmp.cps.SotR) ...   %SotR
                .*(1-hu.ppc.*mdf.mehit).^(hu.pd.*tmp.cps.CS) ...         %CS
                .*(1-hu.ppc.*mdf.mehit).^(hu.pd.*tmp.cps.HotR) ...       %HotR
                .*(1-hu.ppc.*mdf.rahit).^(hu.pd.*tmp.cps.AS) ...         %AS
                .*(1-hu.ppc.*mdf.rahit).^(hu.pd.*tmp.cps.J) ...          %J
                .*(1-hu.ppc.*mdf.mehit).^(hu.pd./player.phs.*(1+player.reck.*(1-hu.ppc.*mdf.mehit))); %AA
            hu.p(1,:)=1-hu.q(1,:);
            hu.q(2,:)=(1-hu.spc).^(hu.pd.*tmp.cps.WoG) ...               %WoG
                .*(1-hu.spc.*mdf.sphit).^(hu.pd.*tmp.cps.HW) ...         %HW
                .*(1-hu.spc).^(hu.pd./cens.NetTick);                     %Cens
            hu.p(2,:)=1-hu.q(2,:);
            hu.tm=zeros(4,4,val.length);hu.dd=hu.tm;hu.upt=zeros(4,val.length);
            hu.tm(1,1,:)=hu.q(1,:).*hu.q(2,:);hu.tm(1,2,:)=hu.p(1,:);hu.tm(1,3,:)=hu.p(2,:).*hu.q(1,:);
            hu.tm(2,1,:)=hu.q(1,:);hu.tm(2,2,:)=hu.p(1,:);
            hu.tm(3,1,:)=hu.q(1,:);hu.tm(3,4,:)=hu.p(1,:);
            hu.tm(4,1,:)=hu.q(1,:);hu.tm(4,4,:)=hu.p(1,:);
            for k=1:val.length hu.dd(:,:,k)=hu.tm(:,:,k)^100;hu.upt(:,k)=hu.dd(1,:,k);end;
            hu.upt=(hu.upt.*hu.pd+vertcat([hu.q(1,:);hu.p(1,:)],zeros(2,val.length)).*hu.sicd)./(hu.pd+hu.sicd);
            htrack(:,:,j+1)=(hu.upt.*hu.pd+htrack(:,:,j+1).*hu.sicd)./(hu.pd+hu.sicd);
        end
        hu.dps=[];
        for j=0:450:900
            gear.haste=hstore+j;
            stat_model;ability_model;rotation_model;
            if tmpemod.rot~=0
                hu.dps=[hu.dps;rot(cfg(c).rot).totdps];
            else
                hu.dps=[hu.dps;rot(exec.pseq).totdps];
            end
        end
        hu.dps=hu.dps(1,:).*(htrack(1,:,6)-1)+hu.dps(2,:).*sum(htrack(2:3,:,6))+hu.dps(3,:).*htrack(4,:,6);
        hu.tps=hu.dps.*mdf.RFury;
        %cleanup
        gear.haste=hstore;
        clear i j k htrack hstore tmpemod
        
        proc.dps=proc.dps+hu.dps;
        proc.tps=proc.tps+hu.tps;
        
    %% Mending
    case 74195
        %formulation
        mend.ppc=3.*gear.swing./60;mend.spc=0.15;mend.sicd=15;
        mend.hpp=800.*mdf.hcrit.*mdf.Divin;
        %trigger rates
%         stat_model;ability_model;
        mend.ptps=mdf.mehit.*tmp.cps.SotR ...	%SotR
            +mdf.mehit.*tmp.cps.CS ...          %CS
            +mdf.mehit.*tmp.cps.HotR ...        %HotR
            +mdf.rahit.*tmp.cps.AS ...          %AS
            +mdf.rahit.*tmp.cps.J ...           %J
            +mdf.mehit./player.wswing;          %AA
        mend.stps=tmp.cps.WoG ...            %WoG
            +mdf.sphit.*tmp.cps.HW ...       %HW
            +1./cens.NetTick;                %Cens
        %effective cooldown/proc chance for spell-based triggers
        mend.effsicd=ceil(mend.sicd.*mend.stps)./mend.stps;
        mend.effspc=1./(mend.stps.*(mend.effsicd+1./(mend.stps.*mend.spc)));
        %output
        mend.pps=mend.ptps.*mend.ppc+mend.stps.*mend.effspc;
        mend.hps=mend.hpp.*mend.pps;
        mend.tps=mend.hps.*mdf.hthreat.*mdf.RFury./exec.npccount;
        
        proc.hps=proc.hps+mend.hps;
        proc.tps=proc.tps+mend.tps;

end

%% Weapons
switch tmp.weap

    
    case {78488,77193,78479}
        
        switch tmp.weap
            case 78488
                souldrinker.coeff=0.013;
            case 77193
                souldrinker.coeff=0.015;
            case 78479
                souldrinker.coeff=0.017;
        end
        
        %% Souldrinker
        %formulation
        souldrinker.pc=0.15;
        souldrinker.dpp=souldrinker.coeff.*player.hitpoints.*mdf.spdmg.*target.resrdx;
        souldrinker.hpp=2.*souldrinker.dpp.*mdf.Divin;
        %trigger rates
%         stat_model;ability_model;
        souldrinker.ptps=mdf.mehit.*tmp.cps.SotR ... %SotR
            +mdf.mehit.*tmp.cps.CS ...      %CS
            +mdf.mehit.*tmp.cps.HotR ...    %HotR
            +min([exec.npccount;1+2.*(mdf.glyphAS==1)]).*mdf.rahit.*tmp.cps.AS ... %AS
            +mdf.mehit./player.wswing;      %AA
        %output
        souldrinker.pps=souldrinker.ptps.*souldrinker.pc;
        souldrinker.dps=souldrinker.pps.*souldrinker.dpp;
        souldrinker.hps=souldrinker.dps.*souldrinker.hpp;
        souldrinker.tps=(souldrinker.dps+souldrinker.hps.*mdf.hthreat./exec.npccount).*mdf.RFury;

        proc.dps=proc.dps+souldrinker.dps;
        proc.hps=proc.hps+souldrinker.hps;
        proc.tps=proc.tps+souldrinker.tps;
        
    case {77188,78472}
        switch tmp.weap
            case 1
                nokaled.basedmg=8476;
            case 77188
                nokaled.basedmg=9567.5;
            case 78472
                nokaled.basedmg=10800;
        end
        %% No'Kaled
        %formulation
        nokaled.pc=0.065;
        nokaled.dpp=nokaled.basedmg.*mdf.spdmg.*mdf.spcrit.*target.resrdx;
        %trigger rates
%         stat_model;ability_model;
        nokaled.ptps=mdf.mehit.*tmp.cps.SotR ... %SotR
            +mdf.mehit.*tmp.cps.CS ...      %CS
            +mdf.mehit.*tmp.cps.HotR ...    %HotR
            +min([exec.npccount;1+2.*(mdf.glyphAS==1)]).*mdf.rahit.*tmp.cps.AS ... %AS
            +mdf.mehit./player.wswing;      %AA
        %output
        nokaled.pps=nokaled.ptps.*nokaled.pc;
        nokaled.dps=nokaled.pps.*nokaled.dpp;
        nokaled.tps=nokaled.dps.*mdf.RFury;
        
        proc.dps=proc.dps+nokaled.dps;
        proc.tps=proc.tps+nokaled.tps;

end

clear pseq