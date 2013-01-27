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
%we set hit/exp to desired values by altering shirt stats

%hit-cap and exp cap
cfg(1)=build_config('hit',7.5,'exp',15);
 
%hit-cap and exp cap, SoI
cfg(2)=build_config('hit',7.5,'exp',15,'seal','SoT');

%hit-cap, exp cap, SoR
cfg(3)=build_config('hit',7.5,'exp',15,'seal','SoR'); 


%% Generate DPS for each config
queue_model; %lists the queues we're interested in

%preallocate arrays for speed
dps=zeros(length(cfg),length(queue.st));
hps=dps;efssUptime=dps;empties=dps;
dps2=dps;hps2=dps;

for g=1:length(cfg)
    %set configuration variables
    
    c=cfg(g);
    c.exec.veng=[ddb.v2];
    c=stat_model(c);
    c=ability_model(c);
    
    wb=waitbar(0,['Calculating CFG # ' int2str(g) ' / ' int2str(length(cfg))]);
    tic
    for q=1:length(queue.st)
        %update waitbar
        waitbar(q/length(queue.st),wb)
        
        %set queue value
        c.exec.queue=queue.st{q};
        
        %calculate DPS
        c=rotation_model(c);
        
        %store stuff for debugging
        crs_debug(q,g).meta=c.rot.metadata;
        crs_debug(q,g).action=c.rot.actionPr;
        crs_debug(q,g).cps=c.rot.cps;
        
        %store values for plot
        dps(q,g)=c.rot.dps;
        hps(q,g)=c.rot.hps;
        efssUptime(q,g)=max([c.rot.efuptime;c.rot.ssuptime]);
        empties(q,g)=c.rot.epct.*100; 
        hpg(q,g)=c.rot.hpg;
        
        %if desired, repeate for lower vengeance
        d=c;
        d.exec.veng=[ddb.v1];
        d=stat_model(d);
        d=ability_model(d);
        d=rotation_model(d);
        dps2(q,g)=d.rot.dps;
        hps2(q,g)=d.rot.hps;
        
        
    end
    close(wb)
    toc
    
 
end   
    

%% construct output arrays
L=length(queue.st);
ldat=2+[1:L];

for g=1:length(cfg)
    
    disp(' ')
    disp([num2str(cfg(g).player.mehit,'%1.2f') '% hit, ' num2str(cfg(g).player.exp,'%1.2f') '% exp, ' cfg(g).exec.seal])
    
    li=DataTable();
    li{1:2,1}={' ';'Q#'};
    li{ldat,1}=[1:L]';
    li{1:2,2}={' ';'Priority'};
    li{ldat,2}=queue.st;
    li{1:2,3}={'DPS';['V=' int2str(ddb.v2) 'k']};
    li{ldat,3}=dps(:,g);
    li{1:2,4}={'SHPS';['V=' int2str(ddb.v2) 'k']};
    li{ldat,4}=hps(:,g);
    li{1:2,5}={'DPS';['V=' int2str(ddb.v1) 'k']};
    li{ldat,5}=dps2(:,g);
    li{1:2,6}={'SHPS';['V=' int2str(ddb.v1) 'k']};
    li{ldat,6}=hps2(:,g);
    li{1:2,7}={'SS/EF';'Up%'};
    li{ldat,7}=efssUptime(:,g).*100;
    li{1:2,8}={'Empty';'GCD%'};
    li{ldat,8}=empties(:,g);
    li{1:2,9}={' ';'HPG/s'};
    li{ldat,9}=hpg(:,g);
    
    li.setColumnTextAlignment(2,'left')
    % li.setColumnTextAlignment(3:6,'center')
    li.setColumnFormat(3:6,'%6.0f')
    li.setColumnFormat(7:8,'%2.1f')
    disp('[code]')
    li.toText()
    disp('[/code]')
    
    lidb{g}=li;
end



%% pretty-print output array, this is only for the first set.
queue.stsubset={ ...
    'CS>J>AS>HW>Cons>SotR'; ...
    'AS>CS>J>HW>Cons>SotR';...
    'CS>J>AS>HW>Cons>ES>SotR';...
    'AS>CS>J>HW>Cons>ES>SotR';...
    '^WB>CS>J>AS>HW>Cons>SS>SotR';...
    'CS>J>AS>HW>HoW>Cons>SotR';...
    'HoW>CS>J>AS>HW>Cons>SotR';...
    'HoW>AS>CS>J>HW>ES>Cons>SotR';...
     };
    
li=lidb{1};
disp([num2str(cfg(1).player.mehit,'%1.2f') '% hit, ' num2str(cfg(1).player.exp,'%1.2f') '% exp'])    

for q=1:size(queue.stsubset,1)
    ind(q)=find(strcmp(queue.st,queue.stsubset{q}));
end

for q=size(queue.st,1):-1:1
    if find(ind==q)
        
    else
        li.deleteRow(2+q);
    end
        
end
    disp('[code]')
    li.toText()
    disp('[/code]')