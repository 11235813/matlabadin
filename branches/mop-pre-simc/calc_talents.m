%%CALC_TALENTS calculates DPS output in a variety of different talent
%%configurations to determine the effect of talent choices

%% Setup Tasks
clear;
disp('------------- CALC_TALENTS -------------')
%load gear database
gear_db;
%load defaults database
def_db;

%% Configurations
%create the first configuation
%set melee hit and expertise by altering shirt stats

%hit-cap and exp cap
cfg(1)=build_config('hit',7.5,'exp',15,'glyph',[0 0 0]);

%hit-cap and exp cap, SoT
cfg(2)=build_config('hit',7.5,'exp',15,'glyph',[0 0 0],'seal','SoT');

%multiple targets SoR
cfg(3)=build_config('hit',7.5,'exp',15,'glyph',[0 0 0],'npccount',5,'seal','SoR'); 

%% Vengeance levels
for v=[ddb.v1,ddb.v2]
    
    
    
%% Sim
tic
for g=1:length(cfg)
    
    %set configuration variables    
    c=cfg(g);
    c.exec.queue='CS>J>AS>HW>Cons>SotR';
    c.exec.veng=v;
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    %store baseline DPS
    dps0(g)=c.rot.dps;
    aoe0(g)=c.rot.aoe;
    hps0(g)=c.rot.hps;
    hpg0(g)=c.rot.hpg;
    sbu0(g)=c.rot.sbuptime;
    
%     wb=waitbar(0,['Calculating CFG # ' int2str(g) ' / ' int2str(length(cfg))]);

    %% L45 Talents
    %Eternal Flame
    c=cfg(g);
    c.talent=talent_model([0 0 2 0 0 0]);
    c.exec.queue='EF[buffEF<2.5]>CS>J>AS>HW>Cons>SotR5';
    c.exec.veng=v;
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    %store DPS & HPS
    EF_dps(g)=c.rot.dps-dps0(g);
    EF_hps(g)=c.rot.hps-hps0(g);
    EF_hpg(g)=c.rot.hpg-hpg0(g);
    EF_sbu(g)=c.rot.sbuptime;
    EF_avgsbu(g)=c.rot.sbuptime;
    
    %Sacred Shield
    c=cfg(g);
    c.talent=talent_model([0 0 3 0 0 0]);
    c.exec.queue='CS>J>AS>HW>Cons>SS>SotR';
    c.exec.veng=v;
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    %store DPS & HPS
    SS_dps(g)=c.rot.dps-dps0(g);
    SS_hps(g)=c.rot.hps-hps0(g);
    SS_hpg(g)=c.rot.hpg-hpg0(g);
    SS_sbu(g)=c.rot.sbuptime;
    SS_avgsbu(g)=c.rot.sbuptime;
    
    %% L75 Talents
    %Holy Avenger
    c=cfg(g);
    c.talent=talent_model([0 0 0 0 1 0]);
    c.exec.queue='CS>J>AS>HW>Cons>SotR';
    c.exec.veng=v;
    c.buff.HA=1;
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    %store DPS & HPS
    HA_dps(g)=(c.rot.dps-dps0(g)).*c.mdf.HAuptime;
    HA_hps(g)=(c.rot.hps-hps0(g)).*c.mdf.HAuptime;
    HA_hpg(g)=(c.rot.hpg-hpg0(g)).*c.mdf.HAuptime;
    HA_sbu(g)=c.rot.sbuptime;
    HA_avgsbu(g)=sbu0(g)+(c.rot.sbuptime-sbu0(g)).*c.mdf.HAuptime;
    
    %Sanctified Wrath
    c=cfg(g);
    c.talent=talent_model([0 0 0 0 2 0]);
    c.exec.queue='J>CS>AS>HW>Cons>SotR';
    c.exec.veng=v;
    c.buff.AW=1;
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    %AW w/o SW
    d=c;
    d.exec.queue='CS>J>AS>HW>Cons>SotR';
    d.talent=talent_model([0 0 0 0 0 0]);
    d=rotation_model(d);
    
    %store DPS & HPS
    swUptime=c.mdf.AWuptime.*c.mdf.SWuptime;
    awUptime=c.mdf.AWuptime;
    SW_dps(g)=(c.rot.dps.*swUptime+dps0(g).*(1-swUptime))-(d.rot.dps.*awUptime+dps0(g).*(1-awUptime));
    SW_hps(g)=(c.rot.hps.*swUptime+hps0(g).*(1-swUptime))-(d.rot.hps.*awUptime+hps0(g).*(1-awUptime));
    SW_hpg(g)=(c.rot.hpg.*swUptime+hpg0(g).*(1-swUptime))-(d.rot.hpg.*awUptime+hpg0(g).*(1-awUptime));
    SW_sbu(g)=c.rot.sbuptime;
    SW_avgsbu(g)=sbu0(g)+(c.rot.sbuptime-sbu0(g)).*swUptime;
    
    %Divine Purpose
    c=cfg(g);
    c.talent=talent_model([0 0 0 0 3 0]);
    c.exec.queue='SotR>CS>J>AS>HW>Cons';
    c.exec.veng=v;
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    %store DPS & HPS
    DP_dps(g)=c.rot.dps-dps0(g);
    DP_hps(g)=c.rot.hps-hps0(g);
    DP_hpg(g)=c.rot.hpg-hpg0(g);
    DP_sbu(g)=c.rot.sbuptime;
    DP_avgsbu(g)=c.rot.sbuptime;
    
    
    %% L90 Talents
    %Holy Prism
    c=cfg(g);
    c.exec.queue='SotR>CS>J>AS>HW>Cons>HPr';
    c.exec.veng=v;
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    %store DPS & HPS
    HPr_dps(g)=c.rot.dps-dps0(g)+c.rot.aoe-aoe0(g);
    HPr_hps(g)=c.rot.hps-hps0(g);
    HPr_hpg(g)=c.rot.hpg-hpg0(g);
    
    %Holy Prism
    c=cfg(g);
    c.exec.queue='SotR>CS>J>AS>HW>Cons>HPrSC';
    c.exec.veng=v;
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    %store DPS & HPS
    HPrSC_dps(g)=c.rot.dps-dps0(g)+c.rot.aoe-aoe0(g);
    HPrSC_hps(g)=c.rot.hps-hps0(g);
    HPrSC_hpg(g)=c.rot.hpg-hpg0(g);
    
    %Light's Hammer
    c=cfg(g);
    c.exec.queue='SotR>CS>J>AS>HW>Cons>LH';
    c.exec.veng=v;
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    %store DPS & HPS
    LH_dps(g)=c.rot.dps-dps0(g)+c.rot.aoe-aoe0(g);
    LH_hps(g)=c.rot.hps-hps0(g);
    LH_hpg(g)=c.rot.hpg-hpg0(g);
    
    %Execution Sentence
    c=cfg(g);
    c.exec.queue='SotR>CS>J>AS>HW>Cons>ES';
    c.exec.veng=v;
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    %store DPS & HPS
    ES_dps(g)=c.rot.dps-dps0(g);
    ES_hps(g)=c.rot.hps-hps0(g);
    ES_hpg(g)=c.rot.hpg-hpg0(g);
    
    
        
end
%     close(wb)
% toc
% end

tal_dps=[EF_dps;SS_dps;HA_dps;SW_dps;DP_dps;HPr_dps;LH_dps;ES_dps];
tal_hps=[EF_hps;SS_hps;HA_hps;SW_hps;DP_hps;HPr_hps;LH_hps;ES_hps];
tal_hpg=roundn([EF_hpg;SS_hpg;HA_hpg;SW_hpg;DP_hpg;HPr_hpg;LH_hpg;ES_hpg],-3);
tal_sbu=[EF_sbu;SS_sbu;HA_sbu;SW_sbu;DP_sbu];
tal_asbu=[EF_avgsbu;SS_avgsbu;HA_avgsbu;SW_avgsbu;DP_avgsbu];
tal_labels={'Eternal Flame';'Sacred Shield';'Holy Avenger';'Sanctified Wrath';...
            'Divine Purpose';'Holy Prism';'Light''s Hammer';'Execution Sentence'};
        
%fix for HPr self-cast in config #3
tal_dps(6,3)=HPrSC_dps(3);
tal_hps(6,3)=HPrSC_hps(3);

%% construct output arrays
ldat=3+[1:length(tal_labels)]; %offset by header rows

li=DataTable();
li{1:3,1}={' ';'Talent';'Base (no talents) '};      
li{ldat,1}=tal_labels;

for g=1:length(cfg)
    
    li{1:3,3*g-1}={['cfg' int2str(g)];'DPS';[num2str(roundn(dps0(g)./1e3,-1),'%2.1f') 'k']};
    li{ldat,3*g-1}=round(tal_dps(:,g));
    
    li{1:3,3*g}={['cfg' int2str(g)];'HPS';[num2str(roundn(hps0(1,g)./1e3,-1),'%2.1f') 'k']};
    li{ldat,3*g}=round(tal_hps(:,g));
    
    li{1:3,3*g+1}={['cfg' int2str(g)];'HPG';[num2str(roundn(hpg0(1,g),-3),'%1.3f')]};
    li{ldat,3*g+1}=tal_hpg(:,g);
    li.setColumnFormat(3*g+1,'%1.3g')

end

li2=DataTable();
li2{1:3,1}={' ';'Talent';'Base'};
li2{4:8,1}=[tal_labels(1:5)];%li2{5,1}=tal_labels{4};li2{6,1}=tal_labels{5};
for g=1:length(cfg)
    
    li2{1:3,2*g}={['cfg' int2str(g)];'SBU%';num2str(roundn(sbu0(g).*100,-2),'%2.2f')};
    li2{4:8,2*g}=tal_sbu(:,g).*100;
    li2.setColumnFormat(2*g,'%2.2f')
    
    li2{1:3,2*g+1}={['cfg' int2str(g)];'AvgU%';num2str(roundn(sbu0(g).*100,-2),'%2.2f')};
    li2{4:8,2*g+1}=tal_asbu(:,g).*100;
    li2.setColumnFormat(2*g+1,'%2.2f')
end

% li.setColumnTextAlignment(2,'left')
% li.setColumnTextAlignment(3:6,'center')
% li.setColumnFormat(3:4,'%6.0f')
% li.setColumnFormat(5:6,'%2.1f')

disp(' ');disp(' ');
disp(['---' int2str(round(c.player.VengAP./1000)) 'k Vengeance ---[code]'])
li.toText()
disp('[/code][code]')
li2.toText()
disp('[/code]')

%% plots

%% close Veng loop
end