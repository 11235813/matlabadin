%enchant_model handles dynamic enchants

%This module requires a rotation input.  If rotation_model hasn't been run,
%do so now
if exist('rot','var')==0 
    rotation_model;
end
%for maximum flexibility, the rotation used is defined as 'seq'.  If this
%hasn't been defined (either in cfg or exec), default to 9C9
if exist('cfg','var') && exist('c','var') && isfield(cfg(c),'rot')  %c always used as config index variable
    pseq=rot(cfg(c).rot);tmpemod.rot=1;
else
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

%% Windwalk
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


%% Landslide
%formulation
ls.pc=gear.swing./60;ls.pd=12;
%reference output
stat_model;ability_model;rotation_model;
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


%% Avalanche
%formulation
av.ppc=5.*gear.swing./60;av.spc=0.2;av.sicd=10;
av.dpp=500.*mdf.spdmg.*mdf.spcrit.*target.resrdx;
%trigger rates
stat_model;ability_model;
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


%% Hurricane
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
%cleanup
gear.haste=hstore;
clear i j k htrack hstore tmpemod


%% Mending
%formulation
mend.ppc=3.*gear.swing./60;mend.spc=0.15;mend.sicd=15;
mend.hpp=800.*mdf.hcrit.*mdf.Divin;
%trigger rates
stat_model;ability_model;
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


%% Souldrinker
%formulation
souldrinkerproc.pc=0.15;
souldrinkerproc.dpp=player.hitpoints.*mdf.spdmg.*target.resrdx;
souldrinkerproc.hpp=2.*souldrinkerproc.dpp.*mdf.Divin;
%trigger rates
stat_model;ability_model;
souldrinkerproc.ptps=mdf.mehit.*(1+mdf.mehit.*mdf.tseal).*tmp.cps.SotR ... %SotR
    +mdf.mehit.*(1+mdf.mehit.*mdf.tseal).*tmp.cps.CS ...      %CS
    +mdf.mehit.*(1+mdf.mehit.*mdf.tseal).*tmp.cps.HotR ...    %HotR
    +min([exec.npccount;1+2.*(mdf.glyphAS==1)]).*mdf.rahit.*(1+mdf.mehit.*mdf.tseal).*tmp.cps.AS ... %AS
    +mdf.rahit.*mdf.mehit.*mdf.tseal.*tmp.cps.J ...           %J
    +mdf.mehit.*(1+mdf.mehit.*mdf.tseal)./player.wswing;      %AA
%output
souldrinkerproc.pps=souldrinkerproc.ptps.*souldrinkerproc.pc;
souldrinkerproc.dps{1}=0.013.*souldrinkerproc.pps.*souldrinkerproc.dpp;
souldrinkerproc.hps{1}=souldrinkerproc.dps{1}.*souldrinkerproc.hpp;
souldrinkerproc.tps{1}=(souldrinkerproc.dps{1}+souldrinkerproc.hps{1}.*mdf.hthreat./exec.npccount).*mdf.RFury;
souldrinkerproc.dps{2}=0.015.*souldrinkerproc.pps.*souldrinkerproc.dpp;
souldrinkerproc.hps{2}=souldrinkerproc.dps{2}.*souldrinkerproc.hpp;
souldrinkerproc.tps{2}=(souldrinkerproc.dps{2}+souldrinkerproc.hps{2}.*mdf.hthreat./exec.npccount).*mdf.RFury;
souldrinkerproc.dps{3}=0.017.*souldrinkerproc.pps.*souldrinkerproc.dpp;
souldrinkerproc.hps{3}=souldrinkerproc.dps{3}.*souldrinkerproc.hpp;
souldrinkerproc.tps{3}=(souldrinkerproc.dps{3}+souldrinkerproc.hps{3}.*mdf.hthreat./exec.npccount).*mdf.RFury;


%% No'Kaled
%formulation
nokaledproc.pc=0.065;
nokaledproc.dpp=mdf.spdmg.*mdf.spcrit.*target.resrdx;
%trigger rates
stat_model;ability_model;
nokaledproc.ptps=mdf.mehit.*(1+mdf.mehit.*mdf.tseal).*tmp.cps.SotR ... %SotR
    +mdf.mehit.*(1+mdf.mehit.*mdf.tseal).*tmp.cps.CS ...      %CS
    +mdf.mehit.*(1+mdf.mehit.*mdf.tseal).*tmp.cps.HotR ...    %HotR
    +min([exec.npccount;1+2.*(mdf.glyphAS==1)]).*mdf.rahit.*(1+mdf.mehit.*mdf.tseal).*tmp.cps.AS ... %AS
    +mdf.rahit.*mdf.mehit.*mdf.tseal.*tmp.cps.J ...           %J
    +mdf.mehit.*(1+mdf.mehit.*mdf.tseal)./player.wswing;      %AA
%output
nokaledproc.pps=nokaledproc.ptps.*nokaledproc.pc;
nokaledproc.dps{1}=8476.*nokaledproc.pps.*nokaledproc.dpp;
nokaledproc.tps{1}=nokaledproc.dps{1}.*mdf.RFury;
nokaledproc.dps{2}=9567.5.*nokaledproc.pps.*nokaledproc.dpp;
nokaledproc.tps{2}=nokaledproc.dps{2}.*mdf.RFury;
nokaledproc.dps{3}=10800.*nokaledproc.pps.*nokaledproc.dpp;
nokaledproc.tps{3}=nokaledproc.dps{3}.*mdf.RFury;

clear pseq