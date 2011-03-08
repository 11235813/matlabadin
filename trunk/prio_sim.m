function [ sequence ] = prio_sim(pri,varargin)
%prio_sim does the grunt work of evaluating the result of a priority queue
%defined in prio_model.
%"pri" can be the current priority structure being executed or an integer.
%If it is an integer, the structure chosen will be prio(pri)

%temporarily put here to make testing easier
%% Input handling
%force update of prio_model in base workspace; this is a kludge to
%compensate for the fact that prio_model doesn't automatically update when
%mdf.mehit is updated, and Theck has a terrible memory when debugging.
%OTOH: it also means we never have to run prio_model anywhere, and since we
%always want to run it before prio_sim anyway, it makes more sense to put
%it here
evalin('base','prio_model');

%import priority queue models, cooldowns, and modifiers
priolist=evalin('base','priolist');
prio=evalin('base','prio');
mdf=evalin('base','mdf');
target=evalin('base','target');  %needed for SotR

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

%temp array for identifiers and labels
for m=1:length(priolist)
    tmp.alabel{m}=priolist(m).alabel;
    eval(['tmp.' priolist(m).alabel '=' int2str(m) ';']);
end


%populate all entries with empty arrays
N=[];dt=[];hopo=[];
%start filling entries with inputs
if nargin>1
    for i=1:2:length(varargin)
        name=varargin{i};         
        value=varargin{i+1};
        switch name
            case {'dt'}
                dt=value;
            case {'N'}
                N=value;
            case {'hopo', 'HP'}
                hopo=value;
        end
    end
end

%default values of the input arguments
if isempty(dt)==1 dt=0.5; end;  %work in timesteps of 0.5 second for now, can adjust this later
if isempty(N)==1 N=300; end;  %number of timesteps to evaluate
if isempty(hopo)==1 hopo=0; end;

M=floor(N.*1.5./dt);
%maintenance, in case we're running this several times
clear t sequence


%% simulation starts here
%initialize gcd and egcd
gcd=0;
egcd=0;

%import cooldowns from prio
for m=1:length(priolist)
    cd(m)=priolist(m).cd;
end

%set "current cooldown" for all relevant spells 
ccd=zeros(size(cd));

%duration variable for buff-like effects
dur.SD=0;
dur.Inq=0;
dur.EGicd=0;
dur.GC=0;

%evaluate setup conditionals
for m=1:length(pri.setup)
    eval(char(pri.setup(m)));
end

%preallocate arrays for speed
L=round(N.*dt./1.5);
sequence.amatrix=zeros(length(priolist),L);
sequence.hmatrix=ones(length(priolist),L);
% sequence.ematrix=zeros(size(sequence.amatrix));
sequence.castid=zeros(1,L);
sequence.SD=zeros(1,L);
sequence.Inq=zeros(1,L);
sequence.hopo=zeros(1,L);
t=zeros(1,N);

%counter for spell casts
qq=1;

%start priority simulation routine
for m=1:N
    %track time
    t(m)=(m-1).*dt;
    
   
    %if gcd is up
    if gcd<=0;

        %evaluate priority conditionals
        for n=1:length(pri.cond)

            %check each cooldown and conditional in order
            if ccd(pri.cast(n))<=0 && eval(char(pri.cond(n)))
                %if true, do stuff
                
                %check for overbounding - occasionally we'll get an extra
                %GCD or two because of partial empties.  This is a fix for
                %the two larger arrays to keep them initialized properly.
                %The other arrays should all auto-correct in the code
                if qq>size(sequence.amatrix,2)
                    sequence.amatrix(:,qq)=0;
                    sequence.hmatrix(:,qq)=1;
                end
                
                %action/cast id for convenience
                aid=pri.cast(n);
                
                %recording what happens - in the end we'll want to know:
                %   -what was cast 
                %   -the timestamp of the cast 
                %   -Status of buffs (SD & Inq)
                %   -any procs that should occur
                %   -Hit/Miss for SotR (so that we can properly evaluate damage later)                
                %the sequence structure will track all of these
                
                %ability usage
                sequence.amatrix(aid,qq)=1;
                sequence.label{qq}=char(priolist(aid).alabel);                
                sequence.castid(qq)=aid;
                
                %procs triggered by ability
                for o=1:length(priolist(aid).proctrig)
                    if priolist(aid).proctrig(o)~=0
                        sequence.amatrix(priolist(aid).proctrig(o),qq)=priolist(aid).procno(o);
                        sequence.hmatrix(priolist(aid).proctrig(o),qq)=priolist(aid).prochit(o);
                    end
                end
                
                %cast time
                sequence.casttime(qq)=t(m);
                                
                %holy power
                sequence.hopo(qq)=hopo;
                                               
                %ShoR handling, check to see if this cast is SotR
                if strfind(sequence.label{qq},'SotR')
                    
                    %check for misses
                    if rand>mdf.mehit
                        %if we miss, set the flag
                        sequence.hmatrix(aid,qq)=0;
                        %nullify procs
                        for o=1:length(priolist(aid).proctrig)
                            if priolist(aid).proctrig(o)~=0
                                sequence.amatrix(priolist(aid).proctrig(o),qq)=0;
                            end
                        end
                        %force SD falloff before next time step to account
                        %for using up the SD proc
                        dur.SD=-dt/10; 
                        
                    %otherwise, we hit - check for SD crits
                    elseif dur.SD>0  
                        sequence.hmatrix(aid,qq)=1; 
                        hopo=0;
                        %set SD to a distinctive value that will fall off
                        %in the next time step to use up SD proc
                        dur.SD=dt/pi;

                    else %no SD, just a regular hit
                        sequence.hmatrix(aid,qq)=1;  
                        hopo=0;
                    end
                      
                else %not SotR, mark as a hit (irrelevant, but necessary if we guessed array lengths incorrectly)
                    sequence.hmatrix(aid,qq)=1;
                end
                
                %set cooldown
                ccd(aid)=cd(aid);

                %perform default ability actions
                eval(char(priolist(aid).action));
                
                %SD/Inq duration (done here so that uptime % is correct)
                sequence.SD(qq)=dur.SD;
                sequence.Inq(qq)=dur.Inq;
                sequence.GC(qq)=dur.GC;
                
                %special actions (performed last)
                eval(char(pri.spaction(n)));

                %reset gcd
                gcd=priolist(aid).gcd;

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
        

       sequence.castid(qq)=0;
       sequence.casttime(qq)=t(m);
       sequence.SD(qq)=dur.SD;
       sequence.GC(qq)=dur.GC;
       sequence.Inq(qq)=dur.Inq;
       sequence.hopo(qq)=hopo;
       sequence.label{qq}='Empty';
       sequence.hmatrix(:,qq)=1;
       
       %necessary to make sure amatrix and pmatrix are the correct length
       %in some cases (partial empties)
       sequence.amatrix(:,qq)=0;
       
       qq=qq+1;
       egcd=1.5; 
    end
    
    %reduce cooldowns 
    ccd=ccd-dt;
    gcd=gcd-dt;
    egcd=egcd-dt;
    
    %reduce durations
    dur.SD=max([dur.SD-dt 0]);
    dur.Inq=max([dur.Inq-dt 0]);
    dur.GC=max([dur.GC-dt 0]);
    
    
    %kludgy fix for numerical errors - 
    %after subtraction @ dt=0.1, AS sits at 3.6554e-14.  Depending on dt,
    %this effect can happen for other cooldowns as well.  This leads to a
    %cast being pushed off by one timestep due to numerical inaccuracy.
    %setting a threshold at 1e-10 seems to work for everything down to
    %dt=0.0001.  This is a patch-up job based on roundn() which is in the
    %mapping toolbox, and thus not necessarily available to Octave.
    factor=1e10;
    ccd=round(ccd.*factor)./factor;
    dur.SD=round(dur.SD.*factor)./factor;dur.SD=max([dur.SD 0]);
    dur.GC=round(dur.GC.*factor)./factor;dur.GC=max([dur.GC 0]);
    gcd=round(gcd.*factor)./factor;
    egcd=round(egcd.*factor)./factor;
    
end


%total time
sequence.totaltime=double(m*dt);

%determine weighting coefficients for each spell
%Inq modifier arrays
sequence.Inqmod=(1+0.3.*[priolist.holy]'*(sequence.Inq>0));
sequence.Inqup=sum(sequence.Inq>0)./sequence.totaltime;
%SotR crit handling array
sequence.SotRmod=ones(size(sequence.Inqmod));
tmp.SotR=(sequence.SD>0).*mdf.phcritm + (sequence.SD<=0).*mdf.phcrit;
for p=1:length(tmp.alabel); 
    if strfind(tmp.alabel{p},'SotR'); 
        sequence.SotRmod(p,:)=tmp.SotR;
    end;
end
sequence.eamatrix=sequence.amatrix.*sequence.hmatrix.*sequence.Inqmod.*sequence.SotRmod;

sequence.numcasts=sum(sequence.amatrix,2);
sequence.effcasts=sum(sequence.eamatrix,2);
sequence.cps=sequence.numcasts./sequence.totaltime;
sequence.scps=sum(sequence.amatrix.*sequence.hmatrix,2)./sequence.totaltime;
sequence.mpc=[priolist.mana]';
sequence.mps=sum(sequence.cps.*sequence.mpc);

sequence.coeff=sequence.effcasts./sequence.totaltime;
sequence.empties=sum(sequence.castid==0);
temp=find(sequence.castid(1:length(sequence.castid)-1)==0); %all but last one
sequence.emptytime=sum(sequence.casttime(temp+1)-sequence.casttime(temp));
sequence.emptypct=100.*sequence.emptytime./sequence.totaltime;

%informational fields
sequence.smiss=sum(sum(sequence.hmatrix==0,2));
sequence.ascast=sequence.numcasts(tmp.AS);
sequence.gcproc=sum(diff(sequence.GC)>1)+int32(sequence.GC(1)~=0);


%all damage calculations now taken care of in postprocessing.

sequence.name=pri.name;
sequence.pri=pri;
end