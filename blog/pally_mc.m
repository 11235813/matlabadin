function [DTPS statblock]=pally_mc(stat,val,simMins,plotFlag,tocFlag,statSetup)
dhit=0;dexp=0;dhaste=0;dmastery=0;ddodge=0;dparry=0;
if nargin<6
    plotNum=1;
else
    plotNum=statSetup.plotNum;
end
if nargin<5
    tocFlag='toc';
end
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
        case 'parry'
            dparry=val;
    end
    
    
end

%% Initialize different random streams
RandStream.setDefaultStream ...
     (RandStream('mt19937ar','seed',sum(100*clock)));
 
%% Player stats
if nargin<6
    buffedStr=9208;
    parryRating=4834;
    dodgeRating=4892;
    masteryRating=6758;
    hitRating=900;
    expRating=1777;
    hasteRating=621;
else
    buffedStr=statSetup.buffedStr;
    parryRating=statSetup.parryRating;
    dodgeRating=statSetup.dodgeRating;
    masteryRating=statSetup.masteryRating;
    hitRating=statSetup.hitRating;
    expRating=statSetup.expRating;
    hasteRating=statSetup.hasteRating;
end

%artificially set hit/exp to zero
% hitRating=0;
% expRating=0;

%% Define constants/variables
bossSwingTimer=1.5;
Cd=65.631440;
Cp=236.1;
Cb=149.1;
k=0.885;
gcProcRate=0.2;
gcBuffDuration=6.3;
% dpProcRate=0.25;
dpProcRate=0;
dpBuffDuration=8;


%% calculate stats
mastery=8+(masteryRating+dmastery)./600;
blockCS=3+10+1./(1./Cb+k./mastery);
miss=0;
dodgeCS=5.01+1./(1./Cd+k./((dodgeRating+ddodge)./885));
parryCS=3.19+1./(1./Cp+k./((buffedStr-178)./951.16+(parryRating+dparry)./885));

avoidance=(dodgeCS+parryCS-9)./100;
block=(blockCS-4.5)./100;

DRmod=1-0.3-mastery./100;

haste=(hasteRating+dhaste)./425./100;

hit=(hitRating+dhit)./340./100;
exp=(expRating+dexp)./340./100;

miss=max(0,0.075-hit);
dodge=max(0,(0.075-exp));
parry=max(0,(0.075-max((exp-0.075),0)));


%initialize Holy Power
hp=0;

%% Define events, cooldowns and buffs to track
events={'Boss Swing Timer','GCD'};
tbe = zeros(size(events));
idBossSwing=1;
idGCD=2;
%start boss swing timer at 0.5 seconds, just to de-synch from GCD
%not strictly necessary, I think, as HP generation should shuffle SotR
%around significantly, but just to be safe...
tbe(1)=0.5;

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

%preallocate arrays
N=floor(simTime.*steps_per_sec);
dt=1./steps_per_sec;
t=zeros(N,1);
damage=-1.*ones(N,1);
SotRUptime=t;debugG=t;debugHP=t;SotRUptimeotR=t;debugHPG=t;

%tracking
avoids=0;
blocks=0;
hits=0;
mits=0;
bMits=0;
hMits=0;

%%for loop to do event handling
tic
for k=1:N
        
    %record time
    t(k)=(k-1).*dt;
    
    %figure out if any of the event timers is 0 or less
    ids=find(tbe<=0);
    
    %event handling
    for j=1:length(ids)
        
        switch ids(j)
            
            %if the GCD timer is up, see if there's something to cast
            case idGCD
                
                %if SotR can be cast, do so
                castSotRIfAble();
                
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
                    if rand<(1-miss)
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
                
                %boss swing
            case idBossSwing
                
                %if SotR can be cast, do so
                castSotRIfAble();
                
                %reset boss swing timer
                tbe(idBossSwing)=bossSwingTimer;
                
                %check for avoid
                if rand < avoidance
                    damage(k)=0;
                    avoids=avoids+1;
                    
                %now check for block
                elseif rand < block
                    blocks=blocks+1;
                    if tob(idSotR)>0
                        mits=mits+1;
                        bMits=bMits+1;
                        damage(k)=0.7.*DRmod;
                    else
                        damage(k)=0.7;
                    end
                %and finally, normal hits
                else
                    hits=hits+1;
                    if tob(idSotR)>0
                        mits=mits+1;
                        hMits=hMits+1;
                        damage(k)=DRmod;
                    else
                        damage(k)=1;
                    end
                end
                
        end %close switch
        
        
    end %close event for
    
    %     end %close event if
        
    
    %% Debugging
    SotRUptime(k,1)=tob(idSotR);
%     SotRUptimeotR(k,1)=tob(idSotRcd);
    debugHP(k,1)=hp;
    
    %increment time by decreasing tob and tbe
    tbe=tbe-dt;
    tob=tob-dt;
    
    %fix SotR at 0
    tob(idSotR)=max(tob(idSotR),0);
end
if ~strcmp(tocFlag,'notoc')
    toc
end

%% compile for plots
dmg=damage(damage>=0);

%sanity check
if hits+blocks+avoids~=length(dmg)
    error('reporting error, length(dmg) doesn''t match number of events')
else
    numEvents=length(dmg);
end

S=sum(SotRUptime>0)./length(SotRUptime);
% avoids=sum(dmg==0);

avoidsPct=avoids./numEvents;
blocksPct=blocks./numEvents;
hitsPct=hits./numEvents;
mitsPct=mits./numEvents;
unmitsPct=(hits-hMits)./numEvents;
bMitsPct=bMits./numEvents;
hMitsPct=hMits./numEvents;

Tsotr = max(t)./sum(SotRUptime==3);
Rsotr = 1/Tsotr;
Rhpg=sum(debugHPG>0)/max(t);

DTPS=sum(dmg)./max(t);
maDTPS=filter(ones(1,5)./5,1,dmg);
mean_ma=mean(maDTPS);
std_ma=std(maDTPS);

if ~strcmp(plotFlag,'noplot')
    figure(1+2.*(plotNum-1))
    [yout xout]=hist(100.*dmg,100.*[0:0.05:1]);
    if max(yout)>1e3
        sf=1e3;
        ylstr='Number of events (in thousands)';
    else
        sf=1;
        ylstr='Number of events';
    end
    youtn=yout./sf;
    bar(xout,youtn);
    xlim([-10 110])
    ylim([0 1.25.*max(youtn)])
    xlabel('Hit size (in % of full hit)')
    ylabel(ylstr)   
    title(['T=' int2str(simTime./60) ' min, S=' num2str(S.*100,'%2.1f') '%, Tsotr=' num2str(Tsotr,'%2.1f') ', DR_{SotR}=' num2str(100.*(1-DRmod),'%2.1f') '%, DTPS=' num2str(DTPS.*100,'%2.2f')])

    %labeling
    offset=diff(get(gca,'YLim'))./20;
        
    text(-7,youtn(xout==0)+offset,[num2str(avoidsPct.*100,'%2.1f') '% avoids'])
    
    text(100*0.7*DRmod-5,youtn(xout==70*round(DRmod*20)/20)+2.*offset,[num2str(bMitsPct.*100,'%2.1f') '%'])
    text(100*0.7*DRmod-15,youtn(xout==70*round(DRmod*20)/20)+offset,'mitigated blocks')
    
    text(100.*DRmod-7,youtn(xout==100*round(20*DRmod)/20)+2.*offset,[num2str(hMitsPct.*100,'%2.1f') '%'])
    text(100.*DRmod-12,youtn(xout==100*round(20*DRmod)/20)+offset,'mitigated hits')
    
    text(70-5,youtn(xout==70)+2.*offset,[num2str((blocksPct-bMitsPct).*100,'%2.1f') '%'])
    text(70-15,youtn(xout==70)+offset,'unmitigated blocks')
    
    text(100-5,youtn(xout==100)+2.*offset,[num2str(unmitsPct.*100,'%2.1f') '%'])
    text(100-18,youtn(xout==100)+offset,'unmitigated hits')
    
    figure(2+2.*(plotNum-1))
    [yout2 xout2]=hist(maDTPS,50);
    yout2n=yout2.*100./length(maDTPS);
    bar(xout2,yout2n);
    xlabel('5-attack moving average DTPS')
    ylabel('Percentage of events')
    title(['T=' int2str(simTime./60) ' min, S=' num2str(S.*100,'%2.1f') '%, Tsotr=' num2str(Tsotr,'%2.1f') ', DR_{SotR}=' num2str(100.*(1-DRmod),'%2.1f') '%, DTPS=' num2str(DTPS.*100,'%2.2f')])
    temp=get(gca,'YLim');mval=temp(2);
    text(0.1,0.8*mval,['mean = ' num2str(mean_ma,'%1.4f')]);
    text(0.1,0.73*mval,['std  = ' num2str(std_ma,'%1.4f')]);
    
    pause(1)
end

statblock.S=S;
statblock.Tsotr=Tsotr;
statblock.Rhpg=Rhpg;
statblock.block=block;
statblock.avoidance=avoidance;
statblock.avoids=avoids;
statblock.blocks=blocks;
statblock.hits=hits;
statblock.mits=mits;
statblock.hMits=hMits;
statblock.bMits=bMits;
statblock.avoidsPct=avoidsPct;
statblock.blocksPct=blocksPct;
statblock.hitsPct=hitsPct;
statblock.mitsPct=mitsPct;
statblock.unmitsPct=unmitsPct;
statblock.hMitsPct=hMitsPct;
statblock.bMitsPct=bMitsPct;
statblock.meanma=mean_ma;
statblock.stdma=std_ma;
statblock.dmg=dmg;
statblock.maDTPS=maDTPS;


    function castSotRIfAble()
        
        %check for 3+ HP and no SotR buff, if so cast SotR
        if ( hp>=3 || tob(idDPBuff)>0 ) && tob(idSotRcd)<=0 && tob(idSotR)<=0
            %set SotR CD, give 3 seconds of DR, 20s of BoG
            tob(idSotRcd)=1.5;
            tob(idSotR)=tob(idSotR)+3;
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
    end

end