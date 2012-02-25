%CALC_TIERBONUS calculates the relative DPS output of different tier
%bonuses using a normalized gear set

%% Setup tasks
clear;
gear_db;
def_db;

exec=execution_model('veng',1); 
base=player_model('race','Human','prof','');
npc=npc_model(base);
egs=ddb.gearset{8};  %3=T11H, 4=T12, 5=T12H
gear_stats;
talent=ddb.talentset{1};
glyph=ddb.glyphset{4}; 
talents;
buff=buff_model;
stat_model;


%% List of weapons
weaplist=[ % 70922; %Mandible of Beth'tilac
%             71406; %Mandible of Beth'tilac (Heroic)
            77193; %Souldrinker 
         ];
M=length(weaplist);

%% Vengeance values
vlist=[0.3 1];
V=length(vlist);

%% Gear/Rotation/Seal Configurations
%939 rotation, low-hit set
%set melee hit to 2%, expertise to 10, mastery to 390 (16.5 mastery);
%do this by altering helm stats

queue.rot={ 'SotR>CS>J>AS';
            'SotR>CS>AS+>J>AS';
            'SotR>CS>AS+>J>AS>Cons';
            'SotR>CS>AS+>J>AS>Cons>HW';
            'ISotR>SDSotR>Inq>CS>J>AS';
            'ISotR>SDSotR>Inq>CS>J>AS>Cons';
            'ISotR>SDSotR>Inq>CS>J>AS>Cons>HW'};
c=1;
cfg(c).helm=egs(1);
cfg(c).helm.hit=max([egs(1).hit 0])-(player.phhit-2).*cnv.hit_phhit;
cfg(c).helm.exp=max([egs(1).exp 0])-(player.exp-10).*cnv.exp_exp;
cfg(c).rot=1; %939   
cfg(c).seal='SoT';
cfg(c).label='939/SoT, 2% hit, 10 exp';

%939 for 8% hit and exp soft-cap
c=c+1;
cfg(c)=cfg(c-1);
cfg(c).helm=egs(1);
cfg(c).helm.hit=max([egs(1).hit 0])-(player.phhit-8).*cnv.hit_phhit;
cfg(c).helm.exp=max([egs(1).exp 0])-(player.exp-26).*cnv.exp_exp;
cfg(c).label='939/SoT, 8% hit, 26 exp';

%939 for 8% hit and exp hard-cap
c=c+1;
cfg(c)=cfg(c-1);
cfg(c).helm=egs(1);
cfg(c).helm.hit=max([egs(1).hit 0])-(player.phhit-8).*cnv.hit_phhit;
cfg(c).helm.exp=max([egs(1).exp 0])-(player.exp-56).*cnv.exp_exp;
cfg(c).label='939/SoT, 8% hit, 56 exp';

% %I39 for 2% hit 10 exp
% c=c+1;
% cfg(c)=cfg(c-1);
% cfg(c).rot=3; %I39
% cfg(c).label='I39/SoT, 2% hit, 10 exp';

%% initialize arrays for speed
prot_2pc_dps=zeros(size(gear.tierbonusP,2),V,length(cfg),M);
ret_2pc_dps=prot_2pc_dps;


%% crank

for m=1:M
    
    %equip the appropriate weapon
    egs(15)=equip(weaplist(m));
    %store useful info for table
    pinfo.name{m}=egs(15).name;
    pinfo.ilvl(m)=egs(15).ilvl;
    
    for c=1:length(cfg)
        %set the configuration
        
        for v=1:V
            
            %for each value of vengeance
            
            %calculate DPS
            exec=execution_model('seal',cfg(c).seal,'veng',vlist(v));
            egs(1)=cfg(c).helm;
            talents;
            gear_stats;
            
            %disable tier bonuses
            gear.tierbonusP=[0 0 0; 0 0 0];
            gear.tierbonusR=[0 0 0; 0 0 0];
            
            stat_model;
            ability_model;
            rotation_model;
            tmprot.dps=rot(cfg(c).rot).totdps;
            dynamic_model;
            %store baseline
            dps0(v,c,m)=tmprot.dps+proc.dps;
            
            
            %calculate each tier bonus
            
            %prot 2pc
            for t=1:size(gear.tierbonusP,2)
                gear.tierbonusP=[0 0 0; 0 0 0];
                gear.tierbonusR=[0 0 0; 0 0 0];
                
                gear.tierbonusP(1,t)=1;
                
                stat_model;
                ability_model;
                rotation_model;
                tmprot.dps=rot(cfg(c).rot).totdps;
                dynamic_model;
                prot_2pc_dps(t,v,c,m)=tmprot.dps+proc.dps;
            end
            
            
            %ret 2pc
            for t=1:size(gear.tierbonusP,2)
                gear.tierbonusP=[0 0 0; 0 0 0];
                gear.tierbonusR=[0 0 0; 0 0 0];
                
                gear.tierbonusR(1,t)=1;
                
                stat_model;
                ability_model;
                rotation_model;
                tmprot.dps=rot(cfg(c).rot).totdps;
                dynamic_model;
                ret_2pc_dps(t,v,c,m)=tmprot.dps+proc.dps;
            end
            
            
        end

    end

end


%% Tables
spacer = repmat(' ',4,3);
for c=1:length(cfg)
    for m=1:M
        
        tablecm=round([prot_2pc_dps(:,2,c,m)';ret_2pc_dps(:,2,c,m)']-dps0(2,c,m));
        
        pptable=[char({' ',' ','prot 2pc','ret 2pc'}) spacer ...
                 char({' ','T11',int2str(tablecm(:,1))}) spacer ...
                 char({' ','T12',int2str(tablecm(:,2))}) spacer ...
                 char({' ','T13',int2str(tablecm(:,3))}) spacer ...
                 ];

             
%         %uncomment if using 30% vengeance as well
%         tablecm=round([[prot_2pc_dps(:,2,c,m)';ret_2pc_dps(:,2,c,m)']-dps0(2,c,m) ...
%             [prot_2pc_dps(:,1,c,m)';ret_2pc_dps(:,1,c,m)']-dps0(1,c,m)]);
%         
%         pptable=[char({' ',' ','prot 2pc','ret 2pc'}) spacer ...
%                  char({'v=','T11',int2str(tablecm(:,1))}) spacer ...
%                  char({[num2str(vlist(2)*100) '%'],'T12',int2str(tablecm(:,2))}) spacer ...
%                  char({' ','T13',int2str(tablecm(:,3))}) spacer ...
%                  char({'v=','T11',int2str(tablecm(:,4))}) spacer ...
%                  char({[num2str(vlist(1)*100) '%'],'T12',int2str(tablecm(:,5))}) spacer ...
%                  char({' ','T13',int2str(tablecm(:,6))}) spacer ...
%                  ];
             
             disp(' ')
             disp([cfg(c).label ', ' queue.rot{cfg(c).rot}])
             disp([pinfo.name{m} ' ' int2str(pinfo.ilvl(m))])
             disp(pptable)
            
    end
end



