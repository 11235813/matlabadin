function [ sequence ] = prio_sim(pri,varargin)
%prio_sim does the grunt work of evaluating the result of a priority queue
%defined in prio_model.
%"pri" can be the current priority structure being executed or an integer.
%If it is an integer, the structure chosen will be prio(pri)

%temporarily put here to make testing easier
%% Input handling

%import priority queue models, cooldowns, and modifiers
prio=evalin('base','prio');
% cd=evalin('base','cd');
mdf=evalin('base','mdf');
target=evalin('base','target');  %needed for ShoR
%the rest are all needed for damage calculations
% dmg=evalin('base','dmg');
% crit=evalin('base','crit');
% player=evalin('base','player');
% cens=evalin('base','cens');
% gear=evalin('base','gear');
% exec=evalin('base','exec');
% npc=evalin('base','npc');



%if no arguments
if nargin<1
    pri=prio(1);
end

%support both structure and integer inptus for pri
if isnumeric(pri)
    tempint=round(pri);
    clear pri
    pri=prio(tempint);
    clear tempint;
end


%populate all entries with empty arrays
N=[];dt=[];hopo=[];
%start filling entries with inputs
if nargin>1
    for i=1:2:length(varargin)
        name=varargin{i};         
        value=varargin{i+1};
        switch name
            case {'N'}
                N=value;
            case {'dt'}
                dt=value;
            case {'hopo', 'HP'}
                hopo=value;
        end
    end
end

%default values of the input arguments
if isempty(N)==1 N=300; end;  %number of timesteps to evaluate
if isempty(dt)==1 dt=0.5; end;  %work in timesteps of 0.5 second for now, can adjust this later
if isempty(hopo)==1 hopo=0; end;

%maintenance, in case we're running this several times
clear t sequence


%% simulation starts here
%initialize gcd and egcd
gcd=0;
egcd=0;

%import cooldowns from prio
% cd=pri.cds;
cd.CS=pri.cds(2);
cd.Jud=pri.cds(3);
cd.AS=pri.cds(4);
cd.HW=pri.cds(5);
cd.Cons=pri.cds(6);

%set "current cooldown" for all relevant spells 
% ccd=zeros(size(cd));

ccd.CS=0;
ccd.AS=0;
ccd.HW=0;
ccd.Jud=0;
ccd.Cons=0;

%duration variable for buff-like effects
dur.SD=0;
dur.Inq=0;
% sdflag=0;  %deprecated

%evaluate setup conditionals
for m=1:length(pri.setup)
    eval(char(pri.setup(m)));
end

%preallocate arrays for speed
L=round(N.*dt./1.5);
sequence.amatrix=zeros(length(pri.alabel),L);
sequence.pmatrix=zeros(length(pri.plabel),L);
sequence.castid=zeros(1,L);
sequence.SD=zeros(1,L);
sequence.Inq=zeros(1,L);
sequence.hopo=zeros(1,L);
sequence.shormiss=zeros(1,L);
t=zeros(1,N);

%counter for spell casts
qq=1;

%start priority simulation routine
for m=1:N
    %track time
    t(m)=(m-1).*dt;
    
    %tracking code for debugging
%     cas(m)=ccd.AS;
%     ccs(m)=ccd.CS;
   
    %if gcd is up
    if gcd<=0;

        %evaluate priority conditionals
        for n=1:length(pri.cond)

            %check each cooldown and conditional in order
            if eval(char(pri.cond(n)))
                %if true, do stuff
                
                %action/cast id for convenience
                aid=pri.cast(n);
                
                %recording what happens - in the end we'll want to know:
                %   -what was cast 
                %   -the timestamp of the cast (for plotting)
                %   -Status of buffs (SD & Inq)
                %   -any procs that should occur
                %   -Hit/Miss for ShoR (so that we can properly evaluate damage later)                
                %the sequence structure will track all of these
                
                %ability usage and proc triggers
                sequence.amatrix(aid,qq)=1;
                sequence.label{qq}=char(pri.alabel(aid));                
                sequence.castid(qq)=aid;
                
                sequence.pmatrix(:,qq)=pri.ptrig(:,aid);
                
                %cast time
                sequence.casttime(qq)=t(m);
                
                %SD/Inq duration
                sequence.SD(qq)=dur.SD;
                sequence.Inq(qq)=dur.Inq;
                
                %holy power
                sequence.hopo(qq)=hopo;
                
                %placeholders for later - related to rotation plots
%                 sequence.seq(qq)=pri.ids(aid);
%                 sequence.color(qq)=0; 
                
                               
                %ShoR handling
                if sum(strcmp(char(pri.alabel(aid)),{'3ShoR';'2ShoR';'1ShoR'}))>0
                    %check for misses
                    if rand<target.avoid/100
                        %if we miss, set the flag and color and nullify
                        %procs
                        sequence.shormiss(qq)=1;
                        sequence.pmatrix(:,qq)=zeros(size(sequence.pmatrix(:,qq)));
%                         sequence.color(qq)=2;

                    elseif dur.SD>0  %otherwise, we hit - check for SD crits
%                         sequence.color(qq)=1;
                        sequence.shormiss(qq)=0;
                        hopo=0;

                    else %no SD, just a regular hit
                        sequence.shormiss(qq)=0;
                        hopo=0;
                    end
                      
                    dur.SD=0;
                else %not shor, mark as a miss (irrelevant, but necessary if we guessed array lengths incorrectly)
                    sequence.shormiss(qq)=0;
                end

                %perform actions
                eval(char(pri.action(aid)));
                
                %special actions (performed last)
                eval(char(pri.spaction(n)));

                %reset gcd
                gcd=pri.gcds(aid);

                %increment counter
                qq=qq+1;

                %break out of for
                break
            end
        end

    end
    
    %if gcd is still <=0, we have an empty or partially empty gcd
    %we only want this to fire about once per gcd, so we use the egcd
    %variable to limit it
    if gcd<=0 && egcd<=0
        
%        sequence.spellname{qq}='Empty';
       sequence.castid(qq)=0;
       sequence.casttime(qq)=t(m);
       sequence.SD(qq)=dur.SD;
       sequence.Inq(qq)=dur.Inq;
       sequence.hopo(qq)=hopo;
       sequence.label{qq}='Empty';
%        sequence.seq(qq)=0;
%        sequence.color(qq)=2;
       sequence.shormiss(qq)=0;
       
       %necessary to make sure amatrix and pmatrix are the correct length
       %in some cases
       sequence.amatrix(1,qq)=0;
       sequence.pmatrix(1,qq)=0;
       
       qq=qq+1;
       egcd=1.5; 
    end
    
    %reduce cooldowns 
%     ccd=ccd-dt;
    ccd.CS=ccd.CS-dt;
    ccd.AS=ccd.AS-dt; 
    ccd.Jud=ccd.Jud-dt;
    ccd.HW=ccd.HW-dt;
    ccd.Cons=ccd.Cons-dt;
    gcd=gcd-dt;
    egcd=egcd-dt;
    
    %reduce durations
    dur.SD=max([dur.SD-dt 0]);
    dur.Inq=max([dur.Inq-dt 0]);
    
    
    %kludgy fix for numerical errors - 
    %after subtraction @ dt=0.1, AS sits at 3.6554e-14.  Depending on dt,
    %this effect can happen for other cooldowns as well.  This leads to a
    %cast being pushed off by one timestep due to numerical inaccuracy.
    %setting a threshold at 1e-10 seems to work for everything down to
    %dt=0.0001.  This is a patch-up job based on roundn() which is in the
    %mapping toolbox, and thus not necessarily available to Octave.
    factor=1e10;
%     ccd=round(ccd.*factor)./factor;
    ccd.CS=round(ccd.CS.*factor)./factor;
    ccd.AS=round(ccd.AS.*factor)./factor;
    ccd.Jud=round(ccd.Jud.*factor)./factor;
    ccd.HW=round(ccd.HW.*factor)./factor;
    ccd.Cons=round(ccd.Cons.*factor)./factor;
    dur.SD=round(dur.SD.*factor)./factor;dur.SD=max([dur.SD 0]);
    gcd=round(gcd.*factor)./factor;
    egcd=round(egcd.*factor)./factor;
    
end



%determine weighting coefficients for each spell
%Helpful constants                   
Iamod=(1+0.3.*pri.adtype'*(sequence.Inq>0));
Ipmod=(1+0.3.*pri.pdtype'*(sequence.Inq>0));
sequence.totaltime=double(m*dt);
sequence.eamatrix=sequence.amatrix.*Iamod;
sequence.epmatrix=ones(2,1)*sum(pri.phit'*ones(1,size(sequence.amatrix,2)).*sequence.amatrix).*sequence.pmatrix;

%fix for ShoR crit handling
ShoRmod=(sequence.SD>0).*mdf.phcritmulti + (sequence.SD==0).*mdf.phcrit;
sequence.eamatrix(1,:)=sequence.eamatrix(1,:).*not(sequence.shormiss).*ShoRmod;

sequence.numcasts=sum([sequence.amatrix; sequence.pmatrix]')';
sequence.effcasts=sum([sequence.eamatrix; sequence.epmatrix]')';


sequence.coeff=sequence.effcasts./sequence.totaltime;
sequence.empties=sum(sequence.castid==0);
temp=find(sequence.castid(1:length(sequence.castid)-1)==0); %all but last one
sequence.emptytime=sum(sequence.casttime(temp+1)-sequence.casttime(temp));
sequence.emptypct=100.*sequence.emptytime./sequence.totaltime;

% %"passive" dps (melee+seals+censure) - in case I decide to move this here
% 
% sequence.padps=0;
%     
% %assume a 5-stack of SoT (if applicable).
% if strcmpi('Truth',exec.seal)||strcmpi('SoT',exec.seal)
%     sequence.padps=sequence.padps+dps.Censure.*(1+sum(Inqmod)./length(Inqmod));
% 
% end
% 
% %aa and seal damage
% sequence.padps=sequence.padps+dps.Melee+dmg.activeseal.*mdf.mehit.*(1+sum(Inqmod)./length(Inqmod))./player.wswing;

%for the moment, only worry about this if damage values are scalars
%later on we might 
if min(size(pri.admg))==1

    sequence.dmgbysrc=[pri.admg; pri.pdmg].*sequence.effcasts;
    sequence.dpsbysrc=[pri.admg; pri.pdmg].*sequence.coeff;

    sequence.dmg=sum(sequence.dmgbysrc);
    sequence.dps=sum(sequence.dpsbysrc);

end

sequence.name=pri.name;
sequence.pri=pri;

%this is from the old version, leaving it here so that I can re-code the
%rotation drawing module later on
%create rotation structure
% rs.seq=seq;
% rs.names(pri.ids)=pri.labels;
% rs.cds(pri.ids)=pri.cds;
% rs.times=casttime;
% rs.color=color;
% % rs.cast=cast;
% % rs.gcds=prio.gcds;

% rotation_drawer(rs,1);

%more debugging code
% figure(2);plot(t,cas,t,ccs);
end