%enchant_model handles dynamic enchants

%This module requires a rotation input.  If rotation_model hasn't been run,
%do so now
if exist('rot','var')==0 
    rotation_model;
end
%for maximum flexibility, the rotation used is defined as 'seq'.  If this
%hasn't been defined, default to 9C9
pseq=rot(exec.pseq);


%% Windwalk
%formulation
ww.pc=gear.swing./60;ww.pd=10;
%output
dtrack=[];dstore=gear.dodge;
for dloop=0:600:600
    gear.dodge=gear.dodge+dloop;
    stat_model;ability_model;rotation_model;
    dtrack=[dtrack player.dodge];
end
%average effectiveness
ww.q=(1-ww.pc.*mdf.mehit).^(ww.pd./player.wswing) ...  %AA
    .*(1-ww.pc.*mdf.mehit).^(ww.pd.*pseq.cps(2,:)) ... %CS
    .*(1-ww.pc).^(ww.pd.*pseq.cps(1,:)) ...            %SotR
    .*(1-ww.pc.*mdf.rahit).^(ww.pd.*pseq.cps(3,:)) ... %J
    .*(1-ww.pc.*mdf.rahit).^(ww.pd.*pseq.cps(4,:));    %AS
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
ls.base=rot(exec.pseq).totdps;
%proc-based output
astore=gear.ap;gear.ap=gear.ap+1000;
stat_model;ability_model;rotation_model;
%average effectiveness
ls.q=(1-ls.pc.*mdf.mehit).^(ls.pd./player.wswing) ...  %AA
    .*(1-ls.pc.*mdf.mehit).^(ls.pd.*pseq.cps(2,:)) ... %CS
    .*(1-ls.pc).^(ls.pd.*pseq.cps(1,:)) ...            %SotR
    .*(1-ls.pc.*mdf.rahit).^(ls.pd.*pseq.cps(3,:)) ... %J
    .*(1-ls.pc.*mdf.rahit).^(ls.pd.*pseq.cps(4,:));    %AS
ls.p=1-ls.q;
ls.dps=(rot(exec.pseq).totdps-ls.base).*ls.p;
%cleanup
gear.ap=astore;
clear astore


%% Avalanche
%formulation
av.ppc=5.*gear.swing./60;av.spc=0.2;av.sicd=10;
av.dpp=500.*mdf.spdmg.*mdf.spcrit.*target.resrdx;
%trigger rates
stat_model;ability_model;rotation_model;
av.ptps=mdf.mehit./player.wswing ... %AA
    +mdf.mehit.*pseq.cps(2,:) ...    %CS
    +pseq.cps(1,:) ...               %SotR
    +mdf.rahit.*pseq.cps(3,:) ...    %J
    +mdf.rahit.*pseq.cps(4,:);       %AS
av.stps=1./cens.NetTick ...                                     %Cens
    +mdf.sphit.*pseq.cps(5,:);                                  %HW
if (min(pseq.cps(13,:))>0) av.stps=av.stps+pseq.cps(13,:); end; %WoG
%effective cooldown/proc chance for spell-based triggers
av.effsicd=ceil(av.sicd.*av.stps)./av.stps;
av.effspc=1./(av.stps.*(av.effsicd+1./(av.stps.*av.spc)));
%output
av.pps=av.ptps.*av.ppc+av.stps.*av.effspc;
av.dps=av.dpp.*av.pps;


%% Hurricane
%formulation
hu.ppc=gear.swing./60;hu.spc=0.15;hu.pd=12;hu.sicd=45;
%output
htrack=zeros(1,4);hstore=gear.haste;
for i=1:5
    j=i;
    gear.haste=hstore+450.*sum(htrack(j,2:3));
    stat_model;ability_model;
    hu.q(1)=(1-hu.ppc.*mdf.mehit).^(hu.pd./player.wswing) ... %AA
        .*(1-hu.ppc.*mdf.mehit).^(hu.pd.*pseq.cps(2,:)) ...   %CS
        .*(1-hu.ppc).^(hu.pd.*pseq.cps(1,:)) ...              %SotR
        .*(1-hu.ppc.*mdf.rahit).^(hu.pd.*pseq.cps(3,:)) ...   %J
        .*(1-hu.ppc.*mdf.rahit).^(hu.pd.*pseq.cps(4,:));      %AS
    hu.p(1)=1-hu.q(1);
    hu.q(2)=(1-hu.spc).^(hu.pd./cens.NetTick) ...           %Cens
        .*(1-hu.spc.*mdf.sphit).^(hu.pd.*pseq.cps(5,:)) ... %HW
        .*(1-hu.spc).^(hu.pd.*pseq.cps(13,:));              %WoG 
    hu.p(2)=1-hu.q(2);
    hu.tm=zeros(4,4);
    hu.tm(1,1)=hu.q(1).*hu.q(2);hu.tm(1,2)=hu.p(1).*hu.q(2);hu.tm(1,3)=hu.p(2).*hu.q(1);hu.tm(1,4)=hu.p(1).*hu.p(2);
    hu.tm(2,2)=1;
    hu.tm(3,3)=hu.q(1);hu.tm(3,4)=hu.p(1);
    hu.tm(4,4)=1;
    hu.dd=hu.tm^100;hu.upt=hu.dd(1,:);
    hu.upt=(hu.upt.*hu.pd+[hu.q(1) hu.p(1) 0 0].*hu.sicd)./(hu.pd+hu.sicd);
    htrack=[htrack;hu.upt];
    gear.haste=hstore+900.*htrack(j,4);
    stat_model;ability_model;
    hu.q(1)=(1-hu.ppc.*mdf.mehit).^(hu.pd./player.wswing) ... %AA
        .*(1-hu.ppc.*mdf.mehit).^(hu.pd.*pseq.cps(2,:)) ...   %CS
        .*(1-hu.ppc).^(hu.pd.*pseq.cps(1,:)) ...              %SotR
        .*(1-hu.ppc.*mdf.rahit).^(hu.pd.*pseq.cps(3,:)) ...   %J
        .*(1-hu.ppc.*mdf.rahit).^(hu.pd.*pseq.cps(4,:));      %AS
    hu.p(1)=1-hu.q(1);
    hu.q(2)=(1-hu.spc).^(hu.pd./cens.NetTick) ...           %Cens
        .*(1-hu.spc.*mdf.sphit).^(hu.pd.*pseq.cps(5,:)) ... %HW
        .*(1-hu.spc).^(hu.pd.*pseq.cps(13,:));              %WoG
    hu.p(2)=1-hu.q(2);
    hu.tm=zeros(4,4);
    hu.tm(1,1)=hu.q(1).*hu.q(2);hu.tm(1,2)=hu.p(1).*hu.q(2);hu.tm(1,3)=hu.p(2).*hu.q(1);hu.tm(1,4)=hu.p(1).*hu.p(2);
    hu.tm(2,2)=1;
    hu.tm(3,3)=hu.q(1);hu.tm(3,4)=hu.p(1);
    hu.tm(4,4)=1;
    hu.dd=hu.tm^100;hu.upt=hu.dd(1,:);
    hu.upt=(hu.upt.*hu.pd+[hu.q(1) hu.p(1) 0 0].*hu.sicd)./(hu.pd+hu.sicd);
    htrack(j+1,:)=(hu.upt.*hu.pd+htrack(j+1,:).*hu.sicd)./(hu.pd+hu.sicd);
end
hu.dps=[];
for j=0:450:900
    gear.haste=hstore+j;
    stat_model;ability_model;rotation_model;
    hu.dps=[hu.dps rot.totdps];
end
hu.dps=hu.dps(1).*(htrack(6,1)-1)+hu.dps(2).*sum(htrack(6,2:3))+hu.dps(3).*htrack(6,4);
%cleanup
gear.haste=hstore;
clear i j htrack hstore


%% Mending
%formulation
mend.ppc=3.*gear.swing./60;mend.spc=0.15;mend.sicd=15;
mend.hpp=800.*mdf.hcrit.*mdf.Divin;
%trigger rates
stat_model;ability_model;rotation_model;
mend.ptps=mdf.mehit./player.wswing ... %AA
    +mdf.mehit.*pseq.cps(2,:) ...      %CS
    +pseq.cps(1,:) ...                 %SotR
    +mdf.rahit.*pseq.cps(3,:) ...      %J
    +mdf.rahit.*pseq.cps(4,:);         %AS
mend.stps=1./cens.NetTick ...                                       %Cens
    +mdf.sphit.*pseq.cps(5,:);                                      %HW
if (min(pseq.cps(13,:))>0) mend.stps=mend.stps+pseq.cps(13,:); end; %WoG
%effective cooldown/proc chance for spell-based triggers
mend.effsicd=ceil(mend.sicd.*mend.stps)./mend.stps;
mend.effspc=1./(mend.stps.*(mend.effsicd+1./(mend.stps.*mend.spc)));
%output
mend.pps=mend.ptps.*mend.ppc+mend.stps.*mend.effspc;
mend.hps=mend.hpp.*av.pps;