%prio_sim does the grunt work of evaluating the result of a priority queue
%defined in prio_model.  This module should be preceded by a line defining
%the "pri" structure, which is the current priority structure being
%executed.

%temporarily put here to make testing easier
pri=prio(1);
player.hopo=0;

%maintenance, in case we're running this several times
clear t damage label spell casttime

%work in timesteps of 0.1 second for now, can adjust this later
dt=0.1;  %timestep in seconds
N=300;   %number of timesteps to evaluate

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

rotation_drawer(rs,1);