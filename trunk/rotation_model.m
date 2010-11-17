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
rot.xtragcd=1./mdf.mehit-1;

p=1-(1-mdf.GC).^3;q=1-p;
cols(1,:)=[1 0];
for mmmm=2:50;temp=p*cols(mmmm-1,1)+cols(mmmm-1,2);cols(mmmm,:)=[temp 1-temp];end;
P=mean(cols(length(cols)-1:length(cols),1));

rot.val.ones=ones(size(mdf.mehit));
rot.labels={'SotR';'CS';'J';'AS';'HW';'Cons';'HotR';'2SotR';'Inq';'Seal';'HaNova';'HoW'};
%% HW>Cons
rot.numcasts=[2.*(mdf.phcrit+mdf.mehit.*mdf.SacDut.*(mdf.phcritm-mdf.phcrit));... %SotR
    6.*rot.val.ones;...                                            %CS
    2.*rot.val.ones;...                                            %J
    2*P.*rot.val.ones;...                                          %AS
    max([2*(1-P); 0]).*rot.val.ones;...                            %HW
    0.*rot.val.ones;...                                            %Cons
    0.*rot.val.ones;...                                            %HotR
    0.*rot.val.ones;...                                            %2ShoR
    0.*rot.val.ones;...                                            %Inq
    0.*rot.val.ones;...                                            %HoW
    8.*mdf.mehit+2.*mdf.rahit.*mdf.jseals.*rot.val.ones;...        %seal (CS+SotR+J)
    0.*rot.val.ones];                                              %HammerNova

%% Cons>HW
rot1=rot;
rot1.numcasts=[2.*(mdf.phcrit+mdf.mehit.*mdf.SacDut.*(mdf.phcritm-mdf.phcrit));... %SotR
    6.*rot.val.ones;...                                            %CS
    2.*rot.val.ones;...                                            %J
    2*P.*rot.val.ones;...                                          %AS
    max([2*(1-P)-0.5; 0]).*rot.val.ones;...                        %HW
    0.5.*rot.val.ones;...                                          %Cons
    0.*rot.val.ones;...                                            %HotR
    0.*rot.val.ones;...                                            %2ShoR
    0.*rot.val.ones;...                                            %Inq
    0.*rot.val.ones;...                                            %HoW
    8.*mdf.mehit+2.*mdf.rahit.*mdf.jseals.*rot.val.ones;...        %seal (CS+SotR+J)
    0.*rot.val.ones];                                              %HammerNova

rot.coeff=rot.numcasts./repmat((18+1.5.*2.*rot.xtragcd),size(rot.numcasts,1),1);
rot1.coeff=rot1.numcasts./repmat((18+1.5.*2.*rot.xtragcd),size(rot1.numcasts,1),1);

rot.acdps=sum(rot.coeff'*pridmg);
rot1.acdps=sum(rot1.coeff'*pridmg);

rot.padps=0;
rot1.padps=0;
if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
    rot.padps=rot.padps+dps.Censure;
    rot1.padps=rot1.padps+dps.Censure;
end

%aa and seal damage
rot.padps=rot.padps+dps.Melee+dmg.activeseal.*mdf.mehit./player.wswing;
rot1.padps=rot1.padps+dps.Melee+dmg.activeseal.*mdf.mehit./player.wswing;

rot.totdps=rot.acdps+rot.padps;
rot1.totdps=rot1.acdps+rot1.padps;

%Inq handling
rot.Inq=0;
rot1.Inq=0;

%coeffs for ability damage sim - will implement later
% if length(rot.val.ones)==1
%     rot.admgcoeffs=(rot.numcasts+[0 0 0 0 0 0.5 6 0 0 0 6 0]')./(18+1.5.*2.*rot.xtragcd);
% end

%% Alternative rotation with HotR instead of CS
rot2.numcasts=[2.*(mdf.phcrit+mdf.mehit.*mdf.SacDut.*(mdf.phcritm-mdf.phcrit));... %SotR
    0.*rot.val.ones;...                                            %CS
    2.*rot.val.ones;...                                            %J
    2*P.*rot.val.ones;...                                          %AS
    max([2*(1-P)-0.5; 0]).*rot.val.ones;...                        %HW
    0.5.*rot.val.ones;...                                          %Cons
    6.*rot.val.ones;...                                            %HotR
    0.*rot.val.ones;...                                            %2ShoR
    0.*rot.val.ones;...                                            %Inq
    0.*rot.val.ones;...                                            %HoW
    2.*mdf.mehit+2.*mdf.rahit.*mdf.jseals.*rot.val.ones;...        %seal (SotR+J)
    6.*rot.val.ones];                                              %HammerNova

rot2.coeff=rot2.numcasts./repmat((18+1.5.*2.*rot.xtragcd),size(rot2.numcasts,1),1);
rot2.acdps=sum(rot2.coeff'*pridmg);

rot2.padps=0;
if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
    rot2.padps=rot2.padps+dps.Censure;
end

%aa and seal damage
rot2.padps=rot2.padps+dps.Melee+dmg.activeseal.*mdf.mehit./player.wswing;

rot2.totdps=rot2.acdps+rot2.padps;

%Inq handling
rot2.Inq=0;

%% AoE rotation - assuming we replace CS with HotR and cast Cons every 36s
aoe.Inq=(base.lvl==85);
aoe.Inqmod=(1+0.3.*aoe.Inq).*[1 0 1 1 1 1 0 1 0 1 1 1]';
aoe.numcasts=[0.*rot.val.ones;...                                     %SotR
              0.*rot.val.ones;...                                     %CS
              2.*rot.val.ones;...                                     %J
              2*P.*rot.val.ones;...                                   %AS
              max([2*(1-P)-0.5; 0]).*rot.val.ones;...                 %HW
              0.5.*rot.val.ones;...                                   %Cons
              6.*rot.val.ones;...                                     %HotR
              0.*rot.val.ones;...                                     %2SotR
              2.*rot.val.ones;...                                     %Inq
              0.*rot.val.ones;...                                     %HoW
              6.*mdf.mehit+2.*mdf.rahit.*mdf.jseals.*rot.val.ones;... %seal
              6.*rot.val.ones];                                       %HammerNova
          
aoe.coeff=aoe.numcasts./18;          
aoe.acdps=sum((aoe.coeff.*repmat(aoe.Inqmod,1,size(aoe.coeff,2)))'*pridmg);

aoe.padps=0;
if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
    aoe.padps=aoe.padps+dps.Censure;
end

%aa and seal damage
aoe.padps=aoe.padps+dps.Melee+dmg.activeseal.*mdf.mehit./player.wswing;

aoe.totdps=aoe.acdps+aoe.padps;


