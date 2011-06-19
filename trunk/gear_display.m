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


%% gear table
fnames=fieldnames(gstats);
statarray=zeros(size(fnames,1)-6,size(gstats,2));

for i=1:(size(fnames,1)-6)

    statarray(i,:)=[gstats.(char(fnames(i)))];

end

spacer=repmat(' ',size(fnames,1)-6,2);
glabels=char(fnames(1:size(fnames,1)-6));
tmpgvals=char(num2str(statarray,5));

%this section gets rid of extra spaces, since there's no control for that
%in num2str

%find index of barmor, that's always the longest number
for i=1:size(glabels,1)
    test=strfind(glabels(i,:),'barmor');
    if test
        armorind=i;
        break
    end
end

%determine max number of spaces
for i=10:-1:1
   test=strfind(tmpgvals(armorind,:),repmat(' ',1,i));
   if ~isempty(test)
       imax=i;
       break
   end
end
testsort=test;
for i=1:(imax-4)
    testsort=[testsort test+i];
end
gindx=setdiff(1:size(tmpgvals,2),testsort);
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

%find index of barmor, that's always the longest number
for i=1:size(plabels,1)
    test=strfind(plabels(i,:),'avoidpct');
    if test
        avoidpctind=i;
        break
    end
end

for i=10:-1:1
   test=strfind(tmppvals(avoidpctind,:),repmat(' ',1,i));
   if ~isempty(test)
       imax=i;
       break
   end
end
testsort=test;
for i=1:(imax-3)
    testsort=[testsort test+i];
end
pindx=setdiff(1:size(tmppvals,2),testsort);
pvals=tmppvals(:,pindx);

%display final table
player_table=[plabels spacer2 pvals]

