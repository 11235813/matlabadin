%% Sample Rotation module
%939 is simple enough that we can model it analytically, which makes a lot
%of things faster.
%Assume fixed rotation of 
% CS-J-CS-AS-CS-ShoR-
% CS-J-CS-X-CS-ShoR- (repeat)

%This cycle is 18 seconds, plus time to account for ShoR misses
%In that time, we get 
%6 CS
%2 J
%1 AS
%2 ShoR
%1 "X" that could be AS, HW, or potentially Cons

%set to 1 if you want to cast Cons in slot X (max once every 4th X,
%regardless of glyph)
if exist('rot')==0 || isfield(rot,'consflag')==0
    rot.consflag=0;
end

tempn=[1:15];
rot.xtragcd=mdf.mehit.*sum(tempn.*(1-mdf.mehit).^(tempn-1))-1;

p=1-(1-mdf.GC).^3;q=1-p;
cols(1,:)=[1 0];
for mmmm=2:50;temp=p*cols(mmmm-1,1)+cols(mmmm-1,2);cols(mmmm,:)=[temp 1-temp];end;
P=mean(cols(length(cols)-1:length(cols),1));

rot.numcasts=[2.*(mdf.phcrit+mdf.mehit.*mdf.SacDut.*(mdf.phcritmulti-mdf.phcrit));... %ShoR
    6;...                                            %CS
    2;...                                            %J
    2*P;...                                          %AS
    max([2*(1-P)-0.5.*rot.consflag; 0]);...          %HW
    0.5.*rot.consflag;...                            %Cons
    0;...                                            %HotR
    0;...                                            %2ShoR
    0;...                                            %Inq
    6.*mdf.mehit+2.*mdf.rahit.*(mdf.JotJ>0);...      %seal
    0];                                             %hammer nova

rot.coeff=rot.numcasts./(18+1.5.*2.*rot.xtragcd);
rot.acdps=sum(pridmg.*rot.coeff);

rot.padps=0;
if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
    rot.padps=rot.padps+dps.Censure;
end

%aa and seal damage
rot.padps=rot.padps+dps.Melee+dmg.activeseal.*mdf.mehit./player.wswing;

rot.totdps=rot.acdps+rot.padps;

%Inq handling
rot.Inq=0;


%% AoE rotation - assuming we replace CS with HotR and cast Cons every 36s

aoe.Inq=1; %keep this up at all times
aoe.Inqmod=(1+0.3.*aoe.Inq).*[1 0 1 1 1 1 0 1 0 1 1]';
aoe.numcasts=[0;...   
              0;...
              2;...
              2*P;...
              max([2*(1-P)-0.5; 0]);...          %HW
              0.5;...                            %Cons
              6;...                                            %HotR
              0;...                                            %2ShoR
              2;...                                            %Inq
              6.*mdf.mehit+2.*mdf.rahit.*(mdf.JotJ>0);...      %seal
              6];                                             %hammer nova
          
aoe.coeff=aoe.numcasts./18;          
aoe.acdps=sum(pridmg.*aoe.coeff.*aoe.Inqmod);

aoe.padps=0;
if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
    aoe.padps=aoe.padps+dps.Censure;
end

%aa and seal damage
aoe.padps=aoe.padps+dps.Melee+dmg.activeseal.*mdf.mehit./player.wswing;

aoe.totdps=aoe.acdps+aoe.padps;


