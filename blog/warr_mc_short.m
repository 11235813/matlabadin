function [DTPS statblock]=warr_mc(stat,val,simMins,plotFlag,tocFlag,startCond)
dhit=0;dexp=0;dhaste=0;dmastery=0;ddodge=0;dparry=0;
if nargin<6
    startCond.rage=0;
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
buffedStr=9208;
parryRating=4834;
dodgeRating=4892;
masteryRating=6758;
hitRating=1521;
expRating=1777;
hasteRating=0;

%toggle off hit/exp
hitRating=0;
expRating=0;

%% Define constants/variables
bossSwingTimer=1.5;
Cd=91.42;
Cp=237.1;
Cb=149.1;
k=0.956;
kb=0.885;
SnBProcRate=0.2;
SnBBuffDuration=6.3;


%% calculate stats
mastery=17.6+(masteryRating+dmastery)./272.6;
blockCS=3+10+1./(1./Cb+kb./(mastery./4.75));
critBlock=mastery./100;
miss=0;
dodgeCS=5.01+1./(1./Cd+k./((dodgeRating+ddodge)./885));
parryCS=3.21+1./(1./Cp+k./((buffedStr-203)./951.16+(parryRating+dparry)./885));

avoidance=(dodgeCS+parryCS-9)./100;
block=(blockCS-4.5)./100;

% DRmod=1-0.3-mastery./100;

haste=(hasteRating+dhaste)./425./100;

hit=(hitRating+dhit)./340./100;
exp=(expRating+dexp)./340./100;

miss=max(0,0.075-hit);
dodge=max(0,(0.075-exp));
parry=max(0,(0.075-max((exp-0.075),0)));


%initialize Rage
rage=startCond.rage;

%% Define events, cooldowns and buffs to track
events={'Boss Swing Timer','GCD'};
tbe = zeros(size(events));
idBossSwing=1;
idGCD=2;
%start boss swing timer at 0.5 seconds, just to de-synch from GCD
%not strictly necessary, I think, as rage generation should shuffle SB
%around significantly, but just to be safe...
tbe(1)=0.5;

buffs={'SB duration','SB charge 1','SB charge 2','SnB duration','WB duration','SS cooldown',...
       'Rev cooldown','BS cooldown','Tclap cooldown','CBE cd'};
tob = zeros(size(buffs));
idSB=1;
idSBcd1=2;
idSBcd2=3;
idSnB=4;
idSScd=5;
idRcd=6;
idBScd=7;
idBRcd=8;
idCBEcd=9;

simTime=simMins*60;
steps_per_sec=10;

%preallocate arrays
N=floor(simTime.*steps_per_sec);
dt=1./steps_per_sec;
t=zeros(N,1);
damage=-1.*ones(N,1);
SBUptime=t;
WBUptime=t;
SBCasts=0;
rageGain=0;
dsRage=0;
xsRage=0;

%%for loop to do event handling
tic
for k=1:N
    
    %record time
    t(k)=(k-1).*dt;
    
    %figure out if any of the event timers is 0 or less
    ids=find(tbe<=0);
    
    
    
    %event handling
    for j=1:length(ids)
        
        %if anything is happening, check off-GCD things
        
        %check for 60+ rage; if so cast SB
        shieldBlockCast();
        
        %Berserker Rage - use if available
        if tob(idBRcd)<=0 && rage<110 %don't over-cap
            %set BR cooldown, start GCD
            tob(idBRcd)=30;
            %add rage
            rage=rage+10;
            rageGain=rageGain+10;
        end          
                   
        %now handle the two types of events
        switch ids(j)
            
            %if the GCD timer is up, see if there's something to cast
            case idGCD
                
                %Defensive Stance
                dsRage=dsRage+0.5;
                if dsRage==1
                    rage=rage+1;
                    rageGain=rageGain+1;
                    dsRage=0;
                end
                
                
                %SS is first priority
                if tob(idSScd)<=0
                    %put SS on cooldown, start GCD
                    tob(idSScd)=6;
                    tbe(idGCD)=1.5;
                    %Check for hit
                    if rand<(1-miss-dodge-parry)
                        %success! grant rage
                        rage=rage+20;
                        rageGain=rageGain+20;
                        %consume Sword and Board
                        if tob(idSnB)>0
                            rage=rage+5;
                            rageGain=rageGain+5;
                            tob(idSnB)=0;
                        end
                    end
                %Rev is second priority, check for cooldown and don't use
                %if SS cd is almost up
                elseif tob(idRcd)<=0 && tob(idSScd)>=0.2
                    %set R cooldown, start GCD
                    tob(idRcd)=9;
                    tbe(idGCD)=1.5;
                    %check for hit
                    if rand<(1-miss-dodge-parry)
                        %success! grant rage, enforce bounds
                        rage=rage+15;
                        rageGain=rageGain+15;
                    end
                %Battle Shout - use on cooldown if it won't cap rage
                elseif tob(idBScd)<=0 && rage<=100;
                    %set BS cooldown, start GCD
                    tob(idBScd)=60;
                    tbe(idGCD)=1.5;
                    %add rage
                    rage=rage+20;
                    rageGain=rageGain+20;
                %Dev - use if empty and nothing else was used. Hold if we
                %somehow caused a near-clash with SS
                elseif tob(idSScd)>=0.2
                    %start GCD
                    tbe(idGCD)=1.5;
                    %check for hit
                    if rand<(1-miss-dodge-parry)
                        %success! check for Sword and Board
                        if rand<SnBProcRate
                            %success! grant SnB buff
                            tob(idSnB)=SnBBuffDuration;
                        end
                    end
                end
                
                %enforce rage bounds - only need one to cover all of the
                %possible GCD cast choices
                if rage>120
                    xsRage=xsRage+(rage-120);
                    rage=min([rage 120]);
                end
            
            %boss swing
            case idBossSwing
                                
                %reset boss swing timer
                tbe(idBossSwing)=bossSwingTimer;
                
                %check for avoid
                if rand < avoidance
                    damage(k)=0;
                    %reset Revenge CD
                    tob(idRcd)=0;
                else
                    %figure out damage value.  If SB is up or we block,
                    %set to 0.7 or 0.4.  Otherwise, set to 1.
                    if tob(idSB)>0 || rand < block
                        %check for crit block
                        if rand < critBlock
                            damage(k)=0.4;
                            %gain rage
                            if tob(idCBEcd)<=0
                                rage=rage+10;
                                rageGain=rageGain+10;
                                tob(idCBEcd)=3;
                            end
                        %otherwise, normal block
                        else
                            damage(k)=0.7;
                        end
                    else
                        damage(k)=1;
                    end
                    %enforce rage bounds
                    if rage>120
                        xsRage=xsRage+(rage-120);
                        rage=min([rage 120]);
                    end
                end
                
                %Debugging
%                 if rage==120
%                     warning('Rage overflow')
%                 end
                
        end %close switch
        
    end %close event for
    
    
    
    %% Debugging
    SBUptime(k,1)=tob(idSB);
%     WBUptime(k,1)=tob(idWB);
%     SotRUptimeotR(k,1)=tob(idSotRcd);
%     debugHP(k,1)=hp;
    
    %increment time by decreasing tob and tbe
    tbe=tbe-dt;
    tob=tob-dt;
    
    %fix SotR at 0
    tob(idSB)=max(tob(idSB),0);
end
if ~strcmp(tocFlag,'notoc')
    toc
end

%% compile for plots
dmg=damage(damage>=0);

S=sum(SBUptime>0)./length(SBUptime);
avoids=sum(dmg==0);
avoidspct=avoids./length(dmg);
b1=sum(dmg==0.7);
b2=sum(dmg==0.4);
blocks=b1+b2;
b1pct=b1./length(dmg);
b2pct=b2./length(dmg);
blockspct=blocks./length(dmg);
hits=sum(dmg==1);
hitspct=hits./length(dmg);


Tsb = max(t)./SBCasts;
Rsb = 1/Tsb;
Rrage=rageGain./max(t);

DTPS=sum(dmg)./max(t);
maDTPS=filter(ones(1,5)./5,1,dmg);
mean_ma=mean(maDTPS);
std_ma=std(maDTPS);

if ~strcmp(plotFlag,'noplot')
    figure(1)
    [yout xout]=hist(100.*dmg,100.*[0:0.05:1]);
    if max(yout)>1e3
        sf=1e3;
        ylstr='Number of events (in thousands)';
    else
        sf=1;
        ylstr='Number of events';
    end
    bar(xout,yout./sf);
    xlim([-10 110])
    ylim([0 1.15.*max(yout)./sf])
    xlabel('Hit size (in % of full hit)')
    ylabel(ylstr)
    text(-5,avoids.*1.075./sf,[num2str(avoidspct.*100,'%2.1f') '%'])
    text(70-5,b1.*1.05./sf,[num2str(b1pct.*100,'%2.1f') '%'])
    text(40-5,b2.*1.1./sf,[num2str(b2pct.*100,'%2.1f') '%'])
    text(100-5,hits.*1.05./sf,[num2str(hitspct.*100,'%2.1f') '%'])
    title(['T=' int2str(simTime./60) ' min, S=' num2str(S.*100,'%2.1f') '%, Tsb=' num2str(Tsb,'%2.1f') 's, R_{rage}=' num2str(Rrage,'%2.3f') '/s, DTPS=' num2str(DTPS.*bossSwingTimer.*100,'%2.2f') '%'])
    
    figure(2)
    [yout2 xout2]=hist(maDTPS,50);
    bar(xout2,yout2./sf);
    title(['T=' int2str(simTime./60) ' min, S=' num2str(S.*100,'%2.1f') '%, Tsb=' num2str(Tsb,'%2.1f') 's, R_{rage}=' num2str(Rrage,'%2.3f') '/s, DTPS=' num2str(DTPS.*bossSwingTimer.*100,'%2.2f') '%'])
    temp=get(gca,'YLim');mval=temp(2);
    text(0.1,0.8*mval,['mean = ' num2str(mean_ma,'%1.4f')]);
    text(0.1,0.73*mval,['std  = ' num2str(std_ma,'%1.4f')]);
end

statblock.S=S;
statblock.Tsb=Tsb;
statblock.Rrage=Rrage;
statblock.block=block;
statblock.avoidance=avoidance;
statblock.rageGain=rageGain;
statblock.xsRage=xsRage;
statblock.blocked=blockspct;
statblock.avoided=avoidspct;
statblock.unmit=hitspct;
statblock.meanma=mean_ma;
statblock.stdma=std_ma;


    function shieldBlockCast()
        
        
        %check for 60+ rage; if so cast SB
        if ( rage>=60 ) && (tob(idSBcd1)<=0  || tob(idSBcd2)<=0)
            %give 6 seconds of SB
            tob(idSB)=tob(idSB)+6;
            %handle charges.  If both available, use #1
            if tob(idSBcd1)<=0 && tob(idSBcd2)<=0
                tob(idSBcd1)=9;
                %if only #1 is available, use it
            elseif tob(idSBcd1)<=0 && tob(idSBcd2)>0
                tob(idSBcd1)=9+tob(idSBcd2);
                %if only #2 is available, use it
            elseif tob(idSBcd2)<=0 && tob(idSBcd1)>0
                tob(idSBcd2)=9+tob(idSBcd1);
                %just in case - debugging
            else
                error('WTF')
            end
            %Consume rage
            rage=rage-60;
            %enforce minimum rage (shouldn't be necessary, but..)
            rage=max([rage;0]);
            %track for cast rate
            SBCasts=SBCasts+1;
        end
    end

end