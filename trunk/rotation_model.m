%% Rotation module

%initialize structure
rot=struct('tag','', ...
           'labels',[], ...
           'val',[], ...
           'xtragcd',[], ...
           'sotrfactor',[], ...
           'ncasts',[], ...
           'cps',[], ...
           'InqMod',[], ...
           'InqUp',[], ...
           'acdps',[], ...
           'achps',[], ...
           'actps',[], ...
           'padps',[], ...
           'pahps',[], ...
           'patps',[], ...
           'totdps',[], ...
           'tothps',[], ...
           'tottps',[]);

%fix entries
for i=1:8
    rot(i).labels={'Inq';'2SotR';'SotR';'WoG';'CS';'HotR';'AS';'Cons';'HoW';'HW';'J';'HaNova';'Seal'};
    rot(i).xtragcd=val.zeros;
    rot(i).sotrfactor=val.ones;
    rot(i).InqMod=ones(13,length(val.ones));
    rot(i).InqUp=val.ones;
    rot(i).padps=val.zeros;
    rot(i).pahps=val.zeros;
    rot(i).patps=val.zeros;
end

idx.sotr=[];
for i=1:length(rot(1).labels)
    if strfind(rot(1).labels{i},'SotR')
        idx.sotr=[idx.sotr i];
    end
end

%probability of SD proc from one J cast
mdf.sd1=mdf.rahit.*mdf.SacDut;
%probability of at least one SD proc from two J casts
mdf.sd2=mdf.rahit.*mdf.SacDut.*(2-mdf.rahit.*mdf.SacDut);

%probability of at least one GrCr proc from 3 CS/HotR casts
q.grcr=binopdf(0,3,mdf.mehit) ...                %no connects
    +binopdf(1,3,mdf.mehit).*(1-mdf.GrCr) ...    %one connects, no proc
    +binopdf(2,3,mdf.mehit).*(1-mdf.GrCr).^2 ... %two connects, no procs
    +binopdf(3,3,mdf.mehit).*(1-mdf.GrCr).^3;    %three connects, no procs
p.grcr=1-q.grcr;
%average AS cast count
clear tmprot
tmprot.cols(1,:)=ones(size(q.grcr));
for mmmm=2:50
tmprot.cols(mmmm,:)=p.grcr.*tmprot.cols(mmmm-1,:)+(1-tmprot.cols(mmmm-1,:));
end
P.grcr=mean(tmprot.cols(size(tmprot.cols,1)-1:size(tmprot.cols,1),:));

%% Naming Convention
%FG-X
%F = HP finisher
%G = HP generator
%X = Nominal Cycle Framework
%
%Examples: 
% -For the default 939, we use SotR as a finisher and CS as the generator,
% so F=S and G=C.  Since the cycle is based on the standard 939 framework,
% X=9, giving us SC9
% -If we alternate Inq and SotR as finishers, and use HotR as the
% generator, we get IHSH9
% -If we alternate I/S and only use HotR as the generator after an Inq, we
% get IHSC9

%% SC9 ("939" or "9C9") framework : SotR>CS>J>AS>Cons>HW (execute range : SotR>CS>J>HoW)
rot(1).tag='SC9';
rot(1).xtragcd=2.*((1./mdf.mehit)-1);
rot(1).sotrfactor=mdf.memodel.*(mdf.phcrit+mdf.mehit.*mdf.sd1.*(mdf.phcritm-mdf.phcrit)).*target.resrdx;
rot(1).ncasts=[...
    0.*val.ones;                                                       %Inq
    0.*val.ones;                                                       %2SotR
    2.*val.ones;                                                       %SotR
    0.*val.ones;                                                       %WoG
    ...
    6.*val.ones;                                                       %CS
    0.*val.ones;                                                       %HotR
    ...
    (2.*P.grcr.*0.81).*val.ones;                                       %AS
    (0.5.*0.81).*val.ones;                                             %Cons
    (2.*0.19).*val.ones;                                               %HoW
    (max([2.*(1-P.grcr)-0.5;zeros(size(mdf.mehit))]).*0.81).*val.ones; %HW
    2.*val.ones;                                                       %J
    ...
    0.*val.ones;                                                       %HammerNova
    (8.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*val.ones];                %seal (CS+SotR+J)  
rot(1).cps=rot(1).ncasts./repmat((18+1.5.*rot(1).xtragcd).*val.ones,size(rot(1).ncasts,1),1);
rot(1).coeff=rot(1).ncasts./repmat((18+1.5.*rot(1).xtragcd).*val.ones,size(rot(1).ncasts,1),1);
rot(1).coeff(idx.sotr,:)=rot(1).coeff(idx.sotr,:).*rot(1).sotrfactor;


%% IHSH9 framework : Inq>SotR>HotR>J>AS>Cons>HW (execute range : Inq>SotR>HotR>J>HoW)
rot(2).tag='IHSH9';
rot(2).xtragcd=(1./mdf.mehit)-1;
rot(2).sotrfactor=mdf.memodel.*(mdf.phcrit+mdf.mehit.*mdf.sd2.*(mdf.phcritm-mdf.phcrit)).*target.resrdx;
rot(2).ncasts=[...
    1.*val.ones;                                                       %Inq
    0.*val.ones;                                                       %2SotR
    1.*val.ones;                                                       %SotR
    0.*val.ones;                                                       %WoG
    ...
    0.*val.ones;                                                       %CS
    6.*val.ones;                                                       %HotR
    ...
    (2.*P.grcr.*0.81).*val.ones;                                       %AS
    (0.5.*0.81).*val.ones;                                             %Cons
    (2.*0.19).*val.ones;                                               %HoW
    (max([2.*(1-P.grcr)-0.5;zeros(size(mdf.mehit))]).*0.81).*val.ones; %HW
    2.*val.ones;                                                       %J
    ...
    6.*val.ones;                                                       %HammerNova
    (7.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*val.ones];                %seal (SotR+J)   
rot(2).cps=rot(2).ncasts./repmat((18+1.5.*rot(2).xtragcd).*val.ones,size(rot(2).ncasts,1),1);
rot(2).coeff=rot(2).ncasts./repmat((18+1.5.*rot(2).xtragcd).*val.ones,size(rot(2).ncasts,1),1);
rot(2).coeff(idx.sotr,:)=rot(2).coeff(idx.sotr,:).*rot(2).sotrfactor;
rot(2).InqMod=rot(2).InqMod+0.3.*[val.zeros;val.ones;val.ones;val.zeros;val.zeros;val.zeros;0.5.*val.ones;0.5.*val.ones;0.5.*val.ones;0.5.*val.ones;0.5.*val.ones;4./6.*val.ones;(mdf.mehit+mdf.rahit.*mdf.jseals)./(mdf.mehit+2.*mdf.rahit.*mdf.jseals).*val.ones]; %uptime depends on ability
rot(2).InqUp=rot(2).InqUp+0.3.*(12./(18+1.5.*rot(2).xtragcd)).*val.ones; 


%% SH9 ("9H9") framework : SotR>HotR>J>AS>Cons>HW (execute range : SotR>HotR>J>HoW)
rot(3).tag='SH9';
rot(3).xtragcd=2.*((1./mdf.mehit)-1);
rot(3).sotrfactor=mdf.memodel.*(mdf.phcrit+mdf.mehit.*mdf.sd1.*(mdf.phcritm-mdf.phcrit)).*target.resrdx;
rot(3).ncasts=[...
    0.*val.ones;                                                       %Inq
    0.*val.ones;                                                       %2SotR
    2.*val.ones;                                                       %SotR
    0.*val.ones;                                                       %WoG
    ...
    0.*val.ones;                                                       %CS
    6.*val.ones;                                                       %HotR
    ...
    (2.*P.grcr.*0.81).*val.ones;                                       %AS
    (0.5.*0.81).*val.ones;                                             %Cons
    (2.*0.19).*val.ones;                                               %HoW
    (max([2.*(1-P.grcr)-0.5;zeros(size(mdf.mehit))]).*0.81).*val.ones; %HW
    2.*val.ones;                                                       %J
    ...
    6.*val.ones;                                                       %HammerNova
    (8.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*val.ones];                %seal (SotR+J) 
rot(3).cps=rot(3).ncasts./repmat((18+1.5.*rot(3).xtragcd).*val.ones,size(rot(3).ncasts,1),1);
rot(3).coeff=rot(3).ncasts./repmat((18+1.5.*rot(3).xtragcd).*val.ones,size(rot(3).ncasts,1),1);
rot(3).coeff(idx.sotr,:)=rot(3).coeff(idx.sotr,:).*rot(3).sotrfactor;



%% IHSC9 : Inq>SotR*>HotR*>CS>J>AS>Cons>HW (execute range: ?)
rot(4).tag='IHSC9';
rot(4).xtragcd=(1./mdf.mehit)-1;
rot(4).sotrfactor=mdf.memodel.*(mdf.phcrit+mdf.mehit.*mdf.sd2.*(mdf.phcritm-mdf.phcrit)).*target.resrdx;
rot(4).ncasts=[...
    1.*val.ones;                                                       %Inq
    0.*val.ones;                                                       %2SotR
    1.*val.ones;                                                       %SotR
    0.*val.ones;                                                       %WoG
    ...
    3.*val.ones;                                                       %CS
    3.*val.ones;                                                       %HotR
    ...
    (2.*P.grcr.*0.81).*val.ones;                                       %AS
    (0.5.*0.81).*val.ones;                                             %Cons
    (2.*0.19).*val.ones;                                               %HoW
    (max([2.*(1-P.grcr)-0.5;zeros(size(mdf.mehit))]).*0.81).*val.ones; %HW
    2.*val.ones;                                                       %J
    ...
    3.*val.ones;                                                       %HammerNova
    (7.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*val.ones];                %seal (CS+SotR+J)
rot(4).cps=rot(4).ncasts./repmat((18+1.5.*rot(4).xtragcd).*val.ones,size(rot(4).ncasts,1),1);
rot(4).coeff=rot(4).ncasts./repmat((18+1.5.*rot(4).xtragcd).*val.ones,size(rot(4).ncasts,1),1);
rot(4).coeff(idx.sotr,:)=rot(4).coeff(idx.sotr,:).*rot(4).sotrfactor;
rot(4).InqMod=rot(4).InqMod+0.3.*[val.zeros;val.ones;val.ones;val.zeros;val.zeros;val.zeros;0.5.*val.ones;0.5.*val.ones;0.5.*val.ones;0.5.*val.ones;0.5.*val.ones;val.ones;(2.*mdf.mehit+mdf.rahit.*mdf.jseals)./(4.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*val.ones]; %uptime depends on ability
rot(4).InqUp=rot(4).InqUp+0.3.*(12./(18+1.5.*rot(4).xtragcd)).*val.ones;


%% IHIHSC9 framework SDSotR*>Inq>HotR*>CS>J>AS>Cons>HW (?) (cast SotR only on SD)
%I have no idea if my guess at the queue is correct.
%with no points in Sacred Duty, the framework is reduced to ICSH
rot(5).tag='IHIHSC';
rot(5).xtragcd=(1./mdf.mehit)-1;
if mdf.SacDut>0
rot(5).sotrfactor=mdf.memodel.*(mdf.phcrit+mdf.mehit.*(mdf.phcritm-mdf.phcrit)).*target.resrdx;
rot(5).ncasts=[...
    (1./mdf.sd2).*val.ones;                                                                    %Inq
    0.*val.ones;                                                            	               %2SotR
    1.*val.ones;                                                                               %SotR
    0.*val.ones;                                                                               %WoG
    ...
    3.*val.ones;                                                                               %CS
    (3./mdf.sd2).*val.ones;                                                                    %HotR
    ...
    (P.grcr.*0.81.*(1+mdf.sd2)./mdf.sd2).*val.ones;                                            %AS
    (0.25.*0.81.*(1+mdf.sd2)./mdf.sd2).*val.ones;                                              %Cons
    (0.19.*(1+mdf.sd2)./mdf.sd2).*val.ones;                                                    %HoW
    (max([(2.*(1-P.grcr)-0.5).*(1+mdf.sd2)./mdf.sd2;zeros(size(mdf.mehit))]).*0.81).*val.ones; %HW
    ((1+mdf.sd2)./mdf.sd2).*val.ones;                                                          %J
    ...
    (3./mdf.sd2).*val.ones;                                                                    %HammerNova
    (7.*mdf.mehit+((1+mdf.sd2)./mdf.sd2).*mdf.rahit.*mdf.jseals).*val.ones];                   %seal (CS+SotR+J)
rot(5).InqMod=rot(5).InqMod+0.3.*[val.zeros;val.ones;val.ones;val.zeros;val.zeros;val.zeros;0.5./mdf.sd2.*val.ones;0.5./mdf.sd2.*val.ones;0.5./mdf.sd2.*val.ones;0.5./mdf.sd2.*val.ones;0.5./mdf.sd2.*val.ones;val.ones;(2.*mdf.mehit+(1./mdf.sd2).*mdf.rahit.*mdf.jseals)./(4.*mdf.mehit+((1+mdf.sd2)./mdf.sd2).*mdf.rahit.*mdf.jseals).*val.ones]; %uptime depends on ability
rot(5).InqUp=rot(5).InqUp+0.3.*((12./mdf.sd2)./(9.*((1+mdf.sd2)./mdf.sd2)+1.5.*rot(5).xtragcd)).*val.ones;
else
rot(5).ncasts=rot(4).ncasts;
rot(5).sotrfactor=rot(4).sotrfactor;
rot(5).InqMod=rot(4).InqMod;
rot(5).InqUp=rot(4).InqUp;
end
rot(5).cps=rot(5).ncasts./repmat((18+1.5.*rot(5).xtragcd).*val.ones,size(rot(5).ncasts,1),1);
rot(5).coeff=rot(5).ncasts./repmat((18+1.5.*rot(5).xtragcd).*val.ones,size(rot(5).ncasts,1),1);
rot(5).coeff(idx.sotr,:)=rot(5).coeff(idx.sotr,:).*rot(5).sotrfactor;



%% IH9 framework (AoE) 
rot(6).tag='IH9';
rot(6).xtragcd=0;
rot(6).sotrfactor=1;
rot(6).ncasts=[...
    2.*val.ones;                                           	   %Inq
    0.*val.ones;                                  	           %2SotR
    0.*val.ones;                                               %SotR
    0.*val.ones;                                       	       %WoG
    ...
    0.*val.ones;                                               %CS
    6.*val.ones;                                               %HotR
    ...
    2.*P.grcr.*val.ones;                                       %AS
    0.5.*val.ones;                                             %Cons
    0.*val.ones;                                   	           %HoW
    max([2.*(1-P.grcr)-0.5;zeros(size(mdf.mehit))]).*val.ones; %HW
    2.*val.ones;                                               %J
    ...
    6.*val.ones;                                        	   %HammerNova
    (6.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*val.ones];        %seal         
rot(6).cps=rot(6).ncasts./18;
rot(6).coeff=rot(6).ncasts./repmat((18+1.5.*rot(6).xtragcd).*val.ones,size(rot(6).ncasts,1),1);
rot(6).coeff(idx.sotr,:)=rot(6).coeff(idx.sotr,:).*rot(6).sotrfactor;
rot(6).InqMod=rot(6).InqMod+0.3.*[val.zeros;val.ones;val.ones;val.zeros;val.zeros;val.zeros;val.ones;val.ones;val.ones;val.ones;val.ones;val.ones;val.ones];
rot(6).InqUp=rot(6).InqUp+0.3.*val.ones; %100% uptime


%% WC9 ("W39") framework
rot(7).tag='WC9';
rot(7).xtragcd=2.*(mdf.EG./(1+mdf.EG));
rot(7).sotrfactor=1;
rot(7).ncasts=[...
    0.*val.ones;                                                       %Inq
    0.*val.ones;                                                       %2SotR
    0.*val.ones;                                                       %SotR
    2.*(1+mdf.EG./(1+mdf.EG)).*val.ones;                               %WoG
    ...
    6.*val.ones;                                                       %CS
    0.*val.ones;                                                       %HotR
    ...
    (2.*P.grcr.*0.81).*val.ones;                                       %AS
    (0.5.*0.81).*val.ones;                                             %Cons
    (2.*0.19).*val.ones;                                               %HoW
    (max([2.*(1-P.grcr)-0.5;zeros(size(mdf.mehit))]).*0.81).*val.ones; %HW
    2.*val.ones;                                                  	   %J
    ...
    0.*val.ones;                                                       %HammerNova
    (6.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*val.ones];                %seal (CS+J) 
rot(7).cps=rot(7).ncasts./repmat((18+1.5.*rot(7).xtragcd).*val.ones,size(rot(7).ncasts,1),1);
rot(7).coeff=rot(7).ncasts./repmat((18+1.5.*rot(7).xtragcd).*val.ones,size(rot(7).ncasts,1),1);
rot(7).coeff(idx.sotr,:)=rot(7).coeff(idx.sotr,:).*rot(7).sotrfactor;


%% WH9 framework
rot(8).tag='WH9';
rot(8).xtragcd=2.*(mdf.EG./(1+mdf.EG));
rot(8).sotrfactor=1;
rot(8).ncasts=[...
    0.*val.ones;                                                       %Inq
    0.*val.ones;                                                       %2SotR
    0.*val.ones;                                                       %SotR
    2.*(1+mdf.EG./(1+mdf.EG)).*val.ones;                               %WoG
    ...
    0.*val.ones;                                                       %CS
    6.*val.ones;                                                       %HotR
    ...
    (2.*P.grcr.*0.81).*val.ones;                                       %AS
    (0.5.*0.81).*val.ones;                                             %Cons
    (2.*0.19).*val.ones;                                               %HoW
    (max([2.*(1-P.grcr)-0.5;zeros(size(mdf.mehit))]).*0.81).*val.ones; %HW
    2.*val.ones;                                                  	   %J
    ...
    6.*val.ones;                                                       %HammerNova
    (6.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*val.ones];                %seal (CS+J) 
rot(8).cps=rot(8).ncasts./repmat((18+1.5.*rot(8).xtragcd).*val.ones,size(rot(8).ncasts,1),1);
rot(8).coeff=rot(8).ncasts./repmat((18+1.5.*rot(8).xtragcd).*val.ones,size(rot(8).ncasts,1),1);
rot(8).coeff(idx.sotr,:)=rot(8).coeff(idx.sotr,:).*rot(8).sotrfactor;

%% output
for i=1:length(rot)
    if i~=6
        rot(i).acdps=[sum(rot(i).coeff.*rot(i).InqMod.*val.pdmg)];
        rot(i).achps=[sum(rot(i).coeff.*val.pheal)];
        rot(i).actps=[sum(rot(i).coeff.*rot(i).InqMod.*val.pthr)];
    else
        rot(i).acdps=[sum(rot(i).coeff.*rot(i).InqMod.*val.admg)];
        rot(i).achps=[sum(rot(i).coeff.*val.pheal)];
        rot(i).actps=[sum(rot(i).coeff.*rot(i).InqMod.*val.athr)];
    end
    if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
        rot(i).padps=rot(i).padps+dps.Censure.*rot(i).InqUp;
        rot(i).patps=rot(i).patps+tps.Censure.*rot(i).InqUp;
    end
    rot(i).padps=rot(i).padps+dps.Melee+dmg.activeseal.*mdf.mehit./player.wswing.*rot(i).InqUp;
    rot(i).pahps=rot(i).pahps+hps.Melee+heal.activeseal.*mdf.mehit./player.wswing;
    if strcmpi('Insight',exec.seal)||strcmpi('SoI',exec.seal)
        rot(i).patps=rot(i).patps+tps.Melee+threat.activeseal.*mdf.mehit./player.wswing;
    else
        rot(i).patps=rot(i).patps+tps.Melee+threat.activeseal.*mdf.mehit./player.wswing.*rot(i).InqUp;
    end
    rot(i).totdps=rot(i).acdps+rot(i).padps;
    rot(i).tothps=rot(i).achps+rot(i).pahps;
    rot(i).tottps=rot(i).actps+rot(i).patps;
end


clear p q tmprot mmmm P i idx