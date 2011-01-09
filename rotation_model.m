%% Sample Rotation module
%939 is simple enough that we can model it analytically, which makes a lot
%of things faster.
%Assume fixed rotation of 
% CS-J-CS-AS-CS-SotR-
% CS-J-CS-X-CS-SotR- (repeat)

%This cycle is 18 seconds, plus time to account for ShoR misses
%In that time, we get 
%6 CS
%2 J
%1 AS
%2 SotR
%1 "X" that could be AS, HW, or potentially Cons

%extra GCD cost of missed SotR
rot.xtragcd=(1./mdf.mehit)-1;

%probability of SD proc from one J cast
mdf.sd1=mdf.rahit.*mdf.SacDut;
%probability of at least one SD proc from two J casts
mdf.sd2=mdf.rahit.*mdf.SacDut.*(2-mdf.rahit.*mdf.SacDut);

%probability of at least one GrCr proc from 3 CS/HotR casts
q.CS=binopdf(0,3,mdf.mehit) ...                  %no connects
    +binopdf(1,3,mdf.mehit).*(1-mdf.GrCr) ...    %one connects, no proc
    +binopdf(2,3,mdf.mehit).*(1-mdf.GrCr).^2 ... %two connects, no procs
    +binopdf(3,3,mdf.mehit).*(1-mdf.GrCr).^3;    %three connects, no procs
p.CS=1-q.CS;
q.HotR=(1-mdf.GrCr).^3;
p.HotR=1-q.HotR;
%compute average AS cast count
% cols(1,:,1)=[1 0];cols(1,:,2)=[1 0];
% for mmmm=2:50
% tmprot.CS=p.CS.*cols(mmmm-1,1,1)+cols(mmmm-1,2,1);cols(mmmm,:,1)=[tmprot.CS 1-tmprot.CS];
% tmprot.HotR=p.HotR.*cols(mmmm-1,1,2)+cols(mmmm-1,2,2);cols(mmmm,:,2)=[tmprot.HotR 1-tmprot.HotR];
% end
clear tmprot
tmprot.CScols(1,:)=ones(size(q.CS));
tmprot.HotRcols(1,:)=ones(size(q.HotR));
for mmmm=2:50
tmprot.CScols(mmmm,:)=p.CS.*tmprot.CScols(mmmm-1,:)+(1-tmprot.CScols(mmmm-1,:));
tmprot.HotRcols(mmmm,:)=p.HotR.*tmprot.HotRcols(mmmm-1,:)+(1-tmprot.HotRcols(mmmm-1,:));
end
P.CS=mean(tmprot.CScols(size(tmprot.CScols,1)-1:size(tmprot.CScols,1),:));
P.HotR=mean(tmprot.HotRcols(size(tmprot.HotRcols,1)-1:size(tmprot.HotRcols,1),:));

rot.val.ones=ones(1,max([length(mdf.mehit) length(val.ones)]));
rot.val.zeros=zeros(1,max([length(mdf.mehit) length(val.zero)]));
rot.labels={'SotR';'CS';'J';'AS';'HW';'Cons';'HotR';'2SotR';'Inq';'Seal';'HaNova';'HoW'};


%% SotR>CS>J>AS>Cons>HW (execute range : SotR>CS>J>HoW)
rot.numcasts=[2.*(mdf.phcrit+mdf.mehit.*mdf.sd1.*(mdf.phcritm-mdf.phcrit)).*rot.val.ones;... %SotR
    6.*rot.val.ones;...                                                     %CS
    2.*rot.val.ones;...                                                     %J
    (2.*P.CS.*0.81).*rot.val.ones;...                                       %AS
    (max([2.*(1-P.CS)-0.5;zeros(size(mdf.mehit))]).*0.81).*rot.val.ones;... %HW
    (0.5.*0.81).*rot.val.ones;...                                           %Cons
    0.*rot.val.ones;...                                                     %HotR
    0.*rot.val.ones;...                                                     %2SotR
    0.*rot.val.ones;...                                                     %Inq
    (2.*0.19).*rot.val.ones;...                                             %HoW
    (8.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*rot.val.ones;...               %seal (CS+SotR+J)
    0.*rot.val.ones];                                                       %HammerNova

%% Inq>SotR>HotR>J>AS>Cons>HW (execute range : Inq>SotR>HotR>J>HoW)
rot1=rot;
rot1.numcasts=[1.*(mdf.phcrit+mdf.mehit.*mdf.sd2.*(mdf.phcritm-mdf.phcrit)).*rot.val.ones;... %SotR
    0.*rot.val.ones;...                                    %CS
    2.*rot.val.ones;...                                    %J
    (2.*P.HotR.*0.81).*rot.val.ones;...                    %AS
    (max([2.*(1-P.HotR)-0.5;0]).*0.81).*rot.val.ones;...   %HW
    (0.5.*0.81).*rot.val.ones;...                          %Cons
    6.*rot.val.ones;...                                    %HotR
    0.*rot.val.ones;...                                    %2SotR
    1.*rot.val.ones;...                                    %Inq
    (2.*0.19).*rot.val.ones;...                            %HoW
    (mdf.mehit+2.*mdf.rahit.*mdf.jseals).*rot.val.ones;... %seal (SotR+J)
    6.*rot.val.ones];                                      %HammerNova

%% Alternative rotation with HotR instead of CS
rot2=rot;
rot2.numcasts=[2.*(mdf.phcrit+mdf.mehit.*mdf.sd1.*(mdf.phcritm-mdf.phcrit)).*rot.val.ones;... %SotR
    0.*rot.val.ones;...                                       %CS
    2.*rot.val.ones;...                                       %J
    (2.*P.HotR.*0.81).*rot.val.ones;...                       %AS
    (max([2.*(1-P.HotR)-0.5;0]).*0.81).*rot.val.ones;...      %HW
    (0.5.*0.81).*rot.val.ones;...                             %Cons
    6.*rot.val.ones;...                                       %HotR
    0.*rot.val.ones;...                                       %2SotR
    0.*rot.val.ones;...                                       %Inq
    (2.*0.19).*rot.val.ones;...                               %HoW
    (2.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*rot.val.ones;... %seal (SotR+J)
    6.*rot.val.ones];                                         %HammerNova

%% Inq/SDSotR weaving (CS in Inq blocks, HotR in SotR blocks, cast SotR disregarding SD)
rot3=rot;
rot3.numcasts=[1.*(mdf.phcrit+mdf.mehit.*mdf.sd2.*(mdf.phcritm-mdf.phcrit)).*rot.val.ones;... %SotR
    3.*rot.val.ones;...                                                        %CS
    2.*rot.val.ones;...                                                        %J
    ((P.CS+P.HotR).*0.81).*rot.val.ones;...                                    %AS
    (max([2-P.CS-P.HotR-0.5;zeros(size(mdf.mehit))]).*0.81).*rot.val.ones;...  %HW
    (0.5.*0.81).*rot.val.ones;...                                              %Cons
    3.*rot.val.ones;...                                                        %HotR
    0.*rot.val.ones;...                                                        %2SotR
    1.*rot.val.ones;...                                                        %Inq
    (2.*0.19).*rot.val.ones;...                                                %HoW
    (4.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*rot.val.ones;...                  %seal (CS+SotR+J)
    3.*rot.val.ones];                                                          %HammerNova

%% Inq/SDSotR weaving (CS in Inq blocks, HotR in SotR blocks, cast SotR only on SD)
rot4=rot;
rot4.numcasts=[1.*(mdf.phcrit+mdf.mehit.*(mdf.phcritm-mdf.phcrit)).*rot.val.ones;... %SotR
    3.*rot.val.ones;...                                                            %CS
    ((1+mdf.sd2)./mdf.sd2).*rot.val.ones;...                                       %J
    ((P.CS+P.HotR./mdf.sd2).*0.81).*rot.val.ones;...                               %AS
    (max([0.75.*((1+mdf.sd2)./mdf.sd2)-(P.CS+P.HotR./mdf.sd2);zeros(size(mdf.mehit))]).*0.81).*rot.val.ones;... %HW
    (0.25.*((1+mdf.sd2)./mdf.sd2).*0.81).*rot.val.ones;...                         %Cons
    (3./mdf.sd2).*rot.val.ones;...                                                 %HotR
    0.*rot.val.ones;...                                                            %2SotR
    (1./mdf.sd2).*rot.val.ones;...                                                 %Inq
    (((1+mdf.sd2)./mdf.sd2).*0.19).*rot.val.ones;...                               %HoW
    (4.*mdf.mehit+((1+mdf.sd2)./mdf.sd2).*mdf.rahit.*mdf.jseals).*rot.val.ones;... %seal (CS+SotR+J)
    (3./mdf.sd2).*rot.val.ones];                                                   %HammerNova

%% AoE rotation - assuming we replace CS with HotR and cast Cons every 36s
aoe=rot;
aoe.numcasts=[0.*rot.val.ones;...                                       %SotR
              0.*rot.val.ones;...                                       %CS
              2.*rot.val.ones;...                                       %J
              2.*P.HotR.*rot.val.ones;...                               %AS
              max([2.*(1-P.HotR)-0.5;0]).*rot.val.ones;...              %HW
              0.5.*rot.val.ones;...                                     %Cons
              6.*rot.val.ones;...                                       %HotR
              0.*rot.val.ones;...                                       %2SotR
              2.*rot.val.ones;...                                       %Inq
              0.*rot.val.ones;...                                       %HoW
              (2.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*rot.val.ones;... %seal
              6.*rot.val.ones];                                         %HammerNova

%% Postprocessing

%Inq handling
rot.Inq=0;

rot1.Inq=(base.lvl==85);
rot1.Inqmod=(1+0.3.*rot1.Inq.*[1.*rot.val.ones;0.*rot.val.ones;0.5.*rot.val.ones;0.5.*rot.val.ones;0.5.*rot.val.ones;0.5.*rot.val.ones;0.*rot.val.ones;0.*rot.val.ones;0.*rot.val.ones;0.5.*rot.val.ones;(mdf.mehit+mdf.rahit.*mdf.jseals)./(mdf.mehit+2.*mdf.rahit.*mdf.jseals).*rot.val.ones;4./6.*rot.val.ones]); %uptime depends on ability
rot1.InqUp=(1+0.3.*rot1.Inq.*(12./(18+1.5.*rot.xtragcd)).*rot.val.ones);

rot2.Inq=0;

rot3.Inq=(base.lvl==85);
rot3.Inqmod=(1+0.3.*rot3.Inq.*[1.*rot.val.ones;0.*rot.val.ones;0.5.*rot.val.ones;0.5.*rot.val.ones;0.5.*rot.val.ones;0.5.*rot.val.ones;0.*rot.val.ones;0.*rot.val.ones;0.*rot.val.ones;0.5.*rot.val.ones;(2.*mdf.mehit+mdf.rahit.*mdf.jseals)./(4.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*rot.val.ones;1.*rot.val.ones]); %uptime depends on ability
rot3.InqUp=(1+0.3.*rot3.Inq.*(12./(18+1.5.*rot.xtragcd)).*rot.val.ones);

rot4.Inq=(base.lvl==85);
rot4.Inqmod=(1+0.3.*rot4.Inq.*[1.*rot.val.ones;0.*rot.val.ones;0.5./mdf.sd2.*rot.val.ones;0.5./mdf.sd2.*rot.val.ones;0.5./mdf.sd2.*rot.val.ones;0.5./mdf.sd2.*rot.val.ones;0.*rot.val.ones;0.*rot.val.ones;0.*rot.val.ones;0.5./mdf.sd2.*rot.val.ones;(2.*mdf.mehit+(1./mdf.sd2).*mdf.rahit.*mdf.jseals)./(4.*mdf.mehit+((1+mdf.sd2)./mdf.sd2).*mdf.rahit.*mdf.jseals).*rot.val.ones;1.*rot.val.ones]); %uptime depends on ability
rot4.InqUp=(1+0.3.*rot4.Inq.*((12./mdf.sd2)./(9.*((1+mdf.sd2)./mdf.sd2)+1.5.*rot.xtragcd)).*rot.val.ones);

aoe.Inq=(base.lvl==85);
aoe.Inqmod=(1+0.3.*aoe.Inq.*[1.*rot.val.ones;0.*rot.val.ones;1.*rot.val.ones;1.*rot.val.ones;1.*rot.val.ones;1.*rot.val.ones;0.*rot.val.ones;1.*rot.val.ones;0.*rot.val.ones;1.*rot.val.ones;1.*rot.val.ones;1.*rot.val.ones]);
aoe.InqUp=(1+0.3.*aoe.Inq.*rot.val.ones); %100% uptime

%Generate weighting coefficients (# casts per second)
rot.coeff=rot.numcasts./repmat((18+1.5.*2.*rot.xtragcd).*rot.val.ones,size(rot.numcasts,1),1);
rot1.coeff=rot1.numcasts.*rot1.Inqmod./repmat((18+1.5.*rot.xtragcd).*rot.val.ones,size(rot1.numcasts,1),1);
rot2.coeff=rot2.numcasts./repmat((18+1.5.*2.*rot.xtragcd).*rot.val.ones,size(rot2.numcasts,1),1);
rot3.coeff=rot3.numcasts.*rot3.Inqmod./repmat((18+1.5.*rot.xtragcd).*rot.val.ones,size(rot3.numcasts,1),1);
rot4.coeff=rot4.numcasts.*rot4.Inqmod./repmat((9.*((1+mdf.sd2)./mdf.sd2)+1.5.*rot.xtragcd).*rot.val.ones,size(rot4.numcasts,1),1);
aoe.coeff=aoe.numcasts.*aoe.Inqmod./18;    

%Active DPS component is the weighted average of pridmg according to coeff
% (# casts per second)*(dmg per cast) = (dmg per second due to active srcs)
rot.acdps=[sum(rot.coeff.*pridmg)];
rot1.acdps=[sum(rot1.coeff.*pridmg)];
rot2.acdps=[sum(rot2.coeff.*pridmg)];
rot3.acdps=[sum(rot3.coeff.*pridmg)];
rot4.acdps=[sum(rot4.coeff.*pridmg)];
aoe.acdps=[sum(aoe.coeff.*aoedmg)];
%and threat //TODO
rot.actps=0;
rot1.actps=0;
rot2.actps=0;
rot3.actps=0;
rot4.actps=0;
aoe.actps=0;

%Initialize passive DPS/TPS
rot.padps=0;rot.patps=0;
rot1.padps=0;rot1.patps=0;
rot2.padps=0;rot2.patps=0;
rot3.padps=0;rot3.patps=0;
rot4.padps=0;rot4.patps=0;
aoe.padps=0;aoe.patps=0;

%add Censure
if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
    rot.padps=rot.padps+dps.Censure;rot.patps=rot.patps+tps.Censure;
    rot1.padps=rot1.padps+dps.Censure.*rot1.InqUp;rot1.patps=rot1.patps+tps.Censure.*rot1.InqUp;
    rot2.padps=rot2.padps+dps.Censure;rot2.patps=rot2.patps+tps.Censure;
    rot3.padps=rot3.padps+dps.Censure.*rot3.InqUp;rot3.patps=rot3.patps+tps.Censure.*rot3.InqUp;
    rot4.padps=rot4.padps+dps.Censure.*rot4.InqUp;rot4.patps=rot4.patps+tps.Censure.*rot4.InqUp;
    aoe.padps=aoe.padps+dps.Censure.*aoe.InqUp;aoe.patps=aoe.patps+tps.Censure.*aoe.InqUp;
end


%add AA+seal output
rot.padps=rot.padps+dps.Melee+dmg.activeseal.*mdf.mehit./player.wswing;
rot.patps=rot.patps+tps.Melee+threat.activeseal.*mdf.mehit./player.wswing;
rot1.padps=rot1.padps+dps.Melee+dmg.activeseal.*mdf.mehit./player.wswing.*rot1.InqUp;
rot1.patps=rot1.patps+tps.Melee+threat.activeseal.*mdf.mehit./player.wswing.*rot1.InqUp;
rot2.padps=rot2.padps+dps.Melee+dmg.activeseal.*mdf.mehit./player.wswing;
rot2.patps=rot2.patps+tps.Melee+threat.activeseal.*mdf.mehit./player.wswing;
rot3.padps=rot3.padps+dps.Melee+dmg.activeseal.*mdf.mehit./player.wswing.*rot3.InqUp;
rot3.patps=rot3.patps+tps.Melee+threat.activeseal.*mdf.mehit./player.wswing.*rot3.InqUp;
rot4.padps=rot4.padps+dps.Melee+dmg.activeseal.*mdf.mehit./player.wswing.*rot4.InqUp;
rot4.patps=rot4.patps+tps.Melee+threat.activeseal.*mdf.mehit./player.wswing.*rot4.InqUp;
aoe.padps=aoe.padps+dps.Melee+dmg.activeseal.*mdf.mehit./player.wswing.*aoe.InqUp;
aoe.patps=aoe.patps+tps.Melee+threat.activeseal.*mdf.mehit./player.wswing.*aoe.InqUp;

%total output
rot.totdps=rot.acdps+rot.padps;rot.tottps=rot.actps+rot.patps;
rot1.totdps=rot1.acdps+rot1.padps;rot1.tottps=rot1.actps+rot1.patps;
rot2.totdps=rot2.acdps+rot2.padps;rot2.tottps=rot2.actps+rot2.patps;
rot3.totdps=rot3.acdps+rot3.padps;rot3.tottps=rot3.actps+rot3.patps;
rot4.totdps=rot4.acdps+rot4.padps;rot4.tottps=rot4.actps+rot4.patps;
aoe.totdps=aoe.acdps+aoe.padps;aoe.tottps=aoe.actps+aoe.patps;

%coeffs for ability damage sim - will implement later (maybe?)
% if length(rot.val.ones)==1
%     rot.admgcoeffs=(rot.numcasts+[0 0 0 0 0 0.5 6 0 0 0 6 0]')./(18+1.5.*2.*rot.xtragcd);
% end

clear mmmm