function [cps ecpsd ecpsh hpg] = action2cps(c,j)
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
jjd=1;
jws=1;
jha=1;
jup=1;
% jss=1;
% jef=1;
% jaw=1;
% jwg=1;

%handle non-singleton arrays
if length(c.mdf.mehit)>1
    jme=j;
end
if length(c.mdf.jdhit)>1
    jjd=j;
end
if length(c.player.wswing)>1
    jws=j;
end
if length(c.player.sphaste)>1
    jha=j;
end
if length(c.rot.uptime)>1
    jup=1;
end
% if length([c.rot.uptime.ss])>1
%     jss=j;
% end
% if length([c.rot.uptime.ef])>1
%     jef=j;
% end
% if length([c.rot.uptime.aw])>1
%     jaw=j;
% end
% if length([c.rot.uptime.gowog1])>1
%     jwg=j;
% end

%% CPS conversions    

%initialize cps vector
cps=zeros(size(c.abil.val.label,1),1);
ecpsh=cps;
ecpsd=cps;
hpg=0;

%sort actionPr entries into cps
for m=1:size(c.rot.actionPr,2)
    %reset GC temp var
    asgc=0;
    hpmod=1;
    gchaflag=0;
    
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
    abil=tok{1};
    hpval=3;
    if length(tok)>1
        hpval=tok(2);
    end
    
    %find the index of the ability
    idx=strcmpi(abil,c.abil.val.label);
    
    %flag as damage or healing
    d=c.abil.val.dmg(idx)>0;
    h=c.abil.val.heal(idx)>0;
    
    %add this to the CPS tally
    cps(idx)=cps(idx)+cpsval;
    
    %compile ecps modifier
    emodd=hpval./3;
    emodh=hpval./3;
    
    %handle extra qualifiers
    for q=2:length(match)
        %text and number (bog)
        switch match{q}
            case 'GC'
                asgc=cpsval;
                gchaflag=1;
            case {'BoG1','BoG2','BoG3','BoG4','BoG5'}
                %strip number
                bogval=str2double(match{q}(length(match{q})));
                emodh=emodh.*(1+h.*c.mdf.BoG.*bogval); 
            case 'AW'
                emodd=emodd.*d.*(1+c.mdf.AW);
            case 'HA'
                hpmod=3;
                switch abil
                    case {'CS','J','HotR'}
                        emodd=emodd.*(1+c.mdf.HAdmg);
                    case 'AS'
                        if gchaflag %GC always comes before HA; AS only gets benefit if AS was cast w/ GC
                            emodd=emodd.*(1+c.mdf.HAdmg);
                        end
                end
            case 'GoWoG1'
                emodd=emodd.*(1+c.mdf.glyphWoG);
            case 'GoWoG2'
                emodd=emodd.*(1+2.*c.mdf.glyphWoG);
            case 'GoWoG3'
                emodd=emodd.*(1+3.*c.mdf.glyphWoG);
        end
           
    end
    
    
    %combine qualifiers
    ecpsd(idx)=ecpsd(idx)+cpsval.*emodd;
    ecpsh(idx)=ecpsh(idx)+cpsval.*emodh;

    %% Handle special cases (seals, etc.)
    sealidx=find(strcmpi(c.exec.seal,c.abil.val.label));
    censFlag=(strcmpi(c.exec.seal,'SoT') || strcmpi(c.exec.seal,'Truth'));
    
    switch abil
        case 'CS'
            %seals, hpg
            cps(sealidx)=cps(sealidx)+cpsval;
            ecpsd(sealidx)=ecpsd(sealidx)+cpsval.*emodd.*c.mdf.mehit(jme);
            ecpsh(sealidx)=ecpsh(sealidx)+cpsval.*emodh.*c.mdf.mehit(jme);
            hpg=hpg+cpsval.*c.mdf.mehit(jme).*hpmod;
        case 'HotR'
            %seals, hpg
            cps(sealidx)=cps(sealidx)+cpsval;
            ecpsd(sealidx)=ecpsd(sealidx)+cpsval.*emodd.*c.mdf.mehit(jme);
            ecpsh(sealidx)=ecpsh(sealidx)+cpsval.*emodh.*c.mdf.mehit(jme);
            hpg=hpg+cpsval.*c.mdf.mehit(jme).*hpmod;
            %HammerNova
            idx=find(strcmpi('HaNova',c.abil.val.label));
            cps(idx)=cpsval;
            ecpsd(idx)=cpsval.*emodd;
        case 'J'
            %seals (only procs SoT), hpg
            if sealidx==find(strcmpi('SoT',c.abil.val.label))
                cps(sealidx)=cps(sealidx)+cpsval;
                ecpsd(sealidx)=ecpsd(sealidx)+cpsval.*emodd.*c.mdf.jdhit(jjd);
                ecpsh(sealidx)=ecpsh(sealidx)+cpsval.*emodh.*c.mdf.jdhit(jjd);
            end
            hpg=hpg+cpsval.*c.mdf.jdhit(jjd).*hpmod;
        case 'SotR'
            %seals
            cps(sealidx)=cps(sealidx)+cpsval;
            ecpsd(sealidx)=ecpsd(sealidx)+cpsval.*emodd.*c.mdf.mehit(jme);
            ecpsh(sealidx)=ecpsh(sealidx)+cpsval.*emodh.*c.mdf.mehit(jme);
        case 'AS'
            %hpg from GC
            hpg=hpg+asgc.*hpmod;
        case 'SS'
            %uptime-based, not cast-based
            cps(idx)=c.rot.uptime(jup).ss./c.player.SSTick(jha);
            ecpsh(idx)=c.rot.uptime(jup).ss./c.player.SSTick(jha); %no modifiers on absorbs
    end

end
%GoWoG average uptime
c.rot.gowogavg=1+c.mdf.glyphWoG.*(c.rot.uptime(jup).gowog1+2.*c.rot.uptime(jup).gowog2+3.*c.rot.uptime(jup).gowog3);

%% Melee
%Melee swings
cps(strcmpi('Melee',c.abil.val.label))=1./c.player.wswing(jws);
ecpsd(strcmpi('Melee',c.abil.val.label))=(1+0.2.*c.rot.uptime(jup).aw).*c.rot.gowogavg./c.player.wswing(jws);
%seal procs
cps(sealidx)=cps(sealidx)+1./c.player.wswing(jws);
ecpsd(sealidx)=ecpsd(sealidx)+(1+0.2.*c.rot.uptime(jup).aw).*c.rot.gowogavg.*c.mdf.mehit(jme)./c.player.wswing(jws);
ecpsh(sealidx)=ecpsh(sealidx)+(1+0.2.*c.rot.uptime(jup).aw).*c.mdf.mehit(jme)./c.player.wswing(jws);

%% Censure
cps(strcmpi('Censure',c.abil.val.label))= censFlag./c.player.censTick(jha);
ecpsd(strcmpi('Censure',c.abil.val.label))= censFlag.*(1+0.2.*c.rot.uptime(jup).aw).*c.rot.gowogavg./c.player.censTick(jha);

%% EF(HoT)
%TODO: this doesn't account for low-HP EF casts
%temp variables for shorter expressions
a=c.rot.uptime(jup);
b1=1+c.mdf.BoG;
b2=1+2.*c.mdf.BoG;
b3=1+3.*c.mdf.BoG;
b4=1+4.*c.mdf.BoG;
b5=1+5.*c.mdf.BoG;
cps(strcmpi('EF(HoT)',c.abil.val.label))= ...
    (a.ef0+a.ef1+a.ef2+a.ef3+a.ef4+a.ef5)...
    ./c.player.EFTick(jha); %divide by tick spacing
ecpsh(strcmpi('EF(HoT)',c.abil.val.label))= ...
    (a.ef0+a.ef1.*b1+a.ef2.*b2+a.ef3.*b3+a.ef4.*b4+a.ef5.*b5)...
    ./c.player.EFTick(jha)... %tick spacing
    .*(1+0.2.*c.rot.uptime(jup).aw); %average effect of AW  

end