function [cps] = action2cps(c,j)
%ACTION2CPS takes the actionPr returned by memoized_fsm and converts them
%into a standardized "cast per second" array, including both active and
%passive sources.
%
%A2CPS takes one required input ("c", the configuration structure) and one
%optional input ("j", the iteration number for calculations where mdf.mehit
%or mdf.rahit are not singleton).
%
%A2CPS returns one output, which is the cps array for the given input
%conditions.

if nargin<2
    j=1;
end

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
cps(strcmpi('Melee',c.abil.val.label))=1./c.player.wswing;


%seal procs
idxr=logical(...
     strcmpi('AS',c.abil.val.label).*fsflag+ ...
     strcmpi('J',c.abil.val.label));
 
idxm=logical(... 
     strcmpi('SotR',c.abil.val.label) + strcmpi('CS',c.abil.val.label)+...
     strcmpi('HotR',c.abil.val.label));

%currently assuming that seals will be "corrected" to uniform behavior
%note that this also requires c.exec.seal to be in 3-char format
cps(strcmpi(c.exec.seal,c.abil.val.label))= ...
    sum(cps(idxr)).*c.mdf.rahit(j) + sum(cps(idxm)).*c.mdf.mehit(j) ... %active sources
    + c.mdf.mehit./c.player.wswing;   %melee swings

%censure
cps(strcmpi('Censure',c.abil.val.label))= 1./c.player.censTick;

end