function [ rs ] = prio_sim(pri,varargin)
%prio_sim does the grunt work of evaluating the result of a priority queue
%defined in prio_model.
%"pri" can be the current priority structure being executed or an integer.
%If it is an integer, the structure chosen will be prio(pri)

%temporarily put here to make testing easier
%% Input handling

%import priority queue models and cooldowns
prio=evalin('base','prio');
cd=evalin('base','cd');

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
clear t damage label spell casttime

dmg=evalin('base','dmg');

%% simulation starts here
%initialize gcd and egcd
gcd=0;
egcd=0;

%set "current cooldown" for all relevant spells 
ccd.CS=0;
ccd.AS=0;
ccd.HoWr=0;
ccd.Jud=0;

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
                damage(qq)=eval(['dmg.' char(pri.cast(n))]);
                spell{qq}=char(pri.cast(n));
                label{qq}=char(pri.labels(n));
                casttime(qq)=t(m);
                seq(qq)=pri.ids(n);
                qq=qq+1;

                %perform actions
                eval(char(pri.action(n)));
                
                %reset gcd
                gcd=pri.gcds(n);
                
                %break out of for
                break
            end
        end

    end
    
    %if gcd is still <=0, we have an empty or partially empty gcd
    %we only want this to fire about once per gcd, so we use the egcd
    %variable to limit it
    if gcd<=0 && egcd<=0
       damage(qq)=0;
       spell{qq}='Empty';
       label{qq}='Empty';
       casttime(qq)=t(m);
       seq(qq)=0;
       qq=qq+1;
       egcd=1.5; 
    end
    
    %reduce cooldowns
    ccd.CS=ccd.CS-dt;
    ccd.AS=ccd.AS-dt; 
    ccd.Jud=ccd.Jud-dt;
    ccd.HoWr=ccd.HoWr-dt;
    gcd=gcd-dt;
    egcd=egcd-dt;
    
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
    gcd=round(gcd.*factor)./factor;
    egcd=round(egcd.*factor)./factor;
    
end

%fix dimensions
damage=damage';
spell=spell';
label=label';
casttime=casttime';

%create rotation structure
rs.seq=seq;
rs.names(pri.ids)=pri.labels;
rs.cds(pri.ids)=pri.cds;
rs.times=casttime;
% rs.gcds=prio.gcds;

rotation_drawer(rs,1);

%more debugging code
% figure(2);plot(t,cas,t,ccs);
end