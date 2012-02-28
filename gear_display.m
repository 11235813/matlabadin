gear_db;
def_db;

for q=1:8
    
    exec=execution_model('veng',1); 
    base=player_model('race','Human');
    npc=npc_model(base);

    egs=ddb.gearset{q};
    gear_stats;
    gstats(q)=gear;
    talent=ddb.talentset{1};
    glyph=ddb.glyphset{1};
    talents;
    buff=buff_model;
    stat_model;
    ability_model;

    pstats(q)=player;
end


%% gear table
fnames=fieldnames(gstats);
stopat=length(fnames)-find(strcmp(fnames,'swing'));
statarray=zeros(size(fnames,1)-stopat,size(gstats,2));

for i=1:(size(fnames,1)-stopat)

    statarray(i,:)=[gstats.(char(fnames(i)))];

end

spacer=repmat(' ',size(fnames,1)-stopat,2);
glabels=char(fnames(1:size(fnames,1)-stopat));
tmpgvals=char(num2str(statarray,5));

%this section gets rid of extra spaces, since there's no control for that
%in num2str
clear spacewidth skiplist skipstart

%find max number of spaces on each row
for i=1:size(tmpgvals,1)
    for j=1:10
        test=strfind(tmpgvals(i,:),repmat(' ',1,j));
        if test
           spacewidth(i)=j-1;
        end
    end
end

%pick the minimum value and row index
[mval mind]=min(spacewidth);


%find the indices of the empty spaces
skipstart=strfind(tmpgvals(mind,:),repmat(' ',1,mval));

%set the spacing to 3 spaces by identifying the indices of everything we
%want to delete
skiplist=skipstart;
for i=1:(mval-3)
    skiplist=[skiplist skipstart+i];
end

%pull out only the elements that are not on the skip list
gindx=setdiff(1:size(tmpgvals,2),skiplist);

%keep only those elements
gvals=tmpgvals(:,gindx);

%display final table
gear_table=[glabels spacer gvals]


%% Player table
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
plabels=char(fnames2(1:size(fnames2,1)));
tmppvals=char(num2str(statarray2,6));

%this section gets rid of extra spaces, since there's no control for that
%in num2str

clear spacewidth skiplist skipstart

%find max number of spaces on each row
for i=1:size(tmppvals,1)
    for j=1:10
        test=strfind(tmppvals(i,:),repmat(' ',1,j));
        if test
           spacewidth(i)=j-1;
        end
    end
end
%pick the minimum value and row index
[mval mind]=min(spacewidth);

%find the indices of the empty spaces
skipstart=strfind(tmppvals(mind,:),repmat(' ',1,mval));

%set the spacing to 3 spaces by identifying the indices of everything we
%want to delete
skiplist=skipstart;
for i=1:(mval-3)
    skiplist=[skiplist skipstart+i];
end

%pull out only the elements that are not on the skip list
pindx=setdiff(1:size(tmppvals,2),skiplist);

%keep only those elements
pvals=tmppvals(:,pindx);

%display final table
player_table=[plabels spacer2 pvals]



%% different method

