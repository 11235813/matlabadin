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
    idx.alabel{m}=priolist(m).alabel;
    eval(['idx.' priolist(m).alabel '=' int2str(m) ';']);
end


%populate all entries with empty arrays
N=[];dt=[];hopo=[];gcdf=[];
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
            case {'gcd','gcdfactor'}
                gcdf=value;
        end
    end
end

%default values of the input arguments
if isempty(dt)==1 dt=0.5; end;  %work in timesteps of 0.5 second for now, can adjust this later
if isempty(N)==1 N=300; end;  %number of timesteps to evaluate
if isempty(hopo)==1 hopo=0; end;
if isempty(gcdf)==1 gcdf=1; end;

M=floor(N.*1.5.*gcdf./dt);
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
dur.GC=0;

%icds
icd.GC=0;
icd.EG=0;

%evaluate setup conditionals
for m=1:length(pri.setup)
    eval(char(pri.setup(m)));
end

%preallocate arrays for speed
L=round(N.*dt./1.5./gcdf);
sequence.amatrix=zeros(length(priolist),L);
sequence.hmatrix=ones(length(priolist),L);
% sequence.ematrix=zeros(size(sequence.amatrix));
sequence.castid=zeros(1,L);
sequence.dur.SD=zeros(1,L);
sequence.dur.Inq=zeros(1,L);
sequence.dur.GC=zeros(1,L);
sequence.icd.EG=zeros(1,L);
sequence.icd.GC=zeros(1,L);
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
                %   -Status of buffs & ICDs (SD, Inq, GC, EG)
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
                fntemp=fieldnames(dur);
                for fi=1:length(fntemp)
                    sequence.dur.(char(fntemp(fi)))(qq)=dur.(char(fntemp(fi)));
                end
                fntemp=fieldnames(icd);
                for fi=1:length(fntemp)
                    sequence.icd.(char(fntemp(fi)))(qq)=icd.(char(fntemp(fi)));
                end
                
                %special actions (performed last)
                eval(char(pri.spaction(n)));

                %reset gcd
                gcd=priolist(aid).gcd.*gcdf;

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
       sequence.hopo(qq)=hopo;
       sequence.label{qq}='Empty';
       sequence.hmatrix(:,qq)=1;
       
       fntemp=fieldnames(dur);
       for fi=1:length(fntemp)
           sequence.dur.(char(fntemp(fi)))(qq)=dur.(char(fntemp(fi)));
       end
       fntemp=fieldnames(icd);
       for fi=1:length(fntemp)
           sequence.icd.(char(fntemp(fi)))(qq)=icd.(char(fntemp(fi)));
       end
       
       %necessary to make sure amatrix and pmatrix are the correct length
       %in some cases (partial empties)
       sequence.amatrix(:,qq)=0;
       
       qq=qq+1;
       egcd=1.5.*gcdf; 
    end
    
    %reduce cooldowns 
    ccd=ccd-dt;
    gcd=gcd-dt;
    egcd=egcd-dt;
    
    %reduce durations and icds, should be dynamic
    fntemp=fieldnames(dur);
    for fi=1:length(fntemp)
        dur.(char(fntemp(fi)))=max([dur.(char(fntemp(fi)))-dt 0]);
    end
    fntemp=fieldnames(icd);
    for fi=1:length(fntemp)
        icd.(char(fntemp(fi)))=max([icd.(char(fntemp(fi)))-dt 0]);
    end    
    
    
    %kludgy fix for numerical errors - 
    %after subtraction @ dt=0.1, AS sits at 3.6554e-14.  Depending on dt,
    %this effect can happen for other cooldowns as well.  This leads to a
    %cast being pushed off by one timestep due to numerical inaccuracy.
    %setting a threshold at 1e-10 seems to work for everything down to
    %dt=0.0001.  This is a patch-up job based on roundn() which is in the
    %mapping toolbox, and thus not necessarily available to Octave.
    rfact=1e10;
    ccd=round(ccd.*rfact)./rfact;
    gcd=round(gcd.*rfact)./rfact;
    egcd=round(egcd.*rfact)./rfact;
%     %functionalized replacements
%     ccd=ps_round(ccd);
%     gcd=ps_round(gcd);
%     egcd=ps_round(egcd);
  
    fntemp=fieldnames(dur);
    for fi=1:length(fntemp)
        dur.(char(fntemp(fi)))=round(dur.(char(fntemp(fi))).*rfact)./rfact;
        dur.(char(fntemp(fi)))=max([dur.(char(fntemp(fi))) 0]);
    end
    fntemp=fieldnames(icd);
    for fi=1:length(fntemp)
        icd.(char(fntemp(fi)))=round(icd.(char(fntemp(fi))).*rfact)./rfact;
        icd.(char(fntemp(fi)))=max([icd.(char(fntemp(fi))) 0]);
    end
%     %functionalized replacements
%     dur=ps_structround(dur);
%     icd=ps_structround(icd);
    
    
    
end


%total time
sequence.totaltime=double(m*dt);

%determine weighting coefficients for each spell, multi-step process
%
%Inq modifier arrays
sequence.Inqmod=(1+0.3.*[priolist.holy]'*(sequence.dur.Inq>0));
sequence.Inqup=sum(sequence.dur.Inq>0)./sequence.totaltime;
%
%SD crit handling array
sequence.SDmod=ones(size(sequence.Inqmod));
tmp.SotR=(sequence.dur.SD>0).*mdf.phcritm + (sequence.dur.SD<=0).*mdf.phcrit;
for p=1:length(idx.alabel); 
    if strfind(idx.alabel{p},'SotR'); 
        sequence.SDmod(p,:)=tmp.SotR;
    end;
end
%
%construct effective ability matrix from all of the above
sequence.eamatrix=sequence.amatrix.*sequence.hmatrix.*sequence.Inqmod.*sequence.SDmod;
%
%total up number of casts and number of effective casts
sequence.numcasts=sum(sequence.amatrix,2);
sequence.effcasts=sum(sequence.eamatrix,2);
%
%use effective casts to generate weights
sequence.coeff=sequence.effcasts./sequence.totaltime;

%informational fields

%casts per second and successful casts per second
sequence.cps=sequence.numcasts./sequence.totaltime;
sequence.scps=sum(sequence.amatrix.*sequence.hmatrix,2)./sequence.totaltime;

%mana stuff
sequence.mpc=[priolist.mana]';
sequence.mps=sum(sequence.cps.*sequence.mpc);

%empties and total empty time
sequence.empties=sum(sequence.castid==0);
tmp.empt=find(sequence.castid(1:length(sequence.castid)-1)==0); %all but last one
sequence.emptytime=sum(sequence.casttime(tmp.empt+1)-sequence.casttime(tmp.empt));
sequence.emptypct=100.*sequence.emptytime./sequence.totaltime;

%sotr misses, as casts, gc procs
sequence.smiss=sum(sum(sequence.hmatrix==0,2));
sequence.ascast=sequence.numcasts(idx.AS);
sequence.gcproc=sum(diff(sequence.dur.GC)>1)+int32(sequence.dur.GC(1)~=0);

%mean time between finishers
tmp.dhopo=diff(sequence.hopo==3);
tmp.i1=find(tmp.dhopo>0);
tmp.i2=find(tmp.dhopo<0);
sequence.f2fgcd=mean(1+tmp.i1-[0 tmp.i2(1:length(tmp.i1)-1)]);
sequence.f2ftime=mean(1.5.*gcdf+sequence.casttime(1+tmp.i1)-sequence.casttime([1 1+tmp.i2(1:length(tmp.i1)-1)]));
sequence.sf2sfgcd=mean(tmp.i1-[0 tmp.i1(1:length(tmp.i1)-1)]);
sequence.sf2sftime=mean(sequence.casttime(1+tmp.i1)-sequence.casttime([1 1+tmp.i1(1:length(tmp.i1)-1)]));


%all damage calculations now taken care of in postprocessing.

%storage of queue name and details
sequence.name=pri.name;
sequence.pri=pri;

%% Functions
%I intended to use these for readability, replacing several of the
%multi-line for loop calls that perform the rounding functions on structure
%fields.  However, while testing I found that there's a significant
%efficiency cost in doing so, up to 10% slower runtime per replacement,
%despite running exactly the same code.  MATLAB's nested function routines
%must have some serious overhead if we get a 5% slowdown by replacing
%x=round(x.*rfact)./rfact with x=ps_round(x).

%     %rounding fix
%     function y=ps_round(x)
%         rfact=1e10;
%         y=round(x.*rfact)./rfact;
%     end
% 
%     function y=ps_max(x)
%         y=max([x 0]);
%     end
% 
%     %compact version of roundign fix for dur/icd structures
%     function z=ps_structround(w)
%         fntemp=fieldnames(w);
%         for fi=1:length(fntemp)
%             z.(char(fntemp(fi)))=ps_round(w.(char(fntemp(fi))));
%             z.(char(fntemp(fi)))=ps_max(w.(char(fntemp(fi))));
%         end
%     end
% 
%     %compact version of subtraction for dur/icd structures
%     function z=ps_structsub(w,dt)
%         fntemp=fieldnames(w);
%         for fi=1:length(fntemp)
%             z.(char(fntemp(fi)))=ps_max(w.(char(fntemp(fi)))-dt);
%         end
%     end
% 
%     %compact version of structure copying for dur/icd 
%     function z=ps_structcopy(w,seqw,qq)
%         fntemp=fieldnames(w);
%         z=seqw;
%         for fi=1:length(fntemp)
%             z.(char(fntemp(fi)))(qq)=w.(char(fntemp(fi)));
%         end
%     end
end