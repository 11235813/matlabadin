clear
load level_based_def.mat

matchstr='(?<level>\d+),\sM(?<miss>\d+\.\d)\sD(?<postDodge>\d+\.\d)\((?<preDodge>\d+\.\d)\)\sP(?<postParry>\d+\.\d)\((?<preParry>\d+\.\d)\)\sG(?<glance>\d+\.\d)\sB(?<postBlock>\d+\.\d)\((?<preBlock>\d+\.\d)\)\sC(?<crush>\d+\.\d)';
for i=1:length(level_based_def)
    
    textline=level_based_def{i};
    names = regexp(textline, matchstr,'names');
    
    level(i)=str2num(names.level);
    miss(i)=str2num(names.miss);
    postDodge(i)=str2num(names.postDodge);
    preDodge(i)=str2num(names.preDodge);
    postParry(i)=str2num(names.postParry);
    preParry(i)=str2num(names.preParry);
    postBlock(i)=str2num(names.postBlock);
    preBlock(i)=str2num(names.preBlock);
    crush(i)=str2num(names.crush);
    glance(i)=str2num(names.glance);
    
    smisslevel=lb_def_smiss(:,1);
    spellmiss=lb_def_smiss(:,2);
    
end

ld=level-90;
ldsm=smisslevel-80;
boss_exp=0;

%% models
base_char_miss=3.0;
ld_mod=1.5;
modmiss=max(0,base_char_miss+ld.*ld_mod+max(ld-3,0).*ld_mod);

base_char_dodge=5.0; %3.0 base + 2.0 Sanctuary
moddodge=max(0,base_char_dodge+ld.*ld_mod);

base_char_parry=preParry;
modparry=max(0,base_char_parry+ld.*ld_mod);

base_char_block = preBlock;
modblock=max(0,base_char_block+ld.*ld_mod);

base_char_crush=0;
ld_crush_mod=10;
modcrush=max(0,base_char_crush+(ld<-3).*(-15-ld.*ld_crush_mod));

base_char_smiss=6;
modsmiss=min(90,max(0,base_char_smiss+3.*ldsm+8.*max(ldsm-3,0)))

%% plots
figure(1)
subplot(2,3,1)
plot(ld,miss,ld,modmiss,'o')
legend('miss','model','Location','Best')
xlabel('level difference')
ylabel('Value')
ylim([-1 14])

subplot(2,3,2)
plot(ld,postDodge,ld,moddodge,'o')
legend('dodge','model','Location','Best')
xlabel('level difference')
ylabel('Value')
ylim([-1 14])

subplot(2,3,3)
plot(ld,postParry,ld,modparry,'o')
legend('parry','model','Location','Best')
xlabel('level difference')
ylabel('Value')
% ylim([-1 14])

subplot(2,3,4)
plot(ld,postBlock,ld,modblock,'o')
legend('block','model','Location','Best')
xlabel('level difference')
ylabel('Value')
% ylim([-1 14])

subplot(2,3,5)
plot(ld,crush,ld,modcrush,'o')
legend('crush','model','Location','Best')
xlabel('level difference')
ylabel('Value')
% ylim([-1 14])

subplot(2,3,6)
plot(ldsm,spellmiss,ldsm,modsmiss,'o')
legend('spellmiss','model','Location','Best')
xlabel('level difference')
ylabel('Value')
% ylim([-1 14])

