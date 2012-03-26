function [cps] = action2cps(c,j)
%ACTION2CPS takes the actionPr returned by memoized_fsm and converts them
%into a standardized "cast per second" array, including both active and
%passive sources.
%
%A2CPS takes one required input ("c", the configuration structure) and one
%optional input ("j", the iteration number for calculations where mdf.mehit
%or mdf.sphit or player.wswing are not singleton).
%
%A2CPS returns one output, which is the cps array for the given input
%conditions.

%% smart array handling
%j could refer to mdf.mehit, mdf.sphit, or player.wswing.  This section sorts out which is which

%assume all arrays are singleton
jme=1;
jsp=1;
jws=1;

%handle non-singleton arrays
if length(c.mdf.mehit)>1
    jme=j;
end
if length(c.mdf.sphit)>1
    jsp=j;
end
if length(c.player.wswing)>1
    jws=j;
end

%% CPS conversions    
%import focused shield glyph
fsflag=c.mdf.glyphFS>1;

%initialize cps vector
cps=zeros(size(c.abil.val.label,1),1);

%sort actionPr entries into cps
for m=1:size(c.rot.actionPr,2)
    idx= strcmpi(c.rot.actionPr{1,m},c.abil.val.label);
    cps(idx)=c.rot.actionPr{2,m};    
end

%corrections

%HotR->HammerNova
idx=find(strcmpi('HotR',c.abil.val.label));
cps(idx+1)=cps(idx);

%Melee swings
cps(strcmpi('Melee',c.abil.val.label))=1./c.player.wswing(jws);


%% seal procs

%find indices of melee abilities that proc seals
idxm=logical(... 
     strcmpi('SotR',c.abil.val.label) +...
     strcmpi('CS',c.abil.val.label)+...
     strcmpi('HotR',c.abil.val.label));

%currently assuming that seals will be "corrected" to uniform behavior
%note that this also requires c.exec.seal to be in 3-char format
cps(strcmpi(c.exec.seal,c.abil.val.label))= ...
    + sum(cps(idxm)).*c.mdf.mehit(jme) ... %melee abilities
    + c.mdf.mehit(jme)./c.player.wswing(jws);   %melee swings

%censure
cps(strcmpi('Censure',c.abil.val.label))= 1./c.player.censTick;

end