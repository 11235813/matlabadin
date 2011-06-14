%PRIO_CALC generates and stores the necessary data to compare different
%priority queues

%% preload all appropriate variables - damage values don't matter
clear;
gear_db;
def_db;
base=player_model('race','Human');
npc=npc_model(base);
exec=execution_model('npccount',1,'timein',1,'timeout',1,'seal','SoT','veng',1);
buff=buff_model;
egs=ddb.gearset{2};  %1=pre-raid , 2=raid
talent=ddb.talentset{1}; %0/31/10, no HG
glyph=ddb.glyphset{4}; %Default, SoT/ShoR/(HotR & CS), Cons/AS
gear_stats
talents

stat_model

%artificially inflating hit and expertise to 8% and 26
gear.hit=8*cnv.hit_phhit;
gear.exp=(26-10-base.exp)*cnv.exp_exp;
stat_model

ability_model
prio_model;

%% Generate coefficients for each priority queue
N=30000;  %# GCDs, set long enough to get stochastic data for each sim
dt=1.5;
wb=waitbar(0,'Calculating');
tic
for k=1:k1
    
    waitbar(k/k1,wb)
    rdata(k)=prio_sim(k,'N',N,'dt',dt);
    
end
close(wb)
toc

%% construct coefficient matrix
for m=1:length(rdata)
    cmat(m,:)=rdata(m).coeff;
end


%% save for later use (good for generic stuff, saves computation time)
save prio_data cmat rdata

%% incorporate non-GCD damage sources
clear li padps1 padps2
for m=1:length(rdata)
    padps1(m)=0;
    %account for Inq
    Inqmod=sum(rdata(m).Inq>0)./length(rdata(m).Inq);
    
    %assume a 5-stack of SoT (if applicable).
    if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
        padps1(m)=padps1(m)+dps.Censure.*(1+0.3.*Inqmod);
    
    end
    
    %aa and seal damage
	padps1(m)=padps1(m)+dps.Melee+dmg.activeseal.*mdf.mehit.*(1+0.3.*Inqmod)./player.wswing;
end
pridmg1=pridmg;

%repeat for low vengeance
exec=execution_model('npccount',1,'timein',1,'timeout',1,'seal','SoT','veng',0.3);
stat_model
ability_model
pridmg2=pridmg;
for m=1:length(rdata)
    padps2(m)=0;
    %account for Inq
    Inqmod=sum(rdata(m).Inq>0)./length(rdata(m).Inq);
    
    %assume a 5-stack of SoT (if applicable).
    if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
        padps2(m)=padps2(m)+dps.Censure.*(1+0.3.*Inqmod);
    
    end
    
    %aa and seal damage
	padps2(m)=padps2(m)+dps.Melee+dmg.activeseal.*mdf.mehit.*(1+0.3.*Inqmod)./player.wswing;
end
%% construct damage arrays
% pridmg  =[raw.ShieldoftheRighteous;dmg.CrusaderStrike;dmg.Judgement;...
%           dmg.AvengersShield;dmg.HolyWrath;dmg.Consecration;...
%           dmg.HammeroftheRighteous;dmg.ShieldoftheRighteous./2; ...  
%           0;dmg.activeseal;dmg.HammerNova];      

% %alternative vector for skipping Consecration damage
% altdmg  =[raw.ShieldoftheRighteous;dmg.CrusaderStrike;dmg.Judgement;...
%           dmg.AvengersShield;dmg.HolyWrath;0;...
%           dmg.HammeroftheRighteous;dmg.ShieldoftheRighteous./2; ...  
%           0;dmg.activeseal;dmg.HammerNova];
      
%check for consecrations that turn into empties
% for m=1:length(rdata);conscasts(m)=sum(rdata(m).castid==6);end;

%build name array
for m=1:length(rdata);name{m,:}=rdata(m).name;end

%calculate empty %
% for m=1:length(rdata);temp=find(rdata(m).castid==0);epct(m)=100.*(sum(rdata(m).casttime(temp+1)-rdata(m).casttime(temp)))./rdata(m).totaltime;end;
spacer=repmat(' ',length(rdata),3);
li=[spacer int2str([1:length(rdata)]') spacer char(name) spacer int2str(cmat*pridmg1+padps1') ...
    spacer int2str(cmat*pridmg2+padps2') spacer int2str([rdata.empties]') spacer num2str([rdata.emptypct]','%3.1f') ...
    spacer int2str([rdata.smiss]') spacer int2str([rdata.ascast]')];
% for m=1:length(rdata)
%     li(m,:)=[int2str(m) repmat(' ',1,4-length(int2str(m))) rdata(m).name ...
%         repmat(' ',1,45-length(rdata(m).name))  int2str(int32(rdata(m).dps+padps(m))) ...
%         repmat(' ',1,8-length(int2str(rdata(m).empties))) int2str(rdata(m).empties) ...
%         repmat(' ',1,8-length(num2str(rdata(m).empties*100./length(rdata(m).castid),'%2.2f'))) num2str(rdata(m).empties*100./length(rdata(m).castid),'%2.2f')];
% end
li
