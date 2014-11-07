
meleeMatch='Melee Booi (?<base>\d+)';
dsMatch='Dummy Strike Booi (?<base>\d+)';
usMatch='Uber Strike Booi (?<base>\d+)';
blockMatch='\s\(B:\s(\d+)\)';
absMatch='\s\(A:\s(\d+)\)';

melee=[];
ds=[];
us=[];
imax=511;

mbase=zeros(imax,1);mabs=mbase;mblk=mbase;
dbase=mbase;dabs=dbase;dblk=dbase;
ubase=mbase;uabs=ubase;ublk=ubase;

amt=0;
for i=1:imax
    temp=booi_mythic{i};
    match=regexp(temp,meleeMatch,'tokens');
    if ~isempty(match)
        amt=str2num(char(match{1}));
        bmatch=regexp(temp,blockMatch,'tokens');
        if ~isempty(bmatch)
            amt=amt+str2num(char(bmatch{1}));
        end
        amatch=regexp(temp,absMatch,'tokens');
        if ~isempty(amatch)
            amt=amt+str2num(char(amatch{1}));
        end
        melee=[melee;amt];        
    end
    match=regexp(temp,dsMatch,'tokens');
    if ~isempty(match)
        amt=str2num(char(match{1}));
        bmatch=regexp(temp,blockMatch,'tokens');
        if ~isempty(bmatch)
            amt=amt+str2num(char(bmatch{1}));
        end
        amatch=regexp(temp,absMatch,'tokens');
        if ~isempty(amatch)
            amt=amt+str2num(char(amatch{1}));
        end
        ds=[melee;amt];         
    end
    match=regexp(temp,usMatch,'tokens');
    if ~isempty(match)
        amt=str2num(char(match{1}));
        bmatch=regexp(temp,blockMatch,'tokens');
        if ~isempty(bmatch)
            amt=amt+str2num(char(bmatch{1}));
        end
        amatch=regexp(temp,absMatch,'tokens');
        if ~isempty(amatch)
            amt=amt+str2num(char(amatch{1}));
        end
        us=[melee;amt];        
    end
    
    
end

raw_melee=melee./(1-0.3847)./(1-0.0062)/0.8;
raw_ds=ds./(1-0.3847)./(1-0.0062)/0.8;
raw_us=us./0.8;