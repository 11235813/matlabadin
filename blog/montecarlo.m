function [DTPS statblock]=montecarlo(stat,val,simMins,plotFlag)
dhit=0;dexp=0;dhaste=0;dmastery=0;ddodge=0;
if nargin<4
    plotFlag='plot';
end
if nargin<3
    simMins=500;
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
dodge=max(0,(0.075-exp));
parry=max(0,(0.075-max((exp-0.075),0)));
hp=0;
gcProcRate=0.2;
gcBuffDuration=6.3;
dpProcRate=0.15;
dpBuffDuration=8;


events={'Boss Swing Timer','GCD'};
tbe = zeros(size(events));
idBossSwing=1;
idGCD=2;

buffs={'SotR duration','BoG Duration','CS cooldown','J cooldown','SotR cooldown','Grand Crusader duration','Div Pupr duration'};
tob = zeros(size(buffs));
idSotR=1;
idBoG=2;
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
                        %figure out damage value.  First, check for SotR
                        if tob(idSotR)>0
                            drmult=0.5;
                        else
                            drmult=1;
                        end
                        %now check for block    
                        if rand < blockChance
                            damage(k)=0.7.*drmult;
                        else
                            damage(k)=1.*drmult;
                        end
                    end
                %if the GCD timer is up, see if there's something to cast                        
                case idGCD
                    %CS is first priority
                    if tob(idCScd)<=0
                        %put CS on cooldown, start GCD
                        tob(idCScd)=4.5./(1+haste);
                        tbe(idGCD)=1.5./(1+haste);
                        %Check for hit
                        if rand<(1-miss-dodge-parry)
                            %success! grant HP, enforce bounds
                            hp=hp+1;hp=min([hp 5]);hp=max([hp 0]);
                            debugHPG(k)=1; %debug flag
                            %Check for Grand Crusader proc
                            if rand<gcProcRate
                                %set GC buff duration
                                tob(idGCbuff)=gcBuffDuration;
                            end
                        end
                    %J is second priority, check for cooldown and don't use
                    %if CS cd is almost up
                    elseif tob(idJcd)<=0 && tob(idCScd)>=0.2
                        %set J cooldown, start GCD
                        tob(idJcd)=6./(1+haste);
                        tbe(idGCD)=1.5./(1+haste);
                        %check for hit
                        if rand<(1-miss-dodge)
                            %success! grant HP, enforce bounds
                            hp=hp+1;hp=min([hp 5]);hp=max([hp 0]);
                            debugHPG(k)=2; %debug flag
                        end
                    %Grand Crusader
                    elseif tob(idGCbuff)>0 && tob(idCScd)>=0.2
                        %Consume GC buff, set GCD
                        tob(idGCbuff)=0;
                        tbe(idGCD)=1.5./(1+haste);
                        %grant HP, enforce bounds
                        hp=hp+1;hp=min([hp 5]);hp=max([hp 0]);
                        debugHPG(k)=3; %debug flag
                    end
                    
                    %check for 3+ HP and no SotR buff, if so cast SotR
                    if ( hp>=3 || tob(idDPBuff)>0 ) && tob(idSotRcd)<=0 && tob(idSotR)<=0
                        %set SotR CD, give 3 seconds of DR, 20s of BoG
                        tob(idSotRcd)=1.5;
                        tob(idSotR)=3;
                        tob(idBoG)=20;
                        %Consume Divine Purpose proc if it exists
                        if tob(idDPBuff)>0
                           tob(idDPBuff)=0; 
                        %otherwise, consume 3 HP
                        elseif hp>=3
                            hp=hp-3;
                        %Just in case - debugging
                        else
                            error('WTF')
                        end
                        %Divine Purpose procs
                        if rand<dpProcRate
                            tob(idDPBuff)=dpBuffDuration;
                        end
                    end
                    
            end %close switch
                                        
        end %close event for

    end %close event if
        
    
    %% Debugging
    debugS(k,1)=tob(idSotR);
    debugSotR(k,1)=tob(idSotRcd);
    debugHP(k,1)=hp;
    
    %increment time by decreasing tob and tbe
    tbe=tbe-dt;
    tob=tob-dt;
end
toc

%% compile for plots
dmg=damage(find(damage>=0));

S=sum(debugS>0)./length(debugS);
avoids=sum(dmg==0);
avoidspct=avoids./length(dmg);
blocks=sum(dmg==0.7);
blockspct=blocks./length(dmg);
dr1=sum(dmg==0.5);
dr1pct=dr1./length(dmg);
dr2=sum(dmg==0.5.*0.7);
dr2pct=dr2./length(dmg);
hits=sum(dmg==1);
hitspct=hits./length(dmg);


Tsotr = max(t)./sum(debugS==3);
Rsotr = 1/Tsotr;
Rhpg=sum(debugHPG>0)/max(t);

DTPS=sum(dmg)./max(t);

if ~strcmp(plotFlag,'noplot')
figure(1)
hist(dmg,[0:0.05:1])
xlim([-0.1 1.1])
text(-0.05,avoids.*1.05,[num2str(avoidspct.*100,'%2.1f') '%'])
text(0.7-0.05,blocks.*1.05,[num2str(blockspct.*100,'%2.1f') '%'])
text(0.5-0.05,dr1.*1.05,[num2str(dr1pct.*100,'%2.1f') '%'])
text(0.7.*0.5-0.05,dr2.*1.05,[num2str(dr2pct.*100,'%2.1f') '%'])
text(1-0.05,hits.*1.05,[num2str(hitspct.*100,'%2.1f') '%'])
title(['T=' int2str(simTime./60) ' min, S=' num2str(S.*100,'%2.1f') '%, Tsotr=' num2str(Tsotr,'%2.1f') ', DTPS=' num2str(DTPS.*100,'%2.2f')])
end

statblock.S=S;
statblock.Tsotr=Tsotr;
statblock.Rhpg=Rhpg;

end