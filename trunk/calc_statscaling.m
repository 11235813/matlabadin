%CALC_STATSCALING calculates the scaling of our abilites with different
%stats



%The construction of this module is that we have a coefficient matrix
%(cmat) which is an NxM matrix of ability coefficients Cij for each of the
%M abilities in N different rotations.  We thus want to construct an MxL
%matrix (adam) of damage values for the M abilities as they scale with a
%particular stat (L different values).  If we matrix multiply cmat*adam, we
%get an NxL matrix containing the DPS values for each rotation as it scales
%with that stat.
%
%When using rotation_model, cmat is 1xM, which simplifies a lot of things.


%% construct adam
clear;
gear_db;
def_db;

% lvl 85
base=player_model('race','Human','prof','');
npc=npc_model(base);
% glyph=ddb.glyphset{1}; %no glyphs
talent=ddb.talentset{1};  %0/31/10
egs=ddb.gearset{2};
%execution
exec=execution_model('npccount',1,'timein',1,'timeout',1,'seal','Truth','veng',0.8);
%activate buffs
buff=buff_model('mode',3);
%invoke talents & glyphs
talents
%calculate relevant stats
gear_stats
%adjustments to make sure that nothing is capped
gear.hit=min([gear.hit; 150.*ones(size(gear.hit))]);
gear.exp=min([gear.exp; 90.*ones(size(gear.exp))]);
gear.mast=min([gear.mast; 400.*ones(size(gear.mast))]);

%calculate final stats
stat_model
ability_model
rotation_model


stat={'exp';'hit';'str';'crit';'ap';'sta';'agi';'haste';'mas';'sp';'int'};
M=length(stat);  %number of "extra" stats

dstat=[10 10 20 10 10 20 10 10 10 10 10];


%% Strength graph

%reset extra structure
extra_init;
extra.val.str=-100+[1:2:1500];


for m=1:M
    %set each stat to dstat extra
    eval(char(['extra.itm.' stat{m} '=dstat(m);']))

    stat_model;ability_model;rotation_model;

    dps1s(m,:)=rot.coeff'*pridmg+rot.padps;
    dps1s2(m,:)=rot2.coeff'*pridmg+rot2.padps;    
    
    
    %set each stat back to 0 extra
    eval(char(['extra.itm.' stat{m} '=0;']))

    stat_model;ability_model;rotation_model;

    dps0s(m,:)=rot.coeff'*pridmg+rot.padps;
    dps0s2(m,:)=rot2.coeff'*pridmg+rot2.padps;

end
diffdpsS=(dps1s-dps0s).*10./repmat(dstat',1,size(dps1s,2));
diffdpsS2=(dps1s2-dps0s2).*10./repmat(dstat',1,size(dps1s2,2));
xS=player.armorystr';

figure(50)
set(gcf,'Position',[290    92   706   414])
plot(xS,diffdpsS')
xlim([min(player.armorystr) max(player.armorystr)])
legend(stat,'Location','NorthEast')
xlabel('Armory Strength')
ylabel('DPS per 10 itemization points')

%% Hit graph
%reset extra structure
extra_init;
extra.val.hit=-max(gear.hit)+0:round(10.*cnv.hit_phhit);
for m=1:M
    %set each stat to dstat extra
    eval(char(['extra.itm.' stat{m} '=dstat(m);']))

    stat_model;ability_model;rotation_model;

    dps1h(m,:)=sum(rot.coeff.*pridmg)+rot.padps;
    dps1h2(m,:)=sum(rot2.coeff.*pridmg)+rot2.padps;
    
    %set each stat back to 0 extra
    eval(char(['extra.itm.' stat{m} '=0;']))

    stat_model;ability_model;rotation_model;
    
    dps0h(m,:)=sum(rot.coeff.*pridmg)+rot.padps;
    dps0h2(m,:)=sum(rot2.coeff.*pridmg)+rot2.padps;

end
diffdpsH=(dps1h-dps0h).*10./repmat(dstat',1,size(dps1h,2));
diffdpsH2=(dps1h2-dps0h2).*10./repmat(dstat',1,size(dps1h2,2));
xH=player.phhit';

figure(51)
set(gcf,'Position',[290    92   706   414])
plot(xH,diffdpsH')
xlim([min(player.phhit) max(player.phhit)])
legend(stat,'Location','NorthEast')
xlabel('Melee hit % against lvl 80')
ylabel('DPS per 10 itemization points')


%% Exp graph
%reset extra structure
extra_init;
extra.val.exp=-max(gear.exp)+0:round(45.*cnv.exp_exp);
for m=1:M
    %set each stat to dstat extra
    eval(char(['extra.itm.' stat{m} '=dstat(m);']))

    stat_model;ability_model;rotation_model;

    dps1e(m,:)=sum(rot.coeff.*pridmg)+rot.padps;
    dps1e2(m,:)=sum(rot2.coeff.*pridmg)+rot2.padps;
    
    %set each stat back to 0 extra
    eval(char(['extra.itm.' stat{m} '=0;']))

    stat_model;ability_model;rotation_model;

    dps0e(m,:)=sum(rot.coeff.*pridmg)+rot.padps;
    dps0e2(m,:)=sum(rot2.coeff.*pridmg)+rot2.padps;

end
diffdpsE=(dps1e-dps0e).*10./repmat(dstat',1,size(dps1e,2));
diffdpsE2=(dps1e2-dps0e2).*10./repmat(dstat',1,size(dps1e2,2));
xE=player.exp';

figure(52)
set(gcf,'Position',[290    92   706   414])
plot(xE,diffdpsE')
xlim([min(player.exp) max(player.exp)])
legend(stat,'Location','NorthEast')
xlabel('Expertise skill')
ylabel('DPS per 10 itemization points')


%% HotR Plots


figure(60)
set(gcf,'Position',[290    92   706   414])
plot(xS,diffdpsS2')
xlim([min(xS) max(xS)])
legend(stat,'Location','NorthEast')
xlabel('Armory Strength')
ylabel('DPS per 10 itemization points')

figure(61)
set(gcf,'Position',[290    92   706   414])
plot(xH,diffdpsH2')
xlim([min(xH) max(xH)])
legend(stat,'Location','NorthEast')
xlabel('Melee hit % against lvl 80')
ylabel('DPS per 10 itemization points')

figure(62)
set(gcf,'Position',[290    92   706   414])
plot(xE,diffdpsE2')
xlim([min(xE) max(xE)])
legend(stat,'Location','NorthEast')
xlabel('Expertise skill')
ylabel('DPS per 10 itemization points')
