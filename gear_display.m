gear_db;
def_db;

for q=1:5
    
    exec=execution_model('veng',1);  %placeholder, set in cfg
    base=player_model('race','Human');
    npc=npc_model(base);

    egs=ddb.gearset{q};
    gear_stats;
    gstats(q)=gear;
    talent=ddb.talentset{1}; %placeholder, set in cfg
    glyph=ddb.glyphset{1}; %placeholder, set in cfg
    talents;
    buff=buff_model;
    stat_model;
    ability_model;

    pstats(q)=player;
end

fnames=fieldnames(gstats);
statarray=zeros(size(fnames,1)-6,size(gstats,2));

for i=1:(size(fnames,1)-6)

    statarray(i,:)=[gstats.(char(fnames(i)))];

end

spacer=repmat(' ',size(fnames,1)-6,2);
[char(fnames(1:size(fnames,1)-6)) spacer char(num2str(statarray,5))]


fnames2=fieldnames(pstats);
statarray2=zeros(size(fnames2,1),size(pstats,2));

for i=1:(size(fnames2,1))
    if ~isstruct(pstats(1).(char(fnames2(i))))
        statarray2(i,:)=[pstats.(char(fnames2(i)))];
    else
        statarray2(i,:)=zeros(1,size(pstats,2));
    end
    
end

spacer2=repmat(' ',size(fnames2,1),2);
[char(fnames2(1:size(fnames2,1))) spacer2 char(num2str(statarray2,6))]

% pp2=[char(fnames2(1:size(fnames2,1)))];
% for i=1:size(statarray2,2)
%    pp2=[pp2 spacer2 char(num2str(statarray2(:,i),'%5.3f'))]; 
% end
% pp2