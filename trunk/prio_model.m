%prio_model sets up the basic priority queue structures that are then
%executed by the priority simulator module.

%initialize structure
priolist=struct('alabel',[], ...
           'cd',[], ...
           'gcd',[], ...
           'holy',[], ...
           'proctrig',[], ...
           'prochit',[], ...
           'cond',[], ...
           'action',[]);
%% Spells and Procs
%Procs are treated just like spells on the list, simplifying the data
%structures in prio_sim considerably.
tmp.sealid=11;
tmp.novaid=12;

%SotR       
priolist(1).alabel='SotR';       
priolist(1).cd=0;
priolist(1).gcd=1.5;
priolist(1).holy=1;
priolist(1).proctrig=[tmp.sealid]; %seals only
priolist(1).prochit=[1]; %SotR misses accounted for in code
priolist(1).condition='hopo>=3';
priolist(1).action='0;';

q=2;
%CS     
priolist(q).alabel='CS';       
priolist(q).cd=3;
priolist(q).gcd=1.5;
priolist(q).holy=0;
priolist(q).proctrig=[tmp.sealid]; %seals only
priolist(q).prochit=[mdf.mehit]; 
priolist(q).condition='1'; 
priolist(q).action='hopo=min([3 hopo+1]);if rand<mdf.GrCr.*mdf.mehit ccd(tmp.AS)=0; end;'; 
 
q=3;
%J    
priolist(q).alabel='J';       
priolist(q).cd=8;
priolist(q).gcd=1.5;
priolist(q).holy=1;
priolist(q).proctrig=[tmp.sealid]; %seals
priolist(q).prochit=[mdf.rahit.*mdf.jseals]; 
priolist(q).condition='1'; 
priolist(q).action='if rand<mdf.SacDut*mdf.rahit dur.SD=15; end;'; 
 
q=4;
%AS   
priolist(q).alabel='AS';       
priolist(q).cd=15;
priolist(q).gcd=1.5;
priolist(q).holy=1;
priolist(q).proctrig=[0]; %no procs
priolist(q).prochit=[0]; 
priolist(q).condition='1'; 
priolist(q).action=''; 
  
q=5;
%HW  
priolist(q).alabel='HW';       
priolist(q).cd=15;
priolist(q).gcd=1.5;
priolist(q).holy=1;
priolist(q).proctrig=[0]; %no procs
priolist(q).prochit=[0]; 
priolist(q).condition='1';
priolist(q).action='';
  
q=6;
%Cons  
priolist(q).alabel='Cons';       
priolist(q).cd=30.*mdf.glyphCons;
priolist(q).gcd=1.5;
priolist(q).holy=1;
priolist(q).proctrig=[0]; %no procs
priolist(q).prochit=[0]; 
priolist(q).condition='1';
priolist(q).action='';
 
q=7;
%HotR   
priolist(q).alabel='HotR';       
priolist(q).cd=3;
priolist(q).gcd=1.5;
priolist(q).holy=0;
priolist(q).proctrig=[tmp.sealid;tmp.novaid]; %seals,HammerNova
priolist(q).prochit=[1;1]; 
priolist(q).condition='1';
priolist(q).action='hopo=min([3 hopo+1]);if rand<mdf.GrCr ccd(tmp.AS)=0; end;';
 
q=8;
%SotR2   
priolist(q).alabel='SotR2';       
priolist(q).cd=0;
priolist(q).gcd=1.5;
priolist(q).holy=1;
priolist(q).proctrig=[tmp.sealid]; %seals
priolist(q).prochit=[1]; 
priolist(q).condition='hopo>=2';
priolist(q).action='0;';

q=9;
%Inq
priolist(q).alabel='Inq';       
priolist(q).cd=0;
priolist(q).gcd=1.5;
priolist(q).holy=0;
priolist(q).proctrig=[0]; %no procs
priolist(q).prochit=[0]; 
priolist(q).condition='hopo>=3 && dur.Inq<=1';
priolist(q).action='dur.Inq=4*hopo;hopo=0;';

q=10;
%HoW
priolist(q).alabel='HoW';       
priolist(q).cd=6;
priolist(q).gcd=1.5;
priolist(q).holy=1;
priolist(q).proctrig=[tmp.sealid]; %seals
priolist(q).prochit=[mdf.rahit]; 
priolist(q).condition='1';
priolist(q).action='';

q=11;
%Seal
priolist(q).alabel=exec.seal;       
priolist(q).cd=0;
priolist(q).gcd=0;
priolist(q).holy=strcmp(exec.seal,'Truth')+strcmp(exec.seal,'Righteousness');
priolist(q).proctrig=[0]; %no recursive procs (irrelevant as this should never be a primary cast anyway)
priolist(q).prochit=[0]; 
priolist(q).condition='0';
priolist(q).action='0;';

q=12;
%HammerNova
priolist(q).alabel='HaNova';       
priolist(q).cd=0;
priolist(q).gcd=0;
priolist(q).holy=1;
priolist(q).proctrig=[0]; %no procs
priolist(q).prochit=[0]; 
priolist(q).condition='0';
priolist(q).action='0;';

q=13;
%WoG
priolist(q).alabel='WoG';       
priolist(q).cd=0;
priolist(q).gcd=1.5;
priolist(q).holy=0;
priolist(q).proctrig=[0]; %no procs
priolist(q).prochit=[0]; 
priolist(q).condition='hopo>=3';
priolist(q).action='if (rand<mdf.EG && dur.EGicd<=0) dur.EGicd=15; else hopo=0; end;'; 

                


%% Construct priority list

clear prio            
%Now we start the rotation-specific priority code.  Note that we invoke
%priolist to get all of the generic stuff, but we can overwrite specific
%things if we decide we want to.

k=1;
prio(k).name='SotR>CS>J>AS>HW';
          
%setup contains commands to be evaluated at the beginning of the
%simulation.  For example, setting ccd.AS=13.5 would simulate pulling with
%AS, making it unavailable early on in the queue.
prio(k).setup={'ccd(tmp.AS)=13.5;'};
            
%spaction is the structure that contains any special actions that should
%occur for specific conditions.  It is run after all of the default actions
%defined in prio.action
prio(k).spaction={'';''; ''; ''; ''; ''; ''; '';'';'';};



%% Single-Target Queues
%standard
k=k+1;prio(k)=prio(1);
prio(k).name='SotR>HotR>J>AS>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR>CS>J>AS>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR>CS>AS>J>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR>AS>CS>J>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='AS>SotR>CS>J>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='SD>SotR>CS>J>AS>Cons>HW';

%Inq rotations

k=k+1;prio(k)=prio(1);
prio(k).name='Inq>CS>J>AS>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR2*>Inq>CS>AS>J>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR*>Inq>CS>J>AS>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR*>Inq>HotR*>CS>J>AS>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR*>Inq>CS>J2>AS>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR*>Inq>HotR>J2>AS>Cons>HW';


k=k+1;prio(k)=prio(1);
prio(k).name='SotR*>Inq>CS>AS>J>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR*>Inq>CS>AS*>J>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR*>Inq>HotR>AS>J>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR*>Inq>SDSotR2>CS>J>AS>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='SDSotR*>Inq>HotR*>CS>J>AS>Cons>HW';

%WoG

k=k+1;prio(k)=prio(1);
prio(k).name='WoG>CS>J>AS>Cons>HW';
        
k=k+1;prio(k)=prio(1);
prio(k).name='WoG>CS>AS>J>Cons>HW';
        
k=k+1;prio(k)=prio(1);
prio(k).name='WoG>CS>AS>Cons>J>HW';
        
k=k+1;prio(k)=prio(1);
prio(k).name='SDSotR>WoG>CS>J>AS>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='SDSotR>WoG>CS>AS>J>Cons>HW';

%HoW (sub-20%)

k=k+1;prio(k)=prio(1);
prio(k).name='SotR>CS>J>AS>HoW';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR>CS>J>HoW>AS';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR>CS>HoW>J>AS';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR>CS>HoW>AS>J>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR>HoW>CS>J>AS>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='HoW>SotR>CS>J>AS>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='HoW>Inq>SotR*>CS>J>AS>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='HoW>CS>SotR>J>AS';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR*>Inq>CS>HoW>J2>AS';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR*>Inq>HotR>HoW>J2>AS';

k=k+1;prio(k)=prio(1);
prio(k).name='HoW*>SotR*>Inq>CS>J2>AS';

k=k+1;prio(k)=prio(1);
prio(k).name='HoW>SotR*>Inq>CS>J2>AS';


k1=k;
%end Single-Target queues

%% AoE Queues

k=k+1;prio(k)=prio(1);
prio(k).name='SotR>HotR>J>AS>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR>HotR>AS>J>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR>HotR>AS>Cons>J>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR>HotR>AS>Cons>HW>J';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR>HotR>Cons>AS>HW>J';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR>HotR>Cons>HW>AS>J';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR>HotR>HW>Cons>AS>J';

k=k+1;prio(k)=prio(1);
prio(k).name='SotR>AS>HotR>Cons>HW>J';

k=k+1;prio(k)=prio(1);
prio(k).name='AS>SotR>HotR>Cons>HW>J';

k=k+1;prio(k)=prio(1);
prio(k).name='AS>HotR>SotR>Cons>HW>J';

k=k+1;prio(k)=prio(1);
prio(k).name='AS>HotR>Cons>SotR>HW>J';

k=k+1;prio(k)=prio(1);
prio(k).name='HotR>AS>Cons>SotR>HW>J';

k=k+1;prio(k)=prio(1);
prio(k).name='HotR>Cons>AS>SotR>HW>J';

k=k+1;prio(k)=prio(1);
prio(k).name='HotR>Cons>HW>AS>SotR>J';

k=k+1;prio(k)=prio(1);
prio(k).name='Cons>HotR>AS>SotR>HW>J';

k=k+1;prio(k)=prio(1);
prio(k).name='Cons>AS>HotR>SotR>HW>J';

k=k+1;prio(k)=prio(1);
prio(k).name='Cons>HW>AS>HotR>SotR>J';

k=k+1;prio(k)=prio(1);
prio(k).name='Inq*>HotR>J>AS>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='Inq>HotR>J>AS>Cons>HW';

k=k+1;prio(k)=prio(1);
prio(k).name='Inq>HotR>AS>Cons>HW>J';

k=k+1;prio(k)=prio(1);
prio(k).name='Inq>HotR>Cons>AS>HW>J';

k=k+1;prio(k)=prio(1);
prio(k).name='Inq>HotR>Cons>HW>AS>J';

k=k+1;prio(k)=prio(1);
prio(k).name='Inq>HotR>HW>Cons>AS>J';

k=k+1;prio(k)=prio(1);
prio(k).name='Inq>HotR>Cons>HW>AS>J>Inq*';

k=k+1;prio(k)=prio(1);
prio(k).name='Inq>HotR>Cons>HW>AS>J>Inq1*';

k=k+1;prio(k)=prio(1);
prio(k).name='HotR>Inq>Cons>HW>AS>J';

k=k+1;prio(k)=prio(1);
prio(k).name='HotR>Inq>Cons>HW>AS>J>Inq*';

k=k+1;prio(k)=prio(1);
prio(k).name='HotR>Inq>Cons>HW>AS>J>Inq1*';

k=k+1;prio(k)=prio(1);
prio(k).name='HotR>Inq>AS>Cons>HW>J>Inq*';

k=k+1;prio(k)=prio(1);
prio(k).name='HotR>Inq>AS>Cons>HW>J>Inq1*';

k=k+1;prio(k)=prio(1);
prio(k).name='HotR>Cons>HW>AS>Inq>J';

k=k+1;prio(k)=prio(1);
prio(k).name='HotR>Cons>HW>AS>Inq>J>Inq1*';

k=k+1;prio(k)=prio(1);
prio(k).name='HotR>AS>Cons>HW>Inq>J';

k=k+1;prio(k)=prio(1);
prio(k).name='Inq>AS>HotR>Cons>HW>J';

k=k+1;prio(k)=prio(1);
prio(k).name='AS>Inq>HotR>Cons>HW>J';

k2=k;


%#1 = SotR
%#2 = CS
%#3 = Jud
%#4 = AS
%#5 = HW
%#6 = Cons
%#7 = HotR
%#8 = SotR2
%#9 = Inq
%#10= HoW


%IMPORTANT for proper SotR handling, the label of SotR should be:
%  3  Holy Power: 'SotR'
% 1+,2+ Holy Power: 'SotRn'
%where n is the minimum HoPo strength.  This is for handling priority queues 
%where we have both SotR3 and SotR2.

for m=1:length(priolist)
    tmp.alabel{m}=priolist(m).alabel;
    eval(['tmp.' priolist(m).alabel '=' int2str(m) ';']);
end

%Automatic generation of "cast" and "condition" fields from "name" field
for m=1:k2
    %find the '>' signs in the queue names, these are delimiters
    ind=[0 find(prio(m).name=='>') length(prio(m).name)+1];
    
    %for each spell name
    for l=1:length(ind)-1
        
        %get spell name string
        snstr=prio(m).name((ind(l)+1):(ind(l+1)-1));
        
        %check snstr against the strings in the default spell list.  Should
        %return the id of the spell if it's found, 0 otherwise
        listid=sum(strcmp(snstr,tmp.alabel).*(1:length(tmp.alabel)));
        
        %store the id of the spell in prio.cast
        prio(m).cast(l)=listid;
        
        %if the spell handle is in the default list, add the conditions to the appropriate fields
        if listid~=0
            prio(m).cond{l}=priolist(listid).condition;

        %if the spell isn't found, it means we're using some special cases.
        %Handle each as appropriate
        elseif prio(m).cast(l)==0
            
            %check against special identifiers for 
            
            %Judgement
            if sum(strcmp(snstr,'J2'))
                prio(m).cast(l)=tmp.J; 
                prio(m).cond{l}='hopo>1';

            %SD fishing
            elseif sum(strcmp(snstr,'SD'))
                prio(m).cast(l)=tmp.J;
                prio(m).cond{l}='hopo>=3 && dur.SD<=0';

            %SotR* (3 hopo, only with Inq active)
            elseif sum(strcmp(snstr,{'SotR*'}))
                prio(m).cast(l)=tmp.SotR; %ShoR
                prio(m).cond{l}=[priolist(tmp.SotR).condition ' && dur.Inq>0'];
                
            %SotR2* (2 hopo, only with Inq active)
            elseif sum(strcmp(snstr,'SotR2*'))
                prio(m).cast(l)=tmp.SotR2; 
                prio(m).cond{l}='hopo>=2 && dur.Inq>0';
                
            %SDSotR (3 hopo, only with SD active)
            elseif sum(strcmp(snstr,'SDSotR'))
                prio(m).cast(l)=tmp.SotR; %2ShoR
                prio(m).cond{l}='hopo>=3 && dur.SD>0';
                                                
            %SDSotR* (3 hopo, only with SD and Inq active)
            elseif sum(strcmp(snstr,'SDSotR*'))
                prio(m).cast(l)=tmp.SotR; %2ShoR
                prio(m).cond{l}='hopo>=3 && dur.SD>0 && dur.Inq>0';
                
            %SDSotR2 (2 hopo, only with SD active)
            elseif sum(strcmp(snstr,'SDSotR2'))
                prio(m).cast(l)=tmp.SotR2; %2ShoR
                prio(m).cond{l}='hopo>=2 && dur.SD>0';
                
            %Inq*  (force refresh even if already active)
            elseif sum(strcmp(snstr,'Inq*'))
                prio(m).cast(l)=tmp.Inq; %Inq
                prio(m).cond{l}='hopo>=3';
                
            %Inq1*  (force refresh at any HP)
            elseif sum(strcmp(snstr,'Inq1*'))
                prio(m).cast(l)=tmp.Inq; %Inq
                prio(m).cond{l}='hopo>=1';
                
            %AS* (only with Inq active)
            elseif sum(strcmp(snstr,'AS*'))
                prio(m).cast(l)=tmp.AS; %AS
                prio(m).cond{l}='dur.Inq>0';
                
            %HotR* (only with Inq active)
            elseif sum(strcmp(snstr,'HotR*'))
                prio(m).cast(l)=tmp.HotR; %HotR
                prio(m).cond{l}='dur.Inq>0';
                
            %HoW* (only with Inq active)
            elseif sum(strcmp(snstr,'HoW*'))
                prio(m).cast(l)=tmp.HoW; %HoW
                prio(m).cond{l}='dur.Inq>0';
            end
        end

        %if it's *still* zero, we have a problem
        if prio(m).cast(l)==0
            error(['Spell identifier check failed on ''' snstr ''''])
        end

    end
    
    
end

%pretty output for troubleshooting
clear prilist*
for m=1:k1
    prilist(m,:)=[ num2str(m,'%03.0f') ' ' prio(m).name repmat(' ',1,40-length(prio(m).name)-4)];
end

for m=(k1+1):k2
    prilist2(m+1-k1,:)=[ num2str(m,'%03.0f') ' ' prio(m).name repmat(' ',1,40-length(prio(m).name)-4)];
end