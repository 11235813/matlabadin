function [cps ecps hpg] = action2cps(c,j)
%ACTION2CPS takes the actionPr returned by memoized_fsm and converts them
%into a standardized "cast per second" array, including both active and
%passive sources.
%
%A2CPS takes one required input ("c", the configuration structure) and one
%optional input ("j", the iteration number for calculations where mdf.mehit
%or mdf.sphit or player.wswing are not singleton).
%
%A2CPS returns three outputs:
% cps - which is the cps array for the given input conditions.
% ecps - which is the multiplier that accounts for AW/BoG/etc
% hpg - which is the holy power generation rate based on the cps data

%% smart array handling
%j could refer to mdf.mehit, mdf.sphit, player.sphaste, or player.wswing.  
%This section sorts out which is which

%assume all arrays are singleton
jme=1;
jra=1;
jws=1;
jha=1;
jss=1;
jef=1;
jaw=1;

%handle non-singleton arrays
if length(c.mdf.mehit)>1
    jme=j;
end
if length(c.mdf.rahit)>1
    jra=j;
end
if length(c.player.wswing)>1
    jws=j;
end
if length(c.player.sphaste)>1
    jha=j;
end
if length([c.rot.uptime.ss])>1
    jss=j;
end
if length([c.rot.uptime.ef])>1
    jef=j;
end
if length([c.rot.uptime.aw])>1
    jaw=j;
end

%% CPS conversions    

%initialize cps vector
cps=zeros(size(c.abil.val.label,1),1);
ecps=cps;
hpg=0;

%sort actionPr entries into cps
for m=1:size(c.rot.actionPr,2)
    %reset GC temp var
    asgc=0;
    hpmod=1;
    
    %separate string into components
    match=regexp(c.rot.actionPr{1,m},'\w*','match');
    
    %grab the CPS value
    cpsval=c.rot.actionPr{2,m};
    
    %sanity check
    if length(match)<1
        error('regexp match failed on actionPr')
    end
    
    %strip out any numeric modifiers
    tok=regexp(match{1},'[a-zA-Z]*|\d','match');
    abil=tok{1};hpval=3;
    if length(tok)>1
        hpval=tok(2);
    end
    
    %find the index of the ability
    idx= strcmpi(abil,c.abil.val.label);
    
    %add this to the CPS tally
    cps(idx)=cps(idx)+cpsval;
    
    %compile ecps modifier
    emod=hpval./3;
    
    %handle extra qualifiers
    for q=2:length(match)
        %text and number (bog)
        switch match{q}
            case 'GC'
                asgc=cpsval;
            case {'BoG1','BoG2','BoG3','BoG4','BoG5'}
                %strip number
                bogval=str2double(match{q}(length(match{q})));
                emod=emod.*(1+(0.1+c.player.mast./100).*bogval);
            case 'AW'
                emod=emod.*1.2;
            case 'HA'
                hpmod=3;
            case 'GoWoG'
                emod=emod.*1.1;
        end
           
    end
    ecpsval=cpsval.*emod;
    
    %combine qualifiers
    ecps(idx)=ecps(idx)+ecpsval;

    %% Handle special cases (seals, etc.)
    sealidx=find(strcmpi(c.exec.seal,c.abil.val.label));
    
    switch abil
        case 'CS'
            %seals, hpg
            cps(sealidx)=cps(sealidx)+cpsval;
            ecps(sealidx)=ecps(sealidx)+ecpsval.*c.mdf.mehit(jme);
            hpg=hpg+cpsval.*c.mdf.mehit(jme).*hpmod;
        case 'HotR'
            %seals, hpg
            cps(sealidx)=cps(sealidx)+cpsval;
            ecps(sealidx)=ecps(sealidx)+ecpsval.*c.mdf.mehit(jme);
            hpg=hpg+cpsval.*c.mdf.mehit(jme).*hpmod;
            %HammerNova
            idx=find(strcmpi('HaNova',c.abil.val.label));
            cps(idx)=cpsval;
            ecps(idx)=ecpsval;
        case 'J'
            %seals (only procs SoT), hpg
            if sealidx==find(strcmpi('SoT',c.abil.val.label))
                cps(sealidx)=cps(sealidx)+cpsval;
                ecps(sealidx)=ecps(sealidx)+ecpsval.*c.mdf.mehit(jme);
            end
            hpg=hpg+cpsval.*c.mdf.rahit(jra).*hpmod;
        case 'SotR'
            %seals
            cps(sealidx)=cps(sealidx)+cpsval;
            ecps(sealidx)=ecps(sealidx)+ecpsval.*c.mdf.mehit(jme);
        case 'AS'
            %hpg from GC
            hpg=hpg+asgc.*hpmod;
        case 'SS'
            %uptime-based, not cast-based
            cps(idx)=c.rot.uptime(jss).ss./6;
            ecps(idx)=c.rot.uptime(jss).ss./6; %no modifiers on absorbs
    end

end

%% Melee
%Melee swings
cps(strcmpi('Melee',c.abil.val.label))=1./c.player.wswing(jws);
ecps(strcmpi('Melee',c.abil.val.label))=(1+0.2.*c.rot.uptime(jaw).aw)./c.player.wswing(jws);
%seal procs
cps(sealidx)=cps(sealidx)+1./c.player.wswing(jws);
ecps(sealidx)=ecps(sealidx)+(1+0.2.*c.rot.uptime(jaw).aw).*c.mdf.mehit(jme)./c.player.wswing(jws);

%% Censure
cps(strcmpi('Censure',c.abil.val.label))= 1./c.player.censTick(jha);
ecps(strcmpi('Censure',c.abil.val.label))= (1+0.2.*c.rot.uptime(jaw).aw)./c.player.censTick(jha);

%% EF(HoT)
%not affected by BoG, assume average overlap with AW, 
%TODO: check that ticks are not haste-affected
%TODO: this doesn't account for low-HP EF casts
cps(strcmpi('EF(HoT)',c.abil.val.label))=c.rot.uptime(jef).ef./3;
ecps(strcmpi('EF(HoT)',c.abil.val.label))=c.rot.uptime(jef).ef./3.*(1+0.2.*c.rot.uptime(jaw).aw);

end