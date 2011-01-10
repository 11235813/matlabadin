%enchant_model handles dynamic enchants

%This module requires a rotation input.  If rotation_model hasn't been run,
%do so now
if exist('rot','var')==0 
    rotation_model;
end
%for maximum flexibility, the rotation used is defined as 'seq'.  If this
%hasn't been defined, default to 9C9
if exist('seq','var')==0
    seq=rot;
    warning('"seq" defaulted to 9C9')
end


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
ww.q=(1-ww.pc.*mdf.mehit).^(ww.pd./player.wswing) ... %AA
    .*(1-ww.pc.*mdf.mehit).^(ww.pd.*seq.cps(2)) ...   %CS
    .*(1-ww.pc).^(ww.pd.*seq.cps(1)) ...              %SotR
    .*(1-ww.pc.*mdf.rahit).^(ww.pd.*seq.cps(3)) ...   %J
    .*(1-ww.pc.*mdf.rahit).^(ww.pd.*seq.cps(4));      %AS
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
ls.base=rot.totdps;
%proc-based output
astore=gear.ap;gear.ap=gear.ap+1000;
stat_model;ability_model;rotation_model;
%average effectiveness
ls.q=(1-ls.pc.*mdf.mehit).^(ls.pd./player.wswing) ... %AA
    .*(1-ls.pc.*mdf.mehit).^(ls.pd.*seq.cps(2)) ...   %CS
    .*(1-ls.pc).^(ls.pd.*seq.cps(1)) ...              %SotR
    .*(1-ls.pc.*mdf.rahit).^(ls.pd.*seq.cps(3)) ...   %J
    .*(1-ls.pc.*mdf.rahit).^(ls.pd.*seq.cps(4));      %AS
ls.p=1-ls.q;
ls.dps=(rot.totdps-ls.base).*ls.p;
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
    +mdf.mehit.*seq.cps(2) ...       %CS
    +seq.cps(1) ...                  %SotR
    +mdf.rahit.*seq.cps(3) ...       %J
    +mdf.rahit.*seq.cps(4);          %AS
av.stps=1./cens.NetTick ... %Cens
    +mdf.sphit.*seq.cps(5); %HW
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
    gear.haste=hstore+450.*sum(htrack(i,2:3));
    stat_model;ability_model;
    hu.q(1)=(1-hu.ppc.*mdf.mehit).^(hu.pd./player.wswing) ... %AA
        .*(1-hu.ppc.*mdf.mehit).^(hu.pd.*seq.cps(2)) ...      %CS
        .*(1-hu.ppc).^(hu.pd.*seq.cps(1)) ...                 %SotR
        .*(1-hu.ppc.*mdf.rahit).^(hu.pd.*seq.cps(3)) ...      %J
        .*(1-hu.ppc.*mdf.rahit).^(hu.pd.*seq.cps(4));         %AS
    hu.p(1)=1-hu.q(1);
    hu.q(2)=(1-hu.spc).^(hu.pd./cens.NetTick) ...     %Cens
        .*(1-hu.spc.*mdf.sphit).^(hu.pd.*seq.cps(5)); %HW
    hu.p(2)=1-hu.q(2);
    hu.tm=zeros(4,4);
    hu.tm(1,1)=hu.q(1).*hu.q(2);hu.tm(1,2)=hu.p(1).*hu.q(2);hu.tm(1,3)=hu.p(2).*hu.q(1);hu.tm(1,4)=hu.p(1).*hu.p(2);
    hu.tm(2,2)=1;
    hu.tm(3,3)=hu.q(1);hu.tm(3,4)=hu.p(1);
    hu.tm(4,4)=1;
    hu.dd=hu.tm^100;hu.upt=hu.dd(1,:);
    hu.upt=(hu.upt.*hu.pd+[hu.q(1) hu.p(1) 0 0].*hu.sicd)./(hu.pd+hu.sicd);
    htrack=[htrack;hu.upt];
    gear.haste=hstore+900.*htrack(i,4);
    stat_model;ability_model;
    hu.q(1)=(1-hu.ppc.*mdf.mehit).^(hu.pd./player.wswing) ... %AA
        .*(1-hu.ppc.*mdf.mehit).^(hu.pd.*seq.cps(2)) ...      %CS
        .*(1-hu.ppc).^(hu.pd.*seq.cps(1)) ...                 %SotR
        .*(1-hu.ppc.*mdf.rahit).^(hu.pd.*seq.cps(3)) ...      %J
        .*(1-hu.ppc.*mdf.rahit).^(hu.pd.*seq.cps(4));         %AS
    hu.p(1)=1-hu.q(1);
    hu.q(2)=(1-hu.spc).^(hu.pd./cens.NetTick) ...     %Cens
        .*(1-hu.spc.*mdf.sphit).^(hu.pd.*seq.cps(5)); %HW
    hu.p(2)=1-hu.q(2);
    hu.tm=zeros(4,4);
    hu.tm(1,1)=hu.q(1).*hu.q(2);hu.tm(1,2)=hu.p(1).*hu.q(2);hu.tm(1,3)=hu.p(2).*hu.q(1);hu.tm(1,4)=hu.p(1).*hu.p(2);
    hu.tm(2,2)=1;
    hu.tm(3,3)=hu.q(1);hu.tm(3,4)=hu.p(1);
    hu.tm(4,4)=1;
    hu.dd=hu.tm^100;hu.upt=hu.dd(1,:);
    hu.upt=(hu.upt.*hu.pd+[hu.q(1) hu.p(1) 0 0].*hu.sicd)./(hu.pd+hu.sicd);
    htrack(i+1,:)=(hu.upt.*hu.pd+htrack(i+1,:).*hu.sicd)./(hu.pd+hu.sicd);
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