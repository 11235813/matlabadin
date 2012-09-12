function [DTPS statblock]=warr_mc(stat,val,simMins,plotFlag,tocFlag,startCond)
dhit=0;dexp=0;dhaste=0;dmastery=0;ddodge=0;dparry=0;
if nargin<6
    startCond.rage=0;
    startCond.prio='steadystate';
    startCond.stepspersecond=2;
    startCond.finisher='SBrBleed';
end
if nargin<5
    tocFlag='toc';
end
if nargin<4
    plotFlag='plot';
end
if nargin<3
    simMins=1000;
end
if nargin<2
    val=1000;
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

%other
meta=1; %toggle for block meta, 1 is on, 0 is off
blockDmg=1-(0.3+meta./100);
critBlockDmg=1-2.*(0.3+meta./100);
armorMit=1-0.45;
specMit=1-0.25;
wbMit=0.9;
%% Define constants/variables
bossSwingTimer=1.5;
bossRawSwingDamage=250000;
Cd=91.42;
Cp=237.1;
Cb=149.1;
k=0.956;
SnBProcRate=0.3;
SnBBuffDuration=5;

%Vengeance info
bossSwingDamage=bossRawSwingDamage.*armorMit.*specMit.*wbMit;
avgVengAP=0.4*(bossRawSwingDamage./bossSwingTimer);
shieldBarrierAbsorb=2*(1.1.*avgVengAP+0.2.*buffedStr)./bossSwingDamage;

%% calculate stats
mastery=17.6+(masteryRating+dmastery).*2.2./600;
blockCS=3+10+meta+1./(1./Cb+k./(mastery.*0.5./2.2));
critBlock=(meta+mastery)./100;
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
tbe(1)=0.4;

buffs={'SB duration','SB charge 1','SB charge 2','SnB duration','WB duration','SS cooldown',...
       'Rev cooldown','BS cooldown','Tclap cooldown','CBE cd','Berserker Rage CD','SBr duration','SBr cd'};
tob = zeros(size(buffs));
idSB=1;
idSBcd1=2;
idSBcd2=3;
idSnB=4;
idWB=5;
idSScd=6;
idRcd=7;
idBScd=8;
idTCcd=9;
idCBEcd=10;
idBRcd=11;
idSBr=12;
idSBrcd=13;

simTime=simMins*60;
steps_per_sec=startCond.stepspersecond;

%preallocate arrays
N=floor(simTime.*steps_per_sec);
dt=1./steps_per_sec;
t=zeros(N,1);
damage=-1.*ones(N,1);
SBUptime=t;
WBUptime=t;
SBCasts=0;
SBrCasts=0;
rageGain=0;
dsRage=0;
xsRage=0;
SBrAmount=0;

%tracking
avoids=0;
fullAbsorbs=0;
blocks=0;
critblocks=0;
hits=0;
fullHits=0;
fullCBAbsorbs=0;
partialCBAbsorbs=0;
fullBAbsorbs=0;
partialBAbsorbs=0;
partialAbsorbs=0;
fullHitAbsorbs=0;

%%for loop to do event handling
tic
for k=1:N
    
    %record time
    t(k)=(k-1).*dt;
    
    %figure out if any of the event timers is 0 or less
    ids=find(tbe<=0);
    
    
    
    %event handling
    for j=1:length(ids)
                
        %Berserker Rage - use if available
        if tob(idBRcd)<=0 && rage<110
            %set BR cooldown, start GCD
            tob(idBRcd)=30;
            %add rage
            rage=rage+10;
            rageGain=rageGain+10;
        end
        
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
                
                %check for 60+ rage; if so cast SB
                finisherCast(startCond.finisher);
                
                gcdPriority(startCond.prio)
                                
                %enforce rage bounds - only need one to cover all of the
                %possible GCD cast choices
                if rage>120
                    xsRage=xsRage+(rage-120);
                    rage=min([rage 120]);
                end
            
            %boss swing
            case idBossSwing
                
                %update SBr
                if tob(idSBr)<=0
                    SBrAmount=0;
                end
                
                %check for 60+ rage; if so cast SB
                finisherCast(startCond.finisher);
                
                %reset boss swing timer
                tbe(idBossSwing)=bossSwingTimer;
                
                %check for avoid
                if rand < avoidance
                    damage(k)=0;
                    %reset Revenge CD
                    tob(idRcd)=0;
                    avoids=avoids+1;
                else
                    %figure out damage value.  If SB is up or we block,
                    %set to 0.7 or 0.4.  Otherwise, set to 1.
                    if tob(idSB)>0 || rand < block
                        blocks=blocks+1;
                        %check for crit block
                        if rand < critBlock
                            critblocks=critblocks+1;
                            if SBrAmount>=critBlockDmg
                                damage(k)=0;
                                SBrAmount=SBrAmount-critBlockDmg;
                                fullAbsorbs=fullAbsorbs+1;
                                fullCBAbsorbs=fullCBAbsorbs+1;
                            else
                                if SBrAmount>0
                                    partialCBAbsorbs=partialCBAbsorbs+1;
                                end
                                damage(k)=critBlockDmg-SBrAmount;
                                SBrAmount=0;
                            end
                            %gain rage
                            if tob(idCBEcd)<=0
                                rage=rage+10;
                                rageGain=rageGain+10;
                                tob(idCBEcd)=3;
                            end
                        %otherwise, normal block
                        else
                            if SBrAmount>=blockDmg
                                damage(k)=0;
                                SBrAmount-SBrAmount-blockDmg;
                                fullAbsorbs=fullAbsorbs+1;
                                fullBAbsorbs=fullBAbsorbs+1;
                            else
                                damage(k)=blockDmg-SBrAmount;
                                if SBrAmount>0
                                    partialBAbsorbs=partialBAbsorbs+1;
                                end
                                SBrAmount=0;
                            end
                        end
                    else
                        hits=hits+1;
                        damage(k)=1-SBrAmount;
                        if SBrAmount>1
                            fullAbsorbs=fullAbsorbs+1;
                            fullHitAbsorbs=fullHitAbsorbs+1;
                        end
                        if SBrAmount>0
                            partialAbsorbs=partialAbsorbs+1;
                            SBrAmount=0;
                        else
                            fullHits=fullHits+1;                            
                        end
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
    WBUptime(k,1)=tob(idWB);
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
% avoids=sum(dmg==0);
avoidspct=avoids./length(dmg);
% b1=sum(dmg==0.7);
b1=blocks-critblocks;
b2=critblocks;
% b2=sum(dmg==0.4);
% blocks=b1+b2;
b1pct=b1./length(dmg);
b2pct=b2./length(dmg);
blockspct=blocks./length(dmg);
% hits=sum(dmg==1);
hitspct=hits./length(dmg);
fullAbsorbspct=fullAbsorbs./length(dmg);
fullCBAbsorbspct=fullCBAbsorbs./length(dmg);
fullBAbsorbspct=fullBAbsorbs./length(dmg);
partialBAbsorbspct=partialBAbsorbs./length(dmg);
partialAbsorbspct=partialAbsorbs./length(dmg);
fullHitspct=fullHits./length(dmg);
fullHitAbsorbspct=fullHitAbsorbs./length(dmg);
partialCBAbsorbspct=partialCBAbsorbs./length(dmg);


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
    ylim([0 1.25.*max(yout)./sf])
    xlabel('Hit size (in % of full hit)')
    ylabel(ylstr)
    offset=diff(get(gca,'YLim'))./20;
    text(-7,(avoids+fullAbsorbs)./sf+offset,[num2str(avoidspct.*100,'%2.1f') '% avoids'])
    text(-7,(avoids+fullAbsorbs)./sf,[num2str(fullAbsorbspct.*100,'%2.2f') '% full Absorbs'])
  
    text(100.*critBlockDmg-10,(b2+partialBAbsorbs+partialAbsorbs)./sf+2*offset,[num2str(b2pct.*100,'%2.1f') '% crit blocks'])
    text(100.*critBlockDmg-10,(b2+partialBAbsorbs+partialAbsorbs)./sf+offset,[num2str(partialCBAbsorbspct.*100,'%2.2f') '% partially absorbed'])
    text(100.*critBlockDmg-10,(b2+partialBAbsorbs+partialAbsorbs)./sf,[num2str(fullCBAbsorbspct.*100,'%2.2f') '% fuly absorbed'])
   
    text(100.*blockDmg-15,(b1+partialAbsorbs)./sf+2*offset,[num2str(b1pct.*100,'%2.1f') '% blocked'])
    text(100.*blockDmg-15,(b1+partialAbsorbs)./sf+offset,[num2str(partialBAbsorbspct.*100,'%2.2f') '% partially absorbed'])
    text(100.*blockDmg-15,(b1+partialAbsorbs)./sf,[num2str(fullBAbsorbspct.*100,'%2.2f') '% fully absorbed'])

    text(100-20,(fullHits+partialAbsorbs)./sf+2*offset,[num2str(hitspct.*100,'%2.1f') '% full hits'])
    text(100-20,(fullHits+partialAbsorbs)./sf+offset,[num2str(partialAbsorbspct.*100,'%2.2f') '% partially absorbed'])
    text(100-20,(fullHits+partialAbsorbs)./sf,[num2str(fullHitAbsorbspct.*100,'%2.2f') '% fully absorbed'])
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
statblock.SBCasts=SBCasts;
statblock.SBrCasts=SBrCasts;


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

    function shieldBarrierCast()
        if (rage>=60) && tob(idSBrcd)<=0
            %give 6 seconds of SBr
            tob(idSBr)=6;
            %set absorb value
            SBrAmount=shieldBarrierAbsorb;
            %consume rage
            rage=rage-60;
            %track for cast rate
            SBrCasts=SBrCasts+1;
        end
    end

    function finisherCast(finisher)
        
        if strcmp(finisher,'SBonly')
            shieldBlockCast()
        elseif strcmp(finisher,'SBronly')
            shieldBarrierCast()
        else %use SBarr to bleed rage >100
            if rage>=100
                shieldBarrierCast()
            else
                shieldBlockCast()
            end
        end
        
    end

    function gcdPriority(prio)
        if strcmp(prio,'short') %30-second priority
            
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
            
        else %default priority, SS>Rev>BS>BR>TC>Dev
            
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
                %Thunder Clap - use if WB isn't up
                elseif tob(idWB)<=0 && tob(idTCcd)<=0
                    %set TC cooldown, start GCD
                    tob(idTCcd)=6;
                    tbe(idGCD)=1.5;
                    %check for hit
                    if rand<(1-miss-dodge)
                        %apply WB
                        tob(idWB)=30;
                    end
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
        end
       
        
    end

end