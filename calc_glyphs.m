%%CALC_TALENTS calculates DPS output in a variety of different talent
%%configurations to determine DPS per talent point spent

%% Setup tasks
clear;
gear_db;
def_db;


base=player_model('lvl',80,'race','Human','prof','');
npc=npc_model(base);
gear_sample
exec=execution_model('npccount',1,'timein',1,'timeout',1,'seal','Truth');
buff=buff_model('mode',1);


%% set up our glyph configurations

%base - unpossible build, contains all relevant glyphs
tempglyph.prime=[1 1 1 1 1 1 1];
tempglyph.major=[0 1 0 0 1 0 0 1 0 0];

gtree(1)=tempglyph;
name{1}='Base';

%Crusader Strike
k=2;
gtree(k)=gtree(1);
gtree(k).prime(1)=0;
name{k}='CS';

%Hammer of the Righteous
k=k+1;
gtree(k)=gtree(1);
gtree(k).prime(3)=0;
name{k}='HotR';

%Judgement
k=k+1;
gtree(k)=gtree(1);
gtree(k).prime(4)=0;
name{k}='J';

%Seal of Truth
k=k+1;
gtree(k)=gtree(1);
gtree(k).prime(5)=0;
name{k}='SoT';

%Shield of the Righteous
k=k+1;
gtree(k)=gtree(1);
gtree(k).prime(6)=0;
name{k}='SotR';

%Cons
k=k+1;
gtree(k)=gtree(1);
gtree(k).major(2)=0;
name{k}='Cons';

%AS
k=k+1;
gtree(k)=gtree(1);
gtree(k).major(5)=0;
name{k}='AS';


%% sim 

%Calculate a sequence for this build, we'll use this sequence for all of
%the talents that don't have a direct effect on the rotation 
%(i.e. all but GC).
clear glyph
glyph=gtree(1);
%invoke talents & glyphs
talents
%calculate relevant stats
gear_stats
gear.exp=99;consum.exp=0;
%calculate final stats
stat_model
ability_model
prio_model
rot.consflag=1;
rotation_model

%run sim
% seq1=prio_sim(10,'N',90000);
%or not
seq1=rot;
seq2=aoe;


%active DPS
acdps(1)=sum(pridmg.*seq1.coeff);
acdps2(1)=sum(pridmg.*seq2.coeff);
      
%calculate passive damage sources
padps(1)=0;
padps2(1)=0;
%account for Inq
Inqmod=sum(seq1.Inq>0)./length(seq1.Inq);
Inqmod2=sum(seq2.Inq>0)./length(seq2.Inq);

%assume a 5-stack of SoT (if applicable).
if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
    padps(1)=padps(1)+dps.Censure.*(1+0.3.*Inqmod);
    padps2(1)=padps2(1)+dps.Censure.*(1+0.3.*Inqmod2);
end

%aa and seal damage
padps(1)=padps(1)+dps.Melee+dmg.activeseal.*mdf.mehit.*(1+0.3.*Inqmod)./player.wswing;
padps2(1)=padps2(1)+dps.Melee+dmg.activeseal.*mdf.mehit.*(1+0.3.*Inqmod2)./player.wswing;

%now calculate total DPS
totdps(1)=acdps(1)+padps(1);
totdps2(1)=acdps2(1)+padps2(1);
tabledps(1,:)=[totdps totdps];

% for m=2:length(tree)-2  %everything except GC & SD
for m=2:length(gtree) %everything
   

    clear glyph
    glyph=gtree(m);
    %invoke talents & glyphs
    talents
    %calculate relevant stats
    gear_stats
    gear.exp=99;consum.exp=0;
    %calculate final stats
    stat_model
    ability_model
    rotation_model;
    seq1=rot;
    seq2=aoe;
    
    
    %active dps
    acdps(m)=sum(pridmg.*seq1.coeff);
    acdps2(m)=sum(pridmg.*seq2.coeff);
    padps(m)=0;
    padps2(m)=0;
    %account for Inq
    Inqmod=sum(seq1.Inq>0)./length(seq1.Inq);
    Inqmod2=sum(seq2.Inq>0)./length(seq2.Inq);

    %assume a 5-stack of SoT (if applicable).
    if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
        padps(m)=padps(m)+dps.Censure.*(1+0.3.*Inqmod);
        padps2(m)=padps2(m)+dps.Censure.*(1+0.3.*Inqmod2);

    end

    %aa and seal damage
    padps(m)=padps(m)+dps.Melee+dmg.activeseal.*mdf.mehit.*(1+0.3.*Inqmod)./player.wswing;
    padps2(m)=padps2(m)+dps.Melee+dmg.activeseal.*mdf.mehit.*(1+0.3.*Inqmod2)./player.wswing;

    totdps(m)=acdps(m)+padps(m);
    totdps2(m)=acdps2(m)+padps2(m);
    
    if strcmp(name(m),'HotR')
        tabledps(m,:)=[totdps2(1) totdps2(m)];
    else
        tabledps(m,:)=[totdps(1) totdps(m)];
    end
    
end


dpspg=-diff(tabledps')';

%% table output
[char(name) repmat(' ',length(name),5) num2str(dpspg,'%2.1f')]


%% plots
figure(40)
set(gcf,'Position',[428 92 568 414])
bar20=barh(dpspg(2:length(dpspg)),'BarWidth',0.5,'BarLayout','stacked');
% set(bar20(2),'FaceColor',[0.749 0.749 0]);
ylim([0.5 7.5])
set(gca,'YTickLabel',name(2:length(name)))
% legend('Unglyphed','Glyphed','Location','NorthEast')
xlabel('DPS')
% ylabel('Damage')

%sorted
[dpspgsorted ind]=sort(dpspg);

figure(41)

set(gcf,'Position',[428 92 568 414])
bar20=barh(dpspgsorted(2:length(dpspg)),'BarWidth',0.5,'BarLayout','stacked');
% set(bar20(2),'FaceColor',[0.749 0.749 0]);
ylim([0.5 7.5])
set(gca,'YTickLabel',name(ind(2:length(name))))
% legend('Unglyphed','Glyphed','Location','NorthEast')
xlabel('DPS')