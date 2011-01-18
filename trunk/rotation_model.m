%% Rotation module

%initialize structure
rot=struct('tag','', ...
           'labels',{'SotR';'CS';'J';'AS';'HW';'Cons';'HotR';'2SotR';'Inq';'Seal';'HaNova';'HoW';'WoG'}, ...
           'val',[], ...
           'xtragcd',[], ...
           'sotrfactor',[], ...
           'ncasts',[], ...
           'cps',[], ...
           'InqMod',[], ...
           'InqUp',[], ...
           'acdps',[], ...
           'actps',[], ...
           'padps',[], ...
           'patps',[], ...
           'totdps',[], ...
           'tottps',[]);

%fix entries
for i=1:7
    rot(i).labels={'SotR';'CS';'J';'AS';'HW';'Cons';'HotR';'2SotR';'Inq';'Seal';'HaNova';'HoW';'WoG'};
    rot(i).val.ones=ones(1,max([length(mdf.mehit) length(val.ones)]));
    rot(i).val.zeros=zeros(1,max([length(mdf.mehit) length(val.zeros)]));
    rot(i).xtragcd=zeros(1,max([length(mdf.mehit) length(val.zeros)]));
    rot(i).sotrfactor=ones(1,max([length(mdf.mehit) length(val.ones)]));
    rot(i).InqMod=ones(13,max([length(mdf.mehit) length(val.ones)]));
    rot(i).InqUp=ones(1,max([length(mdf.mehit) length(val.ones)]));
    rot(i).padps=zeros(1,max([length(mdf.mehit) length(val.zeros)]));
    rot(i).patps=zeros(1,max([length(mdf.mehit) length(val.zeros)]));
end

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
%average AS cast count
clear tmprot
tmprot.CScols(1,:)=ones(size(q.CS));
tmprot.HotRcols(1,:)=ones(size(q.HotR));
for mmmm=2:50
tmprot.CScols(mmmm,:)=p.CS.*tmprot.CScols(mmmm-1,:)+(1-tmprot.CScols(mmmm-1,:));
tmprot.HotRcols(mmmm,:)=p.HotR.*tmprot.HotRcols(mmmm-1,:)+(1-tmprot.HotRcols(mmmm-1,:));
end
P.CS=mean(tmprot.CScols(size(tmprot.CScols,1)-1:size(tmprot.CScols,1),:));
P.HotR=mean(tmprot.HotRcols(size(tmprot.HotRcols,1)-1:size(tmprot.HotRcols,1),:));

%initialize var for storing effective casts
tmpc=[];


%% SCSC framework : SotR>CS>J>AS>Cons>HW (execute range : SotR>CS>J>HoW)
rot(1).tag='SCSC';
rot(1).xtragcd=2.*((1./mdf.mehit)-1);
rot(1).sotrfactor=(mdf.phcrit+mdf.mehit.*mdf.sd1.*(mdf.phcritm-mdf.phcrit));
rot(1).ncasts=[2.*rot(1).val.ones;...                                          %SotR
    6.*rot(1).val.ones;...                                                     %CS
    2.*rot(1).val.ones;...                                                     %J
    (2.*P.CS.*0.81).*rot(1).val.ones;...                                       %AS
    (max([2.*(1-P.CS)-0.5;zeros(size(mdf.mehit))]).*0.81).*rot(1).val.ones;... %HW
    (0.5.*0.81).*rot(1).val.ones;...                                           %Cons
    rot(1).val.zeros;...                                                       %HotR
    rot(1).val.zeros;...                                                       %2SotR
    rot(1).val.zeros;...                                                       %Inq
    (2.*0.19).*rot(1).val.ones;...                                             %HoW
    (8.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*rot(1).val.ones;...               %seal (CS+SotR+J)
    rot(1).val.zeros;                                                          %HammerNova
    rot(1).val.zeros];                                                         %WoG
rot(1).cps=rot(1).ncasts./repmat((18+1.5.*rot(1).xtragcd).*rot(1).val.ones,size(rot(1).ncasts,1),1);
tmpc{1}=rot(1).ncasts;tmpc{1}(1,:)=tmpc{1}(1,:).*rot(1).sotrfactor;
tmpc{1}=tmpc{1}./repmat((18+1.5.*rot(1).xtragcd).*rot(1).val.ones,size(rot(1).ncasts,1),1);


%% IHSH framework : Inq>SotR>HotR>J>AS>Cons>HW (execute range : Inq>SotR>HotR>J>HoW)
rot(2).tag='IHSH';
rot(2).xtragcd=(1./mdf.mehit)-1;
rot(2).sotrfactor=(mdf.phcrit+mdf.mehit.*mdf.sd2.*(mdf.phcritm-mdf.phcrit));
rot(2).ncasts=[1.*rot(2).val.ones;...                         %SotR
    rot(2).val.zeros;...                                      %CS
    2.*rot(2).val.ones;...                                    %J
    (2.*P.HotR.*0.81).*rot(2).val.ones;...                    %AS
    (max([2.*(1-P.HotR)-0.5;0]).*0.81).*rot(2).val.ones;...   %HW
    (0.5.*0.81).*rot(2).val.ones;...                          %Cons
    6.*rot(2).val.ones;...                                    %HotR
    rot(2).val.zeros;...                                      %2SotR
    1.*rot(2).val.ones;...                                    %Inq
    (2.*0.19).*rot(2).val.ones;...                            %HoW
    (mdf.mehit+2.*mdf.rahit.*mdf.jseals).*rot(2).val.ones;... %seal (SotR+J)
    6.*rot(2).val.ones;                                       %HammerNova
    rot(2).val.zeros];                                        %WoG
rot(2).cps=rot(2).ncasts./repmat((18+1.5.*rot(2).xtragcd).*rot(2).val.ones,size(rot(2).ncasts,1),1);
tmpc{2}=rot(2).ncasts;tmpc{2}(1,:)=tmpc{2}(1,:).*rot(2).sotrfactor;
tmpc{2}=tmpc{2}./repmat((18+1.5.*rot(2).xtragcd).*rot(2).val.ones,size(rot(2).ncasts,1),1);
rot(2).InqMod=rot(2).InqMod+0.3.*[rot(2).val.ones;rot(2).val.zeros;0.5.*rot(2).val.ones;0.5.*rot(2).val.ones;0.5.*rot(2).val.ones;0.5.*rot(2).val.ones;rot(2).val.zeros;rot(2).val.zeros;rot(2).val.zeros;0.5.*rot(2).val.ones;(mdf.mehit+mdf.rahit.*mdf.jseals)./(mdf.mehit+2.*mdf.rahit.*mdf.jseals).*rot(2).val.ones;4./6.*rot(2).val.ones;rot(2).val.zeros]; %uptime depends on ability
rot(2).InqUp=rot(2).InqUp+0.3.*(12./(18+1.5.*rot(2).xtragcd)).*rot(2).val.ones;


%% SHSH framework
rot(3).tag='SHSH';
rot(3).xtragcd=2.*((1./mdf.mehit)-1);
rot(3).sotrfactor=(mdf.phcrit+mdf.mehit.*mdf.sd1.*(mdf.phcritm-mdf.phcrit));
rot(3).ncasts=[2.*rot(3).val.ones;...                            %SotR
    rot(3).val.zeros;...                                         %CS
    2.*rot(3).val.ones;...                                       %J
    (2.*P.HotR.*0.81).*rot(3).val.ones;...                       %AS
    (max([2.*(1-P.HotR)-0.5;0]).*0.81).*rot(3).val.ones;...      %HW
    (0.5.*0.81).*rot(3).val.ones;...                             %Cons
    6.*rot(3).val.ones;...                                       %HotR
    rot(3).val.ones;...                                          %2SotR
    rot(3).val.ones;...                                          %Inq
    (2.*0.19).*rot(3).val.ones;...                               %HoW
    (2.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*rot(3).val.ones;... %seal (SotR+J)
    6.*rot(3).val.ones;                                          %HammerNova
    rot(3).val.zeros];                                           %WoG
rot(3).cps=rot(3).ncasts./repmat((18+1.5.*rot(3).xtragcd).*rot(3).val.ones,size(rot(3).ncasts,1),1);
tmpc{3}=rot(3).ncasts;tmpc{3}(1,:)=tmpc{3}(1,:).*rot(3).sotrfactor;
tmpc{3}=tmpc{3}./repmat((18+1.5.*rot(3).xtragcd).*rot(3).val.ones,size(rot(3).ncasts,1),1);


%% ICSH (cast SotR independently of SD)
rot(4).tag='ICSH';
rot(4).xtragcd=(1./mdf.mehit)-1;
rot(4).sotrfactor=(mdf.phcrit+mdf.mehit.*mdf.sd2.*(mdf.phcritm-mdf.phcrit));
rot(4).ncasts=[1.*rot(4).val.ones;...                                            %SotR
    3.*rot(4).val.ones;...                                                       %CS
    2.*rot(4).val.ones;...                                                       %J
    ((P.CS+P.HotR).*0.81).*rot(4).val.ones;...                                   %AS
    (max([2-P.CS-P.HotR-0.5;zeros(size(mdf.mehit))]).*0.81).*rot(4).val.ones;... %HW
    (0.5.*0.81).*rot(4).val.ones;...                                             %Cons
    3.*rot(4).val.ones;...                                                       %HotR
    rot(4).val.zeros;...                                                         %2SotR
    1.*rot(4).val.ones;...                                                       %Inq
    (2.*0.19).*rot(4).val.ones;...                                               %HoW
    (4.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*rot(4).val.ones;...                 %seal (CS+SotR+J)
    3.*rot(4).val.ones;                                                          %HammerNova
    rot(4).val.zeros];                                                           %WoG
rot(4).cps=rot(4).ncasts./repmat((18+1.5.*rot(4).xtragcd).*rot(4).val.ones,size(rot(4).ncasts,1),1);
tmpc{4}=rot(4).ncasts;tmpc{4}(1,:)=tmpc{4}(1,:).*rot(4).sotrfactor;
tmpc{4}=tmpc{4}./repmat((18+1.5.*rot(4).xtragcd).*rot(4).val.ones,size(rot(4).ncasts,1),1);
rot(4).InqMod=rot(4).InqMod+0.3.*[rot(4).val.ones;rot(4).val.zeros;0.5.*rot(4).val.ones;0.5.*rot(4).val.ones;0.5.*rot(4).val.ones;0.5.*rot(4).val.ones;rot(4).val.zeros;rot(4).val.zeros;rot(4).val.zeros;0.5.*rot(4).val.ones;(2.*mdf.mehit+mdf.rahit.*mdf.jseals)./(4.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*rot(4).val.ones;rot(4).val.ones;rot(4).val.zeros]; %uptime depends on ability
rot(4).InqUp=rot(4).InqUp+0.3.*(12./(18+1.5.*rot(4).xtragcd)).*rot(4).val.ones;


%% ICIHSH framework (cast SotR only on SD)
%with no points in Sacred Duty, the framework is reduced to ICSH
rot(5).tag='ICIHSH';
rot(5).xtragcd=(1./mdf.mehit)-1;
if mdf.SacDut>0
rot(5).sotrfactor=(mdf.phcrit+mdf.mehit.*(mdf.phcritm-mdf.phcrit));
rot(5).ncasts=[1.*rot(5).val.ones;...                                                 %SotR
    3.*rot(5).val.ones;...                                                            %CS
    ((1+mdf.sd2)./mdf.sd2).*rot(5).val.ones;...                                       %J
    ((P.CS+P.HotR./mdf.sd2).*0.81).*rot(5).val.ones;...                               %AS
    (max([0.75.*((1+mdf.sd2)./mdf.sd2)-(P.CS+P.HotR./mdf.sd2);zeros(size(mdf.mehit))]).*0.81).*rot(5).val.ones;... %HW
    (0.25.*((1+mdf.sd2)./mdf.sd2).*0.81).*rot(5).val.ones;...                         %Cons
    (3./mdf.sd2).*rot(5).val.ones;...                                                 %HotR
    rot(5).val.zeros;...                                                              %2SotR
    (1./mdf.sd2).*rot(5).val.ones;...                                                 %Inq
    (((1+mdf.sd2)./mdf.sd2).*0.19).*rot(5).val.ones;...                               %HoW
    (4.*mdf.mehit+((1+mdf.sd2)./mdf.sd2).*mdf.rahit.*mdf.jseals).*rot(5).val.ones;... %seal (CS+SotR+J)
    (3./mdf.sd2).*rot(5).val.ones;                                                    %HammerNova
    rot(5).val.zeros];                                                                %WoG
rot(5).InqMod=rot(5).InqMod+0.3.*[rot(5).val.ones;rot(5).val.zeros;0.5./mdf.sd2.*rot(5).val.ones;0.5./mdf.sd2.*rot(5).val.ones;0.5./mdf.sd2.*rot(5).val.ones;0.5./mdf.sd2.*rot(5).val.ones;rot(5).val.zeros;rot(5).val.zeros;rot(5).val.zeros;0.5./mdf.sd2.*rot(5).val.ones;(2.*mdf.mehit+(1./mdf.sd2).*mdf.rahit.*mdf.jseals)./(4.*mdf.mehit+((1+mdf.sd2)./mdf.sd2).*mdf.rahit.*mdf.jseals).*rot(5).val.ones;rot(5).val.ones;rot(5).val.zeros]; %uptime depends on ability
rot(5).InqUp=rot(5).InqUp+0.3.*((12./mdf.sd2)./(9.*((1+mdf.sd2)./mdf.sd2)+1.5.*rot(5).xtragcd)).*rot(5).val.ones;
else
rot(5).ncasts=rot(4).ncasts;
rot(5).sotrfactor=rot(4).sotrfactor;
rot(5).InqMod=rot(4).InqMod;
rot(5).InqUp=rot(4).InqUp;
end
rot(5).cps=rot(5).ncasts./repmat((18+1.5.*rot(5).xtragcd).*rot(5).val.ones,size(rot(5).ncasts,1),1);
tmpc{5}=rot(5).ncasts;tmpc{5}(1,:)=tmpc{5}(1,:).*rot(5).sotrfactor;
tmpc{5}=tmpc{5}./repmat((18+1.5.*rot(5).xtragcd).*rot(5).val.ones,size(rot(5).ncasts,1),1);


%% IHIH framework (AoE)
rot(6).tag='IHIH';
rot(6).xtragcd=0;
rot(6).sotrfactor=1;
rot(6).ncasts=[rot(6).val.zeros;...                                        %SotR
              rot(6).val.zeros;...                                         %CS
              2.*rot(6).val.ones;...                                       %J
              2.*P.HotR.*rot(6).val.ones;...                               %AS
              max([2.*(1-P.HotR)-0.5;0]).*rot(6).val.ones;...              %HW
              0.5.*rot(6).val.ones;...                                     %Cons
              6.*rot(6).val.ones;...                                       %HotR
              rot(6).val.zeros;...                                         %2SotR
              2.*rot(6).val.ones;...                                       %Inq
              rot(6).val.zeros;...                                         %HoW
              (2.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*rot(6).val.ones;... %seal
              6.*rot(6).val.ones;                                          %HammerNova
              rot(6).val.zeros];                                           %WoG
rot(6).cps=rot(6).ncasts./18;
tmpc{6}=rot(6).ncasts;tmpc{6}(1,:)=tmpc{6}(1,:).*rot(6).sotrfactor;
tmpc{6}=tmpc{6}./repmat((18+1.5.*rot(6).xtragcd).*rot(6).val.ones,size(rot(6).ncasts,1),1);
rot(6).InqMod=rot(6).InqMod+0.3.*[rot(6).val.ones;rot(6).val.zeros;rot(6).val.ones;rot(6).val.ones;rot(6).val.ones;rot(6).val.ones;rot(6).val.zeros;rot(6).val.ones;rot(6).val.zeros;rot(6).val.ones;rot(6).val.ones;rot(6).val.ones;rot(6).val.zeros];
rot(6).InqUp=rot(6).InqUp+0.3.*rot(6).val.ones; %100% uptime


%% WCWC framework
rot(7).tag='WCWC';
rot(7).xtragcd=2.*(mdf.EG./(1+mdf.EG));
rot(7).sotrfactor=1;
rot(7).ncasts=[rot(7).val.zeros;...                                            %SotR
    6.*rot(7).val.ones;...                                                     %CS
    2.*rot(7).val.ones;...                                                     %J
    (2.*P.CS.*0.81).*rot(7).val.ones;...                                       %AS
    (max([2.*(1-P.CS)-0.5;zeros(size(mdf.mehit))]).*0.81).*rot(7).val.ones;... %HW
    (0.5.*0.81).*rot(1).val.ones;...                                           %Cons
    rot(7).val.zeros;...                                                       %HotR
    rot(7).val.zeros;...                                                       %2SotR
    rot(7).val.zeros;...                                                       %Inq
    (2.*0.19).*rot(7).val.ones;...                                             %HoW
    (6.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*rot(7).val.ones;...               %seal (CS+J)
    rot(7).val.zeros;                                                          %HammerNova
    2.*(1+mdf.EG./(1+mdf.EG)).*rot(7).val.ones];                               %WoG
rot(7).cps=rot(7).ncasts./repmat((18+1.5.*rot(7).xtragcd).*rot(7).val.ones,size(rot(7).ncasts,1),1);
tmpc{7}=rot(7).ncasts;tmpc{7}(1,:)=tmpc{7}(1,:).*rot(7).sotrfactor;
tmpc{7}=tmpc{7}./repmat((18+1.5.*rot(7).xtragcd).*rot(7).val.ones,size(rot(7).ncasts,1),1);


%% output
for i=1:7
    if i~=6
        rot(i).acdps=[sum(tmpc{i}.*rot(i).InqMod.*val.pdmg)];
        rot(i).actps=[sum(tmpc{i}.*rot(i).InqMod.*val.pthr)];
    else
        rot(i).acdps=[sum(tmpc{i}.*rot(i).InqMod.*val.admg)];
        rot(i).actps=[sum(tmpc{i}.*rot(i).InqMod.*val.athr)];
    end
    if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
        rot(i).padps=rot(i).padps+dps.Censure.*rot(i).InqUp;
        rot(i).patps=rot(i).patps+tps.Censure.*rot(i).InqUp;
    end
    rot(i).padps=rot(i).padps+dps.Melee+dmg.activeseal.*mdf.mehit./player.wswing.*rot(i).InqUp;
    if strcmpi('Insight',exec.seal)||strcmpi('SoI',exec.seal)
        rot(i).patps=rot(i).patps+tps.Melee+threat.activeseal.*mdf.mehit./player.wswing;
    else
        rot(i).patps=rot(i).patps+tps.Melee+threat.activeseal.*mdf.mehit./player.wswing.*rot(i).InqUp;
    end
    rot(i).totdps=rot(i).acdps+rot(i).padps;
    rot(i).tottps=rot(i).actps+rot(i).patps;
end


% coeffs for ability damage sim - will implement later (maybe?)
% if length(rot.val.ones)==1
%     rot.admgcoeffs=(rot.numcasts+[0 0 0 0 0 0.5 6 0 0 0 6 0]')./(18+1.5.*2.*rot.xtragcd);
% end

clear mmmm tmpc i