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
if isfield('rot','consflag')==0
    rot.consflag=0;
end

tempn=[1:15];
rot.xtragcd=mdf.mehit.*sum(tempn.*(1-mdf.mehit).^(tempn-1))-1;

p=1-(1-mdf.GC).^3;q=1-p;
cols(1,:)=[1 0];
for m=2:50;temp=p*cols(m-1,1)+cols(m-1,2);cols(m,:)=[temp 1-temp];end;
P=cols(length(cols),1);

rot.numcasts=[2.*(1+mdf.mehit.*mdf.SacDut.*(mdf.phcritmulti./mdf.phcrit-1));... %ShoR
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

rot.coeff=rot.numcasts./(18+1.5.*rot.xtragcd);
rot.acdps=sum(pridmg.*rot.coeff);

rot.padps=0;
if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
    rot.padps=rot.padps+dps.Censure;
end

%aa and seal damage
rot.padps=rot.padps+dps.Melee+dmg.activeseal.*mdf.mehit./player.wswing;

rot.totdps=rot.acdps+rot.padps

