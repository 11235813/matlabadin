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
ww.pc=gear.swing./60;ww.pd=10;
ww.q=(1-ww.pc.*mdf.mehit).^(ww.pd./player.wswing) ...            %AA
    .*(1-ww.pc.*mdf.mehit).^(ww.pd.*seq.cps(2)) ...            %CS
    .*(1-ww.pc).^(ww.pd.*seq.cps(1)) ...             %SotR
    .*(1-ww.pc.*mdf.rahit).^(ww.pd.*seq.cps(3)) ...     %J
    .*(1-ww.pc.*mdf.rahit).^(ww.pd.*seq.cps(4));               %AS
ww.p=1-ww.q;
dtrack=[];
for dloop=0:600:1800
    tmpavd=avoid_dr(base,gear.dodge+consum.dodge+dloop,gear.parry+consum.parry ...
        +floor((player.str-base.stats.str)./4),player.agi-base.stats.agi);
    dtrack=[dtrack tmpavd.dodgedr];
end
ww.tm=[ww.q ww.p    0    0;
    ww.q    0 ww.p    0;
    ww.q    0    0 ww.p;
    ww.q    0    0 ww.p];
ww.dd=ww.tm^100;
ww.upt=ww.dd(1,:);
ww.gupt=1-ww.upt(1,1);
ww.stacks=(ww.upt(2)+2.*ww.upt(3)+3.*ww.upt(4))./ww.gupt;
ww.dodge=0;
for dloop=1:4
    ww.dodge=ww.dodge+ww.upt(dloop).*dtrack(dloop);
end
ww.dodge(1)=ww.dodge-dtrack(1);
ww.dodge(2)=ww.p.*(dtrack(2)-dtrack(1));
% [ww.gupt ww.stacks ww.dodge(1) ww.dodge(2)]


%% Landslide
ls.pc=gear.swing./60;ls.pd=12;
ls.q=(1-ls.pc.*mdf.mehit).^(ls.pd./player.wswing) ...            %AA
    .*(1-ls.pc.*mdf.mehit).^(ls.pd.*seq.cps(2)) ... %CS
    .*(1-ls.pc).^(ls.pd.*seq.cps(1)) ...               %SotR
    .*(1-ls.pc.*mdf.rahit).^(ls.pd.*seq.cps(3)) ...    %J
    .*(1-ls.pc.*mdf.rahit).^(ls.pd.*seq.cps(4)); %AS
ls.p=1-ls.q;
ls.base=rot.totdps;
gear.ap=gear.ap+1000;stat_model;ability_model;rotation_model;
ls.dps=(rot.totdps-ls.base).*ls.p;
% [ls.p ls.dps]


%% Avalanche
av.ppc=5.*gear.swing./60;av.spc=0.1;
av.dpp=500.*mdf.spdmg.*mdf.spcrit.*target.resrdx;
av.ptps=mdf.mehit./player.wswing ...        %AA
    +mdf.mehit.*seq.cps(2) ... %CS
    +seq.cps(1) ...            %SotR
    +mdf.rahit.*seq.cps(3) ...    %J
    +mdf.rahit.*seq.cps(4); %AS
av.stps=1./cens.NetTick ...                                           %Cens
    +max([0.75-P.CS;rot.val.zeros]).*mdf.sphit./(9+1.5.*rot.xtragcd); %HW
av.pps=av.ptps.*av.ppc+av.stps.*av.spc;
av.dps=av.dpp.*av.pps;
% [av.dpp av.pps av.dps]


%% Hurricane
hu.ppc=gear.swing./60;hu.spc=0.15;hu.pd=12;hu.sicd=45;
htrack=zeros(1,4);
hstore=gear.haste;
for i=1:5
    gear.haste=hstore+450.*sum(htrack(i,2:3));
    stat_model;ability_model;
    hu.q(1)=(1-hu.ppc.*mdf.mehit).^(hu.pd./player.wswing) ...            %AA
        .*(1-hu.ppc.*mdf.mehit).^(hu.pd.*seq.cps(2)) ... %CS
        .*(1-hu.ppc).^(hu.pd.*seq.cps(1)) ...               %SotR
        .*(1-hu.ppc.*mdf.rahit).^(hu.pd.*seq.cps(3)) ...    %J
        .*(1-hu.ppc.*mdf.rahit).^(hu.pd.*seq.cps(4)); %AS
    hu.p(1)=1-hu.q(1);
    hu.q(2)=(1-hu.spc).^(hu.pd./cens.NetTick) ...
        .*(1-hu.spc.*mdf.sphit).^(hu.pd.*seq.cps(5));
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
    hu.q(1)=(1-hu.ppc.*mdf.mehit).^(hu.pd./player.wswing) ...            %AA
        .*(1-hu.ppc.*mdf.mehit).^(hu.pd.*3./(9+1.5.*rot.xtragcd)) ... %CS
        .*(1-hu.ppc).^(hu.pd./(9+1.5.*rot.xtragcd)) ...               %SotR
        .*(1-hu.ppc.*mdf.rahit).^(hu.pd./(9+1.5.*rot.xtragcd)) ...    %J
        .*(1-hu.ppc.*mdf.rahit).^(hu.pd.*P.CS./(9+1.5.*rot.xtragcd)); %AS
    hu.p(1)=1-hu.q(1);
    hu.q(2)=(1-hu.spc).^(hu.pd./cens.NetTick) ...
        .*(1-hu.spc.*mdf.sphit).^(hu.pd.*max([0.75-P.CS;zeros(size(mdf.mehit))])./(9+1.5.*rot.xtragcd));
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
% [htrack(6,:) hu.dps]
