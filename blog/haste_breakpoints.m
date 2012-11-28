hasteBP=[10:20:100];
modRB=1.05;
modBL=1.3;
modSoI=1.1;
ratingConversion=425;
T0=6000;
D0=30000;
mods=[1;modRB;modSoI;modRB.*modSoI;modBL;modBL*modRB;modBL*modSoI;modBL*modSoI*modRB];
hasteRating=0:50e3;
modLabels={'None';'RB';'SoI';'RB+SoI';'BL';'BL+RB';'BL+SoI';'BL+SoI+RB'};

li=DataTable();
li{1,1}='haste%';
li{1,2:7}={'10%','30%','50%','70%','90%','110%'};
li{2,1}='N';
li{2,2:7}=6:11;
li{2+(1:length(mods)),1}=modLabels;
li{2+(1:length(mods)),2:7}=zeros(length(mods),6);

for j=1:length(mods)
    m=mods(j);
    spellHaste=(1+hasteRating./42500).*m;
    T=round(T0./spellHaste);
    N=round2even(D0./T);
    
    inds=find(diff(N));
    for i=1:length(inds)
        
        n=N(inds(i)+1);
        h=hasteRating(inds(i)+1);
        
        %table assignments
        if n<12
            li{2+j,n-4}=int2str(h);
        end
        
        %debug
        nlist(j,i)=n;
        hlist(j,i)=h;
    end
    
    
    
end

li.toText()

%% again, for EF

T02=3000;
D0=30000;
mods=[1;modRB;modSoI;modRB.*modSoI;modBL;modBL*modRB;modBL*modSoI;modBL*modSoI*modRB];
hasteRating2=0:50e3;

li2=DataTable();
li2{1,1}='haste%';
li2{1,2:10}={'5%','15%','25%','35%','45%','55%','65%','75%','85%'};
li2{2,1}='N';
li2{2,2:10}=11:19;
li2{2+(1:length(mods)),1}=modLabels;
li2{2+(1:length(mods)),2:10}=zeros(length(mods),9);

for j=1:length(mods)
    m=mods(j);
    spellHaste=(1+hasteRating./42500).*m;
    T2=round(T02./spellHaste);
    N2=round2even(D0./T2);
    
    inds2=find(diff(N2));
    for i=1:length(inds2)
        
        n2=N2(inds2(i)+1);
        h2=hasteRating(inds2(i)+1);
        
        %table assignments
        if n2<20
            li2{2+j,n2-9}=int2str(h2);
        end
        
        %debug
        nlist2(j,i)=n2;
        hlist2(j,i)=h2;
    end
    
    
    
end

li2.toText()