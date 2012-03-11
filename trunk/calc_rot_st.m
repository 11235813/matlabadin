%CALC_ROT_ST uses the FSM formalism to calculate damage for a variety of
%different single-target rotations under different conditions

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
c(1)=build_config('hit',2,'exp',5); 

%low hit, WoG/SoI build
c(2)=build_config('hit',2,'exp',5,'seal','SoI');

%hit-cap and exp soft-cap
c(3)=build_config('hit',7.5,'exp',7.5);


queue_model; %lists the queues we're interested in



%% Generate DPS for each config

%preallocate arrays for speed
dps=zeros(length(c),length(queue.st));
hps=dps;efssUptime=dps;empties=dps;
dps2=dps;hps2=dps;

for g=1:length(c)
    %set configuration variables
    
    cfg=c(g);
    cfg=stat_model(cfg);
    cfg=ability_model(cfg);
    
    wb=waitbar(0,['Calculating CFG # ' int2str(g) ' / ' int2str(length(c))]);
    tic
    for q=1:length(queue.st)
        %update waitbar
        waitbar(q/length(queue.st),wb)
        
        %set queue value
        cfg.exec.queue=queue.st{q};
        
        %calculate DPS
        cfg=rotation_model(cfg);
        
        %store stuff for debugging
        crs_debug(q,g).meta=cfg.rot.metadata;
        crs_debug(q,g).action=cfg.rot.actionPr;
        crs_debug(q,g).cps=cfg.rot.cps;
        
        %store values for plot
        dps(q,g)=cfg.rot.dps;
        hps(q,g)=cfg.rot.hps;
        efssUptime(q,g)=max([cfg.rot.efuptime;cfg.rot.ssuptime]);
        empties(q,g)=cfg.rot.empties; %TODO: fix in [CR] once actionPr working again
        
        %Old code for empties - for reference
        %empties(q,g)=sum(cfg.rot.cps((length(cfg.rot.cps)-1):length(cfg.rot.cps)));
        %alternatively, grab the "nothing" output of actionPr if it's
        %re-implemented
        %empties(kk)=1/1.5-sum([actionPr{2,:}]);
        
        %if desired, repeate for lower vengeance
        %         cfg.exec.veng=0.3;
        %         cfg=ability_model(cfg);
        %         cfg=rotation_model(cfg);
        %         dps2(q,g)=cfg.rot.dps;
        %         hps2(q,g)=cfg.rot.hps;
        %
        
    end
    close(wb)
    toc
    
 
end   
    

%% construct output arrays
L=length(queue.st);
ldat=2+[1:L];

for g=1:length(c)

disp([num2str(c(g).player.mehit,'%1.2f') '% hit, ' num2str(c(g).player.exp,'%1.2f') '% exp'])    
    
li=DataTable();
li{1:2,1}={' ';'Q#'};      
li{ldat,1}=[1:L]';
li{1:2,2}={' ';'Priority'};
li{ldat,2}=queue.st;
li{1:2,3}={'DPS';'V=100%'};
li{ldat,3}=dps(:,g);
li{1:2,4}={'SHPS';'V=100%'};
li{ldat,4}=hps(:,g);
li{1:2,5}={'SS/EF';'Uptime%'};
li{ldat,5}=efssUptime(:,g);
li{1:2,6}={' ';'Empty%'};
li{ldat,6}=empties(:,g);

li.setColumnTextAlignment(2,'left')
% li.setColumnTextAlignment(3:6,'center')
li.setColumnFormat(3:4,'%6.0f')
li.setColumnFormat(5:6,'%2.1f')
li.toText()

lidb{g}=li;
end



%% pretty-print output array, this is only for the first set.
queue.stsubset={ ...
    'SotR>CS>J>AS>Cons'; ...
    'SotR>CS>AS>J>Cons'; ...
    'WoG>CS>J>AS'; ...
    };
    
li=lidb{1};
disp([num2str(c(1).player.mehit,'%1.2f') '% hit, ' num2str(c(1).player.exp,'%1.2f') '% exp'])    

for q=1:size(queue.stsubset,1)
    ind(q)=find(strcmp(queue.st,queue.stsubset{q}));
end

for q=size(queue.st,1):-1:1
    if find(ind==q)
        
    else
        li.deleteRow(2+q);
    end
        
end
li.toText()