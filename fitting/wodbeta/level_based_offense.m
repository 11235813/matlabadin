clear
load level_based_off.mat

matchstr='(?<level>\d+)\+?,\sM(?<miss>\d+\.\d)\sD(?<dodge>\d+\.\d)\sP(?<parry>\d+\.\d)\sG(?<glance>\d+\.\d)\sB(?<block>\d+\.\d)';
for i=1:length(level_based_off)
    
    textline=level_based_off{i};
    names = regexp(textline, matchstr,'names');
    
    level(i)=str2num(names.level);
    miss(i)=str2num(names.miss);
    dodge(i)=str2num(names.dodge);
    parry(i)=str2num(names.parry);
    block(i)=str2num(names.block);
    glance(i)=str2num(names.glance);
    
end

spellmiss=[77 66 55 44 33 22 11 0 0 0 0 0 0];

ld=90-level;
player_exp=7.5;
player_hit=7.5;

%% models
base_boss_miss=3.0;
ld_mod=1.5;
modmiss=max(0,base_boss_miss+ld.*ld_mod-player_hit);

base_boss_dodge=3.0; 
moddodge=max(0,base_boss_dodge+ld.*ld_mod-player_exp);

base_boss_parry=3.0;
boss_parry_bonus=3;
modparry=max(0,base_boss_parry+ld.*ld_mod+(ld>2)*boss_parry_bonus-player_exp);

base_boss_block = 3.0;
modblock=max(0,base_boss_block+ld.*ld_mod);

base_boss_glance=0;
ld_glance_mod=10;
modglance=max(0,base_boss_glance+(ld>3).*(10+ld.*ld_glance_mod));

base_boss_spellmiss=0;
ld_spellmiss_mod=11;
modspellmiss=max(0,base_boss_spellmiss+max(ld-3,0).*ld_spellmiss_mod);
modspellmiss=max(0,6+3.*ld+8.*max(ld-3,0)-player_hit-player_exp);

%% plots
figure(2)
subplot(2,3,1)
plot(ld,miss,ld,modmiss,'o')
legend('miss','model','Location','Best')
xlabel('level difference')
ylabel('Value')
ylim([-1 14])

subplot(2,3,2)
plot(ld,dodge,ld,moddodge,'o')
legend('dodge','model','Location','Best')
xlabel('level difference')
ylabel('Value')
ylim([-1 14])

subplot(2,3,3)
plot(ld,parry,ld,modparry,'o')
legend('parry','model','Location','Best')
xlabel('level difference')
ylabel('Value')
ylim([-1 14])

subplot(2,3,4)
plot(ld,block,ld,modblock,'o')
legend('block','model','Location','Best')
xlabel('level difference')
ylabel('Value')
% ylim([-1 14])

subplot(2,3,5)
plot(ld,glance,ld,modglance,'o')
legend('glance','model','Location','Best')
xlabel('level difference')
ylabel('Value')
% ylim([-1 14])

subplot(2,3,6)
plot(ld,spellmiss,ld,modspellmiss,'o')
legend('spell miss','model','Location','Best')
xlabel('level difference')
ylabel('Value')
% ylim([-1 14])
