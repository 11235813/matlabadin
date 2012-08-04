%%CALC_TALENTS calculates DPS output in a variety of different talent
%%configurations to determine the effect of talent choices

%% Setup Tasks
clear;
%load gear database
gear_db;
%load defaults database
def_db;

%% Configurations
%create the first configuation
%low hit, SotR/SoT build
%set melee hit to 2%, expertise to 5%
%do this by altering shirt stats
cfg(1)=build_config('hit',2,'exp',5,'glyph',[0 0 0],'talents',[0 0 0 0 0 0]); 

%hit-cap and exp soft-cap
cfg(2)=build_config('hit',7.5,'exp',7.5,'glyph',[0 0 0],'talents',[0 0 0 0 0 0]);
% 
% %multiple targets
% cfg(3)=build_config('hit',2,'exp',5,'glyph',[0 0 0],'npccount',3); 


%% Sim
tic
for g=1:length(cfg)
    
    %set configuration variables    
    c=cfg(g);
    c.exec.queue='^WB>SotR>CS>J>AS>Cons>HW';
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    %store baseline DPS
    dps0(g)=c.rot.dps;
    hps0(g)=c.rot.hps;
    
%     wb=waitbar(0,['Calculating CFG # ' int2str(g) ' / ' int2str(length(cfg))]);

    %% L45 Talents
    %Eternal Flame
    c=cfg(g);
    c.talent=talent_model([0 0 2 0 0 0]);
    c.exec.queue='^WB>^EF>SotR>CS>J>AS>Cons>HW';
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    %store DPS & HPS
    EF_dps(g)=c.rot.dps-dps0(g);
    EF_hps(g)=c.rot.hps-hps0(g);
    
    %Sacred Shield
    c=cfg(g);
    c.talent=talent_model([0 0 3 0 0 0]);
    c.exec.queue='^WB>^SS>SotR>CS>J>AS>Cons>HW';
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    %store DPS & HPS
    SS_dps(g)=c.rot.dps-dps0(g);
    SS_hps(g)=c.rot.hps-hps0(g);
    
    %% L75 Talents
    %Holy Avenger
    c=cfg(g);
    c.talent=talent_model([0 0 0 0 1 0]);
    c.exec.queue='^WB>SotR>CS>J>AS>Cons>HW';
    c.buff.HoAv=1;
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    %store DPS & HPS
    HA_dps(g)=(c.rot.dps-dps0(g)).*15./120;
    HA_hps(g)=(c.rot.hps-hps0(g)).*15./120;
    
    %Sanctified Wrath
    c=cfg(g);
    c.talent=talent_model([0 0 0 0 2 0]);
    c.exec.queue='^WB>SotR>CS>J>AS>Cons>HW';
    c.buff.AvWr=1;
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    %AW w/o SW
    d=c;
    d.talent=talent_model([0 0 0 0 0 0]);
    d=rotation_model(d);
    
    %store DPS & HPS
    SW_dps(g)=(c.rot.dps.*30./180+dps0(g).*150./180)-(d.rot.dps.*20./180+dps0(g).*160./180);
    SW_hps(g)=(c.rot.hps.*30./180+hps0(g).*150./180)-(d.rot.hps.*20./180+hps0(g).*160./180);
    
    %Divine Purpose
    c=cfg(g);
    c.talent=talent_model([0 0 0 0 3 0]);
    c.exec.queue='^WB>SotR>CS>J>AS>Cons>HW';
    c.buff.AW=1;
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    %store DPS & HPS
    DP_dps(g)=c.rot.dps-dps0(g);
    DP_hps(g)=c.rot.hps-hps0(g);
    
    
    %% L90 Talents
    %Holy Prism
    c=cfg(g);
    c.exec.queue='^WB>SotR>CS>J>AS>HPr>Cons>HW';
    c=rotation_model(c);
    
    %store DPS & HPS
    HPr_dps(g)=c.rot.dps-dps0(g);
    HPr_hps(g)=c.rot.hps-hps0(g);
    
    %Light's Hammer
    c=cfg(g);
    c.exec.queue='^WB>SotR>CS>J>AS>LH>Cons>HW';
    c=rotation_model(c);
    
    %store DPS & HPS
    LH_dps(g)=c.rot.dps-dps0(g);
    LH_hps(g)=c.rot.hps-hps0(g);
    
    %Execution Sentence
    c=cfg(g);
    c.exec.queue='^WB>SotR>CS>J>AS>ES>Cons>HW';
    c=rotation_model(c);
    
    %store DPS & HPS
    ES_dps(g)=c.rot.dps-dps0(g);
    ES_hps(g)=c.rot.hps-hps0(g);
    
    
        
end
%     close(wb)
toc
% end

tal_dps=[EF_dps;SS_dps;HA_dps;SW_dps;DP_dps;HPr_dps;LH_dps;ES_dps];
tal_hps=[EF_hps;SS_hps;HA_hps;SW_hps;DP_hps;HPr_hps;LH_hps;ES_hps];
tal_labels={'Eternal Flame';'Sacred Shield';'Holy Avenger';'Sanctified Wrath';...
            'Divine Purpose';'Holy Prism';'Light''s Hammer';'Execution Sentence'};

%% construct output arrays
ldat=3+[1:length(tal_labels)]; %offset by header rows

li=DataTable();
li{1:3,1}={' ';'Talent';'Base (no talents) '};      
li{ldat,1}=tal_labels;

for g=1:length(cfg)
    
li{1:3,2*g}={['cfg' int2str(g)];'DPS';[num2str(roundn(dps0(g)./1e3,-1),'%2.1f') 'k']};
li{ldat,2*g}=round(tal_dps(:,g));

li{1:3,2*g+1}={['cfg' int2str(g)];'HPS';[num2str(roundn(hps0(1,g)./1e3,-1),'%2.1f') 'k']};
li{ldat,2*g+1}=round(tal_hps(:,g));

end

% li.setColumnTextAlignment(2,'left')
% li.setColumnTextAlignment(3:6,'center')
% li.setColumnFormat(3:4,'%6.0f')
% li.setColumnFormat(5:6,'%2.1f')
li.toText()

%% plots