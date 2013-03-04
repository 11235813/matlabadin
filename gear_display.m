disp('------------- GEAR_DISPLAY -------------')
gear_db;
def_db;
c=build_config;

for q=1:length(ddb.gearset)
    
    c.egs=ddb.gearset{q};
    c.gear=gear_stats(c.egs);
    
    %store stats
    gstats(q)=c.gear;
    
    %calculate dps
    c=stat_model(c);
    c=ability_model(c);

    pstats(q)=c.player;
end


%% gear table
fnames=fieldnames(gstats);
stopat=find(strcmp(fnames,'swing'));

lig=DataTable();
lig{1:2,1}={'ilvl->';'Stat'};
lig{1,1+[1:q]}=[gstats.medilvl];
lig{2+(1:stopat),1}=[fnames(1:stopat)];


% statarray=zeros(size(fnames,1)-stopat,size(gstats,2));

for i=1:stopat

    lig{2+i,1+[1:q]}=round([gstats.(char(fnames(i)))]);

end

%fix for avg dmg and swing
lig{1+i,1+[1:q]}=cellstr(num2str([gstats.(char(fnames(i-1)))]','%6.1f'))';
lig{2+i,1+[1:q]}=cellstr(num2str([gstats.(char(fnames(i)))]','%6.2f'))';

lig.toText()


%% Player table
fnames2=fieldnames(pstats);
stopat2=length(fnames2);
% statarray2=zeros(size(fnames2,1),size(pstats,2));

lip=DataTable();
lip{1:2,1}={'ilvl->';'Stat'};
lip{1,1+[1:q]}=[gstats.medilvl];
j=3;
for i=1:(size(fnames2,1))
    
    if ~isstruct(pstats(1).(char(fnames2(i))))
        lip{j,1}=fnames2(i);
        lip{j,1+(1:q)}=[pstats.(char(fnames2(i)))];
        j=j+1;
    end
    
end
lip.setColumnFormat(1+(1:q),'%6.3f')
lip.toText();

