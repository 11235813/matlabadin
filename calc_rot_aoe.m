%CALC_ROT_AOE uses the FSM formalism to calculate damage for a variety of
%different aoe-target rotations against multiple targets

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
cfg(1)=build_config('hit',7.5,'exp',15,'glyph',[0 0 0]);
 
%hit-cap and exp cap, SoI
cfg(2)=build_config('hit',7.5,'exp',15,'seal','SoT','glyph',[0 0 0]);

%hit-cap, exp cap, SoR
cfg(3)=build_config('hit',7.5,'exp',15,'seal','SoR','glyph',[0 0 0]); 


%% Generate DPS for each config
queue_model; %lists the queues we're interested in
NumTargets=8;

%preallocate arrays for speed
z=zeros(length(queue.aoe),NumTargets,length(cfg));
dps1=z;dps2=z;
aoe1=z;aoe2=z;
hps1=z;hps2=z;
sut1=z;sut2=z;
emt1=z;emt2=z;
hpg1=z;hpg2=z;

for k=1:length(cfg)
    %set configuration variables
    
    c=cfg(k);
    
    wb=waitbar(0,['Calculating CFG # ' int2str(k) ' / ' int2str(length(cfg))]);
    tic
    for q=1:length(queue.aoe)
        %update waitbar
        waitbar(q/length(queue.aoe),wb)
        
        %set queue value
        c.exec.queue=queue.aoe{q};
        
        %for each number of targets
        for n=1:NumTargets
            
            c.exec.npccount=n;
            
            %calculate DPS for first Vengeance value
            c.exec.veng=[ddb.v1];
            c=stat_model(c);
            c=ability_model(c);
            c=rotation_model(c);
            
            %store values for table/plot
            dps1(q,n,k)=c.rot.dps;
            aoe1(q,n,k)=c.rot.aoe./(n-1);
            hps1(q,n,k)=c.rot.hps;
            sut1(q,n,k)=c.rot.sbuptime;
            emt1(q,n,k)=c.rot.epct.*100;
            hpg1(q,n,k)=c.rot.hpg;
            
            %debug
            C(q,n,k)=c;
            
            %repeate for higher vengeance
            d=c;
            d.exec.veng=[ddb.v2];
            d=stat_model(d);
            d=ability_model(d);
            d=rotation_model(d);
            
            %store values for table/plot
            dps2(q,n,k)=d.rot.dps;
            aoe2(q,n,k)=d.rot.aoe./(n-1);
            hps2(q,n,k)=d.rot.hps;
            sut2(q,n,k)=d.rot.sbuptime;
            emt2(q,n,k)=d.rot.epct.*100;
            hpg2(q,n,k)=d.rot.hpg;
            
        end
        
        
    end
    close(wb)
    toc
    
 
end


%% construct output arrays
L=length(queue.aoe);
ldat=2+[1:L];

%for each vengeance value
for v=1:2
    eval(['dps=dps' int2str(v) ';aoe=aoe' int2str(v) ';veng=ddb.v' int2str(v) ';']);
    
    
    for g=1:length(cfg)
        
        disp(' ')
        disp([num2str(cfg(g).player.mehit,'%1.2f') '% hit, ' num2str(cfg(g).player.exp,'%1.2f') '% exp, ' cfg(g).exec.seal])
        
        li=DataTable();
        li{1:2,1}={' ';'Q#'};
        li{ldat,1}=[1:L]';
        li{1:2,2}={['V=' int2str(veng) 'k'];'Priority'};
        li{ldat,2}=queue.aoe;
        li{1:2,3}={'Primary';'N=3'};
        li{ldat,3}=round(dps(:,3,g));
        for j=2:NumTargets
            li{1:2,2+j}={'Splash';['N=' int2str(j)]};
            li{ldat,2+j}=round(aoe(:,j,g));
        end
        
        li.setColumnTextAlignment(2,'left')
        disp('[code]')
        li.toText()
        disp('[/code]')
        
        lidb{g}=li;
    end
end


%% TODO: SoT vs. SoR
% SoR damage is (SoR DPS)*M, where M is the # of targets
% SoT damage is (SoT DPS) + (Censure Stack DPS)*N, where N is the # of
% targets you can keep a full stack of Censure applied to
