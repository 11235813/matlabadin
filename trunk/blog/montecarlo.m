function [DTPS statblock]=montecarlo(stat,val,simMins,plotFlag)
dhit=0;dexp=0;dhaste=0;dmastery=0;ddodge=0;
if nargin<4
    plotFlag='plot';
end
if nargin<3
    simMins=1000;
end
if nargin<2
    val=600;
end
if nargin>=1
    switch stat
        case 'hit'
            dhit=val;
        case 'exp'
            dexp=val;
        case 'haste'
            dhaste=val;
        case 'mastery'
            dmastery=val;
        case 'dodge'    
            ddodge=val;
    end
    
    
end


%% Define constants/variables
bossSwingTimer=2;
avoidance=0.2+1/(1/0.65631440+0.9560/(0.1128+0.01.*ddodge/176.71890258));
blockChance=0.05+1/(1/1.351+0.9560/(0.7588+0.0225.*dmastery/179.28004455));
haste=0.1+0.01.*dhaste./128.05715942;
hit=0.02+0.01.*dhit./120.10880279;
exp=0.02+0.01.*dexp./120.10880279;
miss=0.075-hit;
dodge=0.075-exp;
parry=0.075-max((exp-0.075),0);
hp=0;
gcProcRate=0.2;
gcBuffDuration=6.3;
dpProcRate=0.15;
dpBuffDuration=8;


events={'Boss Swing Timer','GCD'};
tbe = zeros(size(events));
idBossSwing=1;
idGCD=2;

buffs={'SotR buff #1 duration','SotR buff #2 duration','CS cooldown','J cooldown','SotR cooldown','Grand Crusader duration','Div Pupr duration'};
tob = zeros(size(buffs));
idGBlock=1;
idBvBuff=2;
idCScd=3;
idJcd=4;
idSotRcd=5;
idGCbuff=6;
idDPBuff=7;

simTime=simMins*60;
steps_per_sec=100;
% time=0;             %initial time

%arrays
N=floor(simTime.*steps_per_sec);
dt=1./steps_per_sec;
t=zeros(N,1);
damage=-1.*ones(N,1);
debugS=t;debugG=t;debugHP=t;debugSotR=t;debugHPG=t;

%%for loop to do event handling
tic
for k=1:N
        
    %record time
    t(k)=(k-1).*dt;
    
    %check for events
    if sum(tbe<=0)>0  %if any of the event timers is 0 or less
        %something should happen in this time step
        
        
        %figure out which event(s) it is
        ids=find(tbe<=0);
        
        %event handling
        for j=1:length(ids)
            switch ids(j)
                
                %boss swing
                case idBossSwing
                    %reset boss swing timer
                    tbe(idBossSwing)=bossSwingTimer;
                                        
                    %check for avoid
                    if rand < avoidance
                        damage(k)=0;
                    else
                        %figure out damage value.  First, check for gblock
                        if tob(idGBlock)>0
                            damage(k)=0.25;
                            tob(idGBlock)=0;
                        elseif rand < blockChance
                            if tob(idBvBuff)>0
                                damage(k)=0.5;
                            else
                                damage(k)=0.7;
                            end
                        else
                            damage(k)=1;
                        end
                    end
                                        
                case idGCD
                    
                    if tob(idCScd)<=0
                        tob(idCScd)=4.5./(1+haste);
                        tbe(idGCD)=1.5./(1+haste);
                        if rand<(1-miss-dodge-parry)
                            hp=hp+1;hp=min([hp 5]);hp=max([hp 0]);
                            debugHPG(k)=1;
                            %grand crusader
                            if rand<gcProcRate
                                tob(idGCbuff)=gcBuffDuration;
                            end
                        end
                    elseif tob(idJcd)<=0 && tob(idCScd)>=0.2
                        tob(idJcd)=6./(1+haste);
                        tbe(idGCD)=1.5./(1+haste);
                        if rand<(1-miss-dodge)
                            hp=hp+1;hp=min([hp 5]);hp=max([hp 0]);
                            debugHPG(k)=2;
                        end
                    elseif tob(idGCbuff)>0
                        tob(idGCbuff)=0;
                        tbe(idGCD)=1.5./(1+haste);
                        hp=hp+1;hp=min([hp 5]);hp=max([hp 0]);
                            debugHPG(k)=3;
                    end
                    
                    %check for 3+ HP, if so cast SotR
                    if ( hp>=3 || tob(idDPBuff)>0 ) && tob(idSotRcd)<=0 && tob(idGBlock)<=0
                        tob(idSotRcd)=1.5;
                        tob(idGBlock)=6;
                        tob(idBvBuff)=max(0,tob(idBvBuff))+6;
                        if tob(idDPBuff)>0
                           tob(idDPBuff)=0; 
                        elseif hp>=3
                            hp=hp-3;
                        else
                            error('WTF')
                        end
                        %DP
                        if rand<dpProcRate
                            tob(idDPBuff)=dpBuffDuration;
                        end
                    end
                    
            end %close switch
                                        
        end %close event for

    end %close event if
        
    
    %% Debugging
    debugS(k,1)=tob(idBvBuff);
    debugG(k,1)=tob(idGBlock);
    debugSotR(k,1)=tob(idSotRcd);
    debugHP(k,1)=hp;
    
    %increment time by decreasing tob and tbe
    tbe=tbe-dt;
    tob=tob-dt;
end
toc

%% compile for plots
avoids=sum(damage==0);
gblocks=sum(damage==0.25);
sblocks=sum(damage==0.5);
rblocks=sum(damage==0.7);
hits=sum(damage==1);
allattacks=avoids+gblocks+sblocks+rblocks+hits;

avoidspct=avoids./allattacks;
gblockspct=gblocks./allattacks;
sblockspct=sblocks./allattacks;
rblockspct=rblocks./allattacks;
hitspct=hits./allattacks;

G=gblocks./(allattacks-avoids);
S=sblocks./(allattacks-avoids-gblocks-hits);
Tsotr = max(t)./sum(debugG==6);
Rsotr = 1/Tsotr;
Rhpg=sum(debugHPG>0)/max(t);

DTPS=sum((damage>0).*damage)./max(t);

if ~strcmp(plotFlag,'noplot')
figure(1)
x=[0 0.25 0.5 0.7 1]; y=[avoidspct gblockspct sblockspct rblockspct hitspct];
bar(x,y)
xlim([-0.1 1.1])
text(-0.03,avoidspct+0.01,[num2str(avoidspct.*100,'%2.1f') '%'])
text(0.25-0.03,gblockspct+0.01,[num2str(gblockspct.*100,'%2.1f') '%'])
text(0.5-0.03,sblockspct+0.01,[num2str(sblockspct.*100,'%2.1f') '%'])
text(0.7-0.03,rblockspct+0.01,[num2str(rblockspct.*100,'%2.1f') '%'])
text(1-0.03,hitspct+0.01,[num2str(hitspct.*100,'%2.1f') '%'])
title(['T=' int2str(simTime./60) ' min, G=' num2str(G.*100,'%2.1f') '%, S=' num2str(S.*100,'%2.1f') '%, Tsotr=' num2str(Tsotr,'%2.1f') ', DTPS=' num2str(DTPS.*100,'%2.2f')])
end

statblock.G=G;
statblock.S=S;
statblock.Tsotr=Tsotr;
statblock.Rhpg=Rhpg;

end