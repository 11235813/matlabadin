%ACTION2CPS takes the actionPr and avgDuration arrays returned by
%memoized_fsm and converts them into a standardized array containing casts
%per second values for DPS calculations
function [cps] = action2cps( actionPr, avgDuration, metadata, labels)

%import focused shield glyph
fsflag=evalin('base','mdf.glyphAS>1');

if nargin<4
    %import val for labels
    val=evalin('base','val');
else
    val.fsmlabel=labels;
end

%default to 1.5s GCD if avgDuration is not supplied
if nargin<2
    avgDuration=1.5;
end

%mdf.mehit and mdf.rahit required for seals - pull from metadata if
%supplied, else import mdf
if nargin<3
    mhit=evalin('base','mdf.mehit');
    rhit=evalin('base','mdf.rahit');
else
    mhit=str2double(metadata.Param_Hit_Melee);
    rhit=str2double(metadata.Param_Hit_Ranged);
end
    

%initialize cps vector
cps=zeros(size(val.fsmlabel,1),1);

%sort actionPr entries into cps
for m=1:size(actionPr,2)
    idx= strcmp(actionPr{1,m},val.fsmlabel);
    cps(idx)=actionPr{2,m};    
end

%corrections

%HotR->HammerNova
idx2=find(strcmp('HotR',val.fsmlabel));
cps(idx2+1)=cps(idx2);

%HotR(Inq)->HammerNova(Inq)
idx3=find(strcmp('HotR(Inq)',val.fsmlabel));
cps(idx3+1)=cps(idx3);

%seal procs
idx4r=logical(...
     strcmp('AS',val.fsmlabel).*fsflag+ ...
     strcmp('J',val.fsmlabel)+ ...
     strcmp('HoW',val.fsmlabel));
 
idx4m=logical(... 
     strcmp('SotR',val.fsmlabel)+strcmp('SotR(SD)',val.fsmlabel)+...
     strcmp('SotR2',val.fsmlabel)+strcmp('CS',val.fsmlabel)+...
     strcmp('HotR',val.fsmlabel));

cps(strcmp('seal',val.fsmlabel))=sum(cps(idx4r)).*rhit + ...
                                 sum(cps(idx4m)).*mhit;
 
idx5r=logical(...
     strcmp('AS(Inq)',val.fsmlabel).*fsflag+ ...
     strcmp('J(Inq)',val.fsmlabel)+ ...
     strcmp('HoW(Inq)',val.fsmlabel));
 
idx5m=logical(... 
     strcmp('SotR(Inq)',val.fsmlabel)+strcmp('SotR(SD)(Inq)',val.fsmlabel)+...
     strcmp('SotR2(Inq)',val.fsmlabel)+strcmp('CS(Inq)',val.fsmlabel)+...
     strcmp('HotR(Inq)',val.fsmlabel));

cps(strcmp('seal(Inq)',val.fsmlabel))=sum(cps(idx5r)).*rhit + ...
                                      sum(cps(idx5m)).*mhit;

%convert CPGCD to CPS
cps=cps./avgDuration;
end