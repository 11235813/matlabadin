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
           'actps',[], ...
           'padps',[], ...
           'patps',[], ...
           'totdps',[], ...
           'tottps',[]);

%fix entries
for i=1:7
    rot(i).labels={'SotR';'CS';'J';'AS';'HW';'Cons';'HotR';'2SotR';'Inq';'Seal';'HaNova';'HoW';'WoG'};
    rot(i).xtragcd=val.zeros;
    rot(i).sotrfactor=val.ones;
    rot(i).InqMod=ones(13,length(val.ones));
    rot(i).InqUp=val.ones;
    rot(i).padps=val.zeros;
    rot(i).patps=val.zeros;
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


%% SCSC/939 framework : SotR>CS>J>AS>Cons>HW (execute range : SotR>CS>J>HoW)
rot(1).tag='939';
rot(1).xtragcd=2.*((1./mdf.mehit)-1);
rot(1).sotrfactor=(mdf.phcrit+mdf.mehit.*mdf.sd1.*(mdf.phcritm-mdf.phcrit));
rot(1).ncasts=[...
    2.*val.ones;...                                                     %SotR
    6.*val.ones;...                                                     %CS
    2.*val.ones;...                                                     %J
   (2.*P.CS.*0.81).*val.ones;...                                        %AS
   (max([2.*(1-P.CS)-0.5;zeros(size(mdf.mehit))]).*0.81).*val.ones;...  %HW
   (0.5.*0.81).*val.ones;...                                            %Cons
    0.*val.ones;...                                                     %HotR
    0.*val.ones;...                                                     %2SotR
    0.*val.ones;...                                                     %Inq
   (2.*0.19).*val.ones;...                                              %HoW
   (8.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*val.ones;...                %seal (CS+SotR+J)
    0.*val.ones;                                                        %HammerNova
    0.*val.ones];                                                       %WoG
rot(1).cps=rot(1).ncasts./repmat((18+1.5.*rot(1).xtragcd).*val.ones,size(rot(1).ncasts,1),1);
rot(1).coeff=rot(1).ncasts./repmat((18+1.5.*rot(1).xtragcd).*val.ones,size(rot(1).ncasts,1),1);
rot(1).coeff(1,:)=rot(1).coeff(1,:).*rot(1).sotrfactor;


%% IHSH9 framework : Inq>SotR>HotR>J>AS>Cons>HW (execute range : Inq>SotR>HotR>J>HoW)
rot(2).tag='IHSH9';
rot(2).xtragcd=(1./mdf.mehit)-1;
rot(2).sotrfactor=(mdf.phcrit+mdf.mehit.*mdf.sd2.*(mdf.phcritm-mdf.phcrit));
rot(2).ncasts=[...
    1.*val.ones;...                                    %SotR
    0.*val.ones;...                                    %CS
    2.*val.ones;...                                    %J
   (2.*P.HotR.*0.81).*val.ones;...                     %AS
   (max([2.*(1-P.HotR)-0.5;0]).*0.81).*val.ones;...    %HW
   (0.5.*0.81).*val.ones;...                           %Cons
    6.*val.ones;...                                    %HotR
    0.*val.ones;...                                    %2SotR
    1.*val.ones;...                                    %Inq
   (2.*0.19).*val.ones;...                             %HoW
   (mdf.mehit+2.*mdf.rahit.*mdf.jseals).*val.ones;...  %seal (SotR+J)
    6.*val.ones;                                       %HammerNova
    0.*val.ones];                                      %WoG
rot(2).cps=rot(2).ncasts./repmat((18+1.5.*rot(2).xtragcd).*val.ones,size(rot(2).ncasts,1),1);
rot(2).coeff=rot(2).ncasts./repmat((18+1.5.*rot(2).xtragcd).*val.ones,size(rot(2).ncasts,1),1);
rot(2).coeff(1,:)=rot(2).coeff(1,:).*rot(2).sotrfactor;
rot(2).InqMod=rot(2).InqMod+0.3.*[val.ones;val.zeros;0.5.*val.ones;0.5.*val.ones;0.5.*val.ones;0.5.*val.ones;val.zeros;val.zeros;val.zeros;0.5.*val.ones;(mdf.mehit+mdf.rahit.*mdf.jseals)./(mdf.mehit+2.*mdf.rahit.*mdf.jseals).*val.ones;4./6.*val.ones;val.zeros]; %uptime depends on ability
rot(2).InqUp=rot(2).InqUp+0.3.*(12./(18+1.5.*rot(2).xtragcd)).*val.ones;


%% SH9 framework : SotR>HotR>J>AS>Cons>HW (execute range : SotR>HotR>J>HoW)
rot(3).tag='SH9';
rot(3).xtragcd=2.*((1./mdf.mehit)-1);
rot(3).sotrfactor=(mdf.phcrit+mdf.mehit.*mdf.sd1.*(mdf.phcritm-mdf.phcrit));
rot(3).ncasts=[ ...
    2.*val.ones;...                                         %SotR
    0.*val.ones;...                                         %CS
    2.*val.ones;...                                         %J
   (2.*P.HotR.*0.81).*val.ones;...                          %AS
   (max([2.*(1-P.HotR)-0.5;0]).*0.81).*val.ones;...         %HW
   (0.5.*0.81).*val.ones;...                                %Cons
    6.*val.ones;...                                         %HotR
    0.*val.ones;...                                         %2SotR
    0.*val.ones;...                                         %Inq
   (2.*0.19).*val.ones;...                                  %HoW
   (2.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*val.ones;...    %seal (SotR+J)
    6.*val.ones;                                            %HammerNova
    0.*val.ones];                                           %WoG
rot(3).cps=rot(3).ncasts./repmat((18+1.5.*rot(3).xtragcd).*val.ones,size(rot(3).ncasts,1),1);
rot(3).coeff=rot(3).ncasts./repmat((18+1.5.*rot(3).xtragcd).*val.ones,size(rot(3).ncasts,1),1);
rot(3).coeff(1,:)=rot(3).coeff(1,:).*rot(3).sotrfactor;



%% IHSC9 : Inq>SotR*>HotR*>CS>J>AS>Cons>HW (execute range: ?)
rot(4).tag='IHSC';
rot(4).xtragcd=(1./mdf.mehit)-1;
rot(4).sotrfactor=(mdf.phcrit+mdf.mehit.*mdf.sd2.*(mdf.phcritm-mdf.phcrit));
rot(4).ncasts=[...
    1.*val.ones;...                                                         %SotR
    3.*val.ones;...                                                         %CS
    2.*val.ones;...                                                         %J
   ((P.CS+P.HotR).*0.81).*val.ones;...                                      %AS
   (max([2-P.CS-P.HotR-0.5;zeros(size(mdf.mehit))]).*0.81).*val.ones;...    %HW
   (0.5.*0.81).*val.ones;...                                                %Cons
    3.*val.ones;...                                                         %HotR
    0.*val.ones;...                                                         %2SotR
    1.*val.ones;...                                                         %Inq
   (2.*0.19).*val.ones;...                                                  %HoW
   (4.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*val.ones;...                    %seal (CS+SotR+J)
    3.*val.ones;                                                            %HammerNova
    0.*val.ones];                                                           %WoG
rot(4).cps=rot(4).ncasts./repmat((18+1.5.*rot(4).xtragcd).*val.ones,size(rot(4).ncasts,1),1);
rot(4).coeff=rot(4).ncasts./repmat((18+1.5.*rot(4).xtragcd).*val.ones,size(rot(4).ncasts,1),1);
rot(4).coeff(1,:)=rot(4).coeff(1,:).*rot(4).sotrfactor;
rot(4).InqMod=rot(4).InqMod+0.3.*[val.ones;val.zeros;0.5.*val.ones;0.5.*val.ones;0.5.*val.ones;0.5.*val.ones;val.zeros;val.zeros;val.zeros;0.5.*val.ones;(2.*mdf.mehit+mdf.rahit.*mdf.jseals)./(4.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*val.ones;val.ones;val.zeros]; %uptime depends on ability
rot(4).InqUp=rot(4).InqUp+0.3.*(12./(18+1.5.*rot(4).xtragcd)).*val.ones;


%% ICIHSH framework Inq>SDSotR*>HotR*>CS>J>AS>Cons>HW (?)  (cast SotR only on SD)
%TODO: the naming scheme really breaks down for this one, I have no idea if my
%guess at the queue is correct.
%with no points in Sacred Duty, the framework is reduced to ICSH
rot(5).tag='ICIHSH';
rot(5).xtragcd=(1./mdf.mehit)-1;
if mdf.SacDut>0
rot(5).sotrfactor=(mdf.phcrit+mdf.mehit.*(mdf.phcritm-mdf.phcrit));
rot(5).ncasts=[...
    1.*val.ones;...                                                             %SotR
    3.*val.ones;...                                                             %CS
  ((1+mdf.sd2)./mdf.sd2).*val.ones;...                                          %J
  ((P.CS+P.HotR./mdf.sd2).*0.81).*val.ones;...                                  %AS
   (max([0.75.*((1+mdf.sd2)./mdf.sd2)-(P.CS+P.HotR./mdf.sd2);zeros(size(mdf.mehit))]).*0.81).*val.ones;... %HW
   (0.25.*((1+mdf.sd2)./mdf.sd2).*0.81).*val.ones;...                           %Cons
   (3./mdf.sd2).*val.ones;...                                                   %HotR
    0.*val.ones;...                                                            	%2SotR
   (1./mdf.sd2).*val.ones;...                                                   %Inq
 (((1+mdf.sd2)./mdf.sd2).*0.19).*val.ones;...                                   %HoW
   (4.*mdf.mehit+((1+mdf.sd2)./mdf.sd2).*mdf.rahit.*mdf.jseals).*val.ones;...   %seal (CS+SotR+J)
   (3./mdf.sd2).*val.ones;                                                      %HammerNova
    0.*val.ones];                                                               %WoG
rot(5).InqMod=rot(5).InqMod+0.3.*[val.ones;val.zeros;0.5./mdf.sd2.*val.ones;0.5./mdf.sd2.*val.ones;0.5./mdf.sd2.*val.ones;0.5./mdf.sd2.*val.ones;val.zeros;val.zeros;val.zeros;0.5./mdf.sd2.*val.ones;(2.*mdf.mehit+(1./mdf.sd2).*mdf.rahit.*mdf.jseals)./(4.*mdf.mehit+((1+mdf.sd2)./mdf.sd2).*mdf.rahit.*mdf.jseals).*val.ones;val.ones;val.zeros]; %uptime depends on ability
rot(5).InqUp=rot(5).InqUp+0.3.*((12./mdf.sd2)./(9.*((1+mdf.sd2)./mdf.sd2)+1.5.*rot(5).xtragcd)).*val.ones;
else
rot(5).ncasts=rot(4).ncasts;
rot(5).sotrfactor=rot(4).sotrfactor;
rot(5).InqMod=rot(4).InqMod;
rot(5).InqUp=rot(4).InqUp;
end
rot(5).cps=rot(5).ncasts./repmat((18+1.5.*rot(5).xtragcd).*val.ones,size(rot(5).ncasts,1),1);
rot(5).coeff=rot(5).ncasts./repmat((18+1.5.*rot(5).xtragcd).*val.ones,size(rot(5).ncasts,1),1);
rot(5).coeff(1,:)=rot(5).coeff(1,:).*rot(5).sotrfactor;



%% IH9? framework (AoE) 
%Are we casting Inq every 9 seconds here (i.e. Inq*>HotR>J>AS>Cons>HW)?  if
%not then this is one case where we "break" the 939 framework and move to
%something else
rot(6).tag='IH9';
rot(6).xtragcd=0;
rot(6).sotrfactor=1;
rot(6).ncasts=[0.*val.ones;...                                      %SotR
               0.*val.ones;...                                      %CS
               2.*val.ones;...                                      %J
               2.*P.HotR.*val.ones;...                              %AS
               max([2.*(1-P.HotR)-0.5;0]).*val.ones;...             %HW
               0.5.*val.ones;...                                    %Cons
               6.*val.ones;...                                      %HotR
               0.*val.ones;...                                  	%2SotR
               2.*val.ones;...                                   	%Inq
               0.*val.ones;...                                   	%HoW
              (2.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*val.ones;... %seal
               6.*val.ones;                                        	%HammerNova
               0.*val.ones];                                       	%WoG
rot(6).cps=rot(6).ncasts./18;
rot(6).coeff=rot(6).ncasts./repmat((18+1.5.*rot(6).xtragcd).*val.ones,size(rot(6).ncasts,1),1);
rot(6).coeff(1,:)=rot(6).coeff(1,:).*rot(6).sotrfactor;
rot(6).InqMod=rot(6).InqMod+0.3.*[val.ones;val.zeros;val.ones;val.ones;val.ones;val.ones;val.zeros;val.ones;val.zeros;val.ones;val.ones;val.ones;val.zeros];
rot(6).InqUp=rot(6).InqUp+0.3.*val.ones; %100% uptime


%% WC9 framework
rot(7).tag='W39';
rot(7).xtragcd=2.*(mdf.EG./(1+mdf.EG));
rot(7).sotrfactor=1;
rot(7).ncasts=[...
    0.*val.ones;...                                                     %SotR
    6.*val.ones;...                                                     %CS
    2.*val.ones;...                                                  	%J
   (2.*P.CS.*0.81).*val.ones;...                                        %AS
   (max([2.*(1-P.CS)-0.5;zeros(size(mdf.mehit))]).*0.81).*val.ones;...  %HW
   (0.5.*0.81).*val.ones;...                                            %Cons
    0.*val.ones;...                                                  	%HotR
    0.*val.ones;...                                                     %2SotR
    0.*val.ones;...                                                     %Inq
   (2.*0.19).*val.ones;...                                              %HoW
   (6.*mdf.mehit+2.*mdf.rahit.*mdf.jseals).*val.ones;...                %seal (CS+J)
    0.*val.ones;                                                       	%HammerNova
    2.*(1+mdf.EG./(1+mdf.EG)).*val.ones];                               %WoG
rot(7).cps=rot(7).ncasts./repmat((18+1.5.*rot(7).xtragcd).*val.ones,size(rot(7).ncasts,1),1);
rot(7).coeff=rot(7).ncasts./repmat((18+1.5.*rot(7).xtragcd).*val.ones,size(rot(7).ncasts,1),1);
rot(7).coeff(1,:)=rot(7).coeff(1,:).*rot(7).sotrfactor;


%% output
for i=1:length(rot)
    if i~=6
        rot(i).acdps=[sum(rot(i).coeff.*rot(i).InqMod.*val.pdmg)];
        rot(i).actps=[sum(rot(i).coeff.*rot(i).InqMod.*val.pthr)];
    else
        rot(i).acdps=[sum(rot(i).coeff.*rot(i).InqMod.*val.admg)];
        rot(i).actps=[sum(rot(i).coeff.*rot(i).InqMod.*val.athr)];
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


clear mmmm tmpc i