function [ sequence ] = prio_sim(pri,varargin)
%prio_sim does the grunt work of evaluating the result of a priority queue
%defined in prio_model.
%"pri" can be the current priority structure being executed or an integer.
%If it is an integer, the structure chosen will be prio(pri)

%temporarily put here to make testing easier
%% Input handling

%import priority queue models, cooldowns, and modifiers
prio=evalin('base','prio');
cd=evalin('base','cd');
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
if isempty(dt)==1 dt=0.1; end;  %work in timesteps of 0.1 second for now, can adjust this later
if isempty(hopo)==1 hopo=0; end;

%maintenance, in case we're running this several times
clear t sequence


%% simulation starts here
%initialize gcd and egcd
gcd=0;
egcd=0;

%set "current cooldown" for all relevant spells 
ccd.CS=0;
ccd.AS=0;
ccd.HoWr=0;
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

% damage=zeros(N,1);
% spell=cell(N);
% label=cell(N);

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

            %check each conditional in order
            if eval(char(pri.cond(n)))
                %if true, do stuff
                
                %action/cast id for convenience
                aid=pri.cast(n);
                
                %recording what happens - in the end we'll want to know:
                %   -what was cast 
                %   -the timestamp of the cast (for plotting)
                %   -Status of buffs (SD & Inq)
                %   -Hit/Miss for ShoR (so that we can properly evaluate damage later)
                
                %the sequence structure will track all of these
                sequence.castid(qq)=aid;
                sequence.casttime(qq)=t(m);
                sequence.SD(qq)=dur.SD;
                sequence.Inq(qq)=dur.Inq;
                sequence.hopo(qq)=hopo;
                sequence.spellname{qq}=char(pri.castname(aid));
                sequence.label{qq}=char(pri.labels(aid));
                sequence.seq(qq)=pri.ids(aid);
                sequence.color(qq)=0; %placeholder for later
                
                
                
                %i want to handle damage after-the-fact, but I'll leave
                %this here for now in case we decide it's relevant.
%                 sequence.damage(qq)=pri.dmg(aid);
            
                
                %perform actions
                eval(char(pri.action(aid)));
                
                %ShoR handling
                if strcmp(char(pri.castname(aid)),'ShieldoftheRighteous')
                    %check for misses
                    if rand<target.avoid/100
                        %if we miss, set the flag and color 
                        sequence.shormiss(qq)=1;
                        sequence.color(qq)=2;
                        %sacred duty cleared at end of if statement

                    elseif dur.SD>0  %otherwise, we hit - check for SD crits
                        sequence.color(qq)=1;
                        sequence.shormiss(qq)=0;

                    else %no SD, just a regular hit
                        sequence.shormiss(qq)=0;
                    end

                    %clear SD, regardless of outcome
                    dur.SD=0;

                else %not ShoR, mark as not a miss (irrelevant really)
                    sequence.shormiss(qq)=0;
                end

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
        
%        sequence.damage(qq)=0;
       sequence.castid(qq)=0;
       sequence.casttime(qq)=t(m);
       sequence.SD(qq)=dur.SD;
       sequence.Inq(qq)=dur.Inq;
       sequence.hopo(qq)=hopo;
       sequence.spellname{qq}='Empty';
       sequence.label{qq}='Empty';
       sequence.seq(qq)=0;
       sequence.color(qq)=2;
       sequence.shormiss(qq)=0;
       
       qq=qq+1;
       egcd=1.5; 
    end
    
    %reduce cooldowns   TODO: Implement generic ccd array
    ccd.CS=ccd.CS-dt;
    ccd.AS=ccd.AS-dt; 
    ccd.Jud=ccd.Jud-dt;
    ccd.HoWr=ccd.HoWr-dt;
    ccd.Cons=ccd.Cons-dt;
    gcd=gcd-dt;
    egcd=egcd-dt;
    
    %reduce durations
    dur.SD=max([dur.SD-dt 0]);
    dur.Inq=max([dur.Inq-dt 0]);
    
    %modifiers
    mdf.Inq=1.3.*sign(dur.Inq);
    mdf.SDcrit=1.*sign(dur.SD);
    
    %recalculate ability damages - probably not necessary if we're not
    %going to track damages locally
%     ability_model;
    
    %kludgy fix for numerical errors - 
    %after subtraction @ dt=0.1, AS sits at 3.6554e-14.  Depending on dt,
    %this effect can happen for other cooldowns as well.  This leads to a
    %cast being pushed off by one timestep due to numerical inaccuracy.
    %setting a threshold at 1e-10 seems to work for everything down to
    %dt=0.0001.  This is a patch-up job based on roundn() which is in the
    %mapping toolbox, and thus not necessarily available to Octave.
    factor=1e10;
    ccd.CS=round(ccd.CS.*factor)./factor;
    ccd.AS=round(ccd.AS.*factor)./factor;
    ccd.Jud=round(ccd.Jud.*factor)./factor;
    ccd.HoWr=round(ccd.HoWr.*factor)./factor;
    dur.SD=round(dur.SD.*factor)./factor;dur.SD=max([dur.SD 0]);
    gcd=round(gcd.*factor)./factor;
    egcd=round(egcd.*factor)./factor;
    
end



%determine weighting coefficients for each spell
%Helpful constants                   
Inqmod=(0.3.*(sequence.Inq>0));
sequence.totaltime=m*dt;

for mm=1:length(pri.labels)
    %if we're evaluating a ShoR
    if sum(strcmp(char(pri.labels{mm}),{'3ShoR';'2ShoR';'1ShoR'}))>0
        sequence.shorflag(mm)=1;
        sequence.effcasts(mm)=sum((1+Inqmod).* ...  %Inq handling, probably irrelevant for ShoR
            ((sequence.castid==mm).*not(sequence.shormiss).*(sequence.SD==0).*mdf.phcrit+... %# ShoR hits/crits
            (sequence.castid==mm).*not(sequence.shormiss).*(sequence.SD>0).*mdf.phcritmulti) ... %# ShoR SD crits
            ); 
        sequence.sealcasts(mm)=sum((1+Inqmod).* ...  %Inq handling, probably irrelevant for ShoR
            ((sequence.castid==mm).*not(sequence.shormiss).*(sequence.SD==0)+... %# ShoR hits/crits
            (sequence.castid==mm).*not(sequence.shormiss).*(sequence.SD>0)) ... %# ShoR SD crits
            ); 
        sequence.numcasts(mm)=sum( ...
            ((sequence.castid==mm).*not(sequence.shormiss).*(sequence.SD==0)+... %# ShoR hits/crits
            (sequence.castid==mm).*not(sequence.shormiss).*(sequence.SD>0)) ... %# ShoR SD crits
            ); 
    
    else %everything else is easier - just Inq
        sequence.shorflag(mm)=0;
        sequence.effcasts(mm)=sum((sequence.castid==mm).*(1+Inqmod.*pri.inqeffect(mm)));
        sequence.numcasts(mm)=sum((sequence.castid==mm));
        sequence.sealcasts(mm)=pri.procsseals(mm).*pri.sealhit(mm).*sequence.effcasts(mm);
    end
end

%seals from ShoR
sequence.effcasts(mm+1)=sum(sequence.sealcasts);

sequence.coeff=sequence.effcasts./sequence.totaltime;
sequence.empties=sum(sequence.castid==0);

sequence.dmg=[pri.damage pri.sealdamage].*sequence.effcasts;
sequence.dps=[pri.damage pri.sealdamage].*sequence.coeff;
sequence.net=pri.damage.*sequence.coeff(1:mm)+pri.sealdamage.*sequence.sealcasts./sequence.totaltime;
sequence.sumdps=sum(sequence.dps);

sequence.name=pri.name;

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