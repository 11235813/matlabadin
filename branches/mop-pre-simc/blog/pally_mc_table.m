function li = pally_mc_table(statSetup,statblock,config,gearsets)


%unpack
dmg=[statblock(gearsets).dmg];
S=[statblock(gearsets).S];
if nargin<4
    n=length(statSetup);
    names={statSetup.name};
    totalHP=[statblock.totalHitPoints];
    health=[statblock.health];
else
    n=length(gearsets);
    names={statSetup(gearsets).name};
    totalHP=[statblock(gearsets).totalHitPoints];
    health=[statblock(gearsets).health];    
end
jMin=config.jbounds(1);
jStep=config.jbounds(2);
jMax=config.jbounds(3);


li=DataTable();
li{1:6,1}={'Set:';'mean';'std';'S%';'HP';'nHP'};
li{1,1+(1:n)}=names;
matemp=filter(ones(1,5)./5,1,dmg);
li{2,1+(1:n)}=mean(matemp);
li{3,1+(1:n)}=std(matemp);
li{4,1+(1:n)}=S;
li{5,1+(1:n)}=cellstr([int2str(round(totalHP./1e3)') repmat('k',length(totalHP),1)])';
li{6,1+(1:n)}=health;
linePH=0;
healthScaleFactor2=repmat(health,size(matemp,1),1);
for j=jMin:jStep:jMax
    matemp=filter(ones(1,j),1,dmg);
    if n<=4
        li{7+linePH,1:5}={'----',['--- ' int2str(j)],'Attack','Moving','Avg.--'};
    elseif n==5
        li{7+linePH,1:6}={'----',['--- ' int2str(j)],'Attack','Moving','Avg.--','------'};
    else
        li{7+linePH,1:(1+n)}=[{'----'},repmat({'------'},[1 min(1,n-6)]),{['--- ' int2str(j)],'Attack','Moving','Avg.--'} repmat({'------'},[1 (n-4-min(1,n-6))])];
    end
    linePH=linePH+1;
    for qq=0.1:0.1:2
        temp=sum((matemp./healthScaleFactor2)>qq)./size(matemp,1).*100;
        if max(temp)>=0.001 && min(temp)<50
            li{7+linePH,1}=[int2str(int32(qq.*100)) '%'];
            li{7+linePH,1+(1:n)}=temp;
            linePH=linePH+1;
        end
    end
end
li.setColumnFormat(1+(1:n),'%1.3f')
disp('<pre>')
disp(['Finisher = ' config.finisher ', Boss Attack = ' int2str(config.bossSwingDamage./1e3) 'k, SoI model=' config.soimodel ' data set ' config.filetype '-' int2str(config.simMins) '-' int2str(config.fileid)])
li.toText()
disp('</pre>')

end