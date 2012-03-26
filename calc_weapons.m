%CALC_WEAPONS calculates the relative DPS output of different weapons

%% Setup Tasks
clear;
%load gear database
gear_db;
%load defaults database
def_db;

%% Configurations
%create the first configuation
%low hit, SotR/SoT build
%set melee hit to 2%, expertise to 5%
%do this by altering shirt stats
cfg(1)=build_config('hit',2,'exp',5,'glyph',[0 0 0]); 

%hit-cap and exp soft-cap
cfg(2)=build_config('hit',7.5,'exp',7.5,'glyph',[0 0 0]);


%% List of weapons
%ordered pairs of [itemid category], categories are 1=tank, 2=DPS, 3=SP
weaplist=[  69609 1;    %Bloodlord's Protector
            69639 1;    %Renataki's Soul Slicer
            59459 3;    %Andoros, Fist of the Dragon King
            71006 3;    %Volcanospike
            71312 2;    %Gatecrasher
            71406 1;    %Mandible of Beth'tilac (Heroic)
            77193 1;    %Souldrinker
            78371 2;    %Hand of Morchok (Heroic) 410
          ];
      
wids=weaplist(:,1);
wcat=weaplist(:,2);
          
M=length(wids);  %total number of weapons
M1=sum(wcat==1);M2=sum(wcat==2);M3=sum(wcat==3); %length of each individual section


%% Crank

for g=1:length(cfg)
    %set configuration variables
    
    c=cfg(g);
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    dps0(:,g)=repmat(c.rot.dps,M,1);
    hps0(:,g)=repmat(c.rot.dps,M,1);
    
    wb=waitbar(0,['Calculating Weapons']);
    tic
    for m=1:M
        
        %equip the appropriate weapon
        c.egs(15)=equip(weaplist(m));
        %handle socketing
        if isfield(c.egs(15),'socket') && isempty(c.egs(15).socket)==0
            switch c.egs(15).socket
                case 'R'
                    c.egs(15)=socket(c.egs(15),gem.red);
                case 'Y'
                    c.egs(15)=socket(c.egs(15),gem.yel);
                case 'B'
                    c.egs(15)=socket(c.egs(15),gem.blu);
            end
        end
        
        %store useful info for plots
        winfo.name{m,1}=c.egs(15).name;
        winfo.ilvl(m,1)=c.egs(15).ilvl;
        
        
        %calculate DPS
        c=stat_model(c);
        c=ability_model(c);
        c=rotation_model(c);
        
        dps(m,g)=c.rot.dps;
        hps(m,g)=c.rot.hps;
        waitbar(m/M,wb)
        
    end
    close(wb)
    
end

toc

wdps=dps-dps0;
whps=hps-hps0;
    
% winfo.name=char(winfo.name);
% winfo.labels=[winfo.name repmat(' ',length(winfo.ilvl),2) int2str(winfo.ilvl')];


%% Table
%TODO: Sorting
ldat=2+[1:M];

li=DataTable();
li{1:2,1}={' ';'Weapon'};      
li{ldat,1}=winfo.name;
li{1:2,2}={' ';'ilvl'};      
li{ldat,2}=winfo.ilvl;

for g=1:length(cfg)
    
li{1:2,2*g+1}={['cfg' int2str(g)];'DPS'};
li{ldat,2*g+1}=round(wdps(:,g));

li{1:2,2*g+2}={['cfg' int2str(g)];'HPS'};
li{ldat,2*g+2}=round(whps(:,g));

end     
li.setColumnTextAlignment(1,'left')
% li.setColumnFormat(3:4,'%6.0f')
li.toText()

%% Plots
% 
% %number of weapons to skip in each category
% m1=7;
% m2=5;
% m3=8;
% m1=0;m2=0;m3=0;
% 
% %indices of desired weapons
% i1=(1+m1):M1;
% i2=M1+((1+m2):M2);
% i3=M1+M2+((1+m3):M3);
% 
% %y-values for plots
% y1=1:(M1-m1);
% y3=(M1-m1)+1+(1:(M3-m3));
% % y2=M1+1+[1:M2];
% % y3=max(y2)+1+[1:M3];
% 
% %combine indices and y values from different sections
% y=[y1 y3];
% i=[i1 i3];
% 
% %construct DPS tables for plotting and sorting
% dps70=[wdps(:,3) diff(wdps(:,3:4)')']./1000;
% pinfo.plotlabels70=pinfo.labels(i,:);
% dps70p=dps70(i,:);
% xmin70=min(dps70p(:,1));
% xmax70=max(sum(dps70p,2));
% 
% dps71=[wdps(i1,3) diff(wdps(i1,3:4)')']./1000;
% [x71 k71]=sort(dps71(:,1));y71=y1(k71);
% temp=pinfo.labels(i1,:);
% pinfo.plotlabels71=temp(k71,:);
% dps71p=dps71(k71,:);
% xmin71=min(dps71p(:,1));
% xmax71=max(sum(dps71p,2));
% 
% %All weapons plot
% figure(70)
% % set(gcf,'Position',[2200 12 724 936])
% bar70=barh(y,dps70p,'BarWidth',0.5,'BarLayout','stacked');
% set(bar70(2),'FaceColor',[0.749 0.749 0]);
% xlim([0.99.*xmin70 1.01.*xmax70])
% ylim(0.5+[0 max(y)])
% set(gca,'YTick',y,'YTickLabel',pinfo.plotlabels70)
% xlabel('DPS (thousands)')
% title('All by ilvl & category - CS rotation')
% legend('4% hit 18 exp','8% hit 26 exp','Location','Best')
% 
% 
% figure(71)
% % set(gcf,'Position',[2240 88 724 579])
% bar71=barh(dps71p,'BarWidth',0.5,'BarLayout','stacked');
% set(bar71(2),'FaceColor',[0.749 0.749 0]);
% xlim([0.99.*xmin71 1.01.*xmax71])
% ylim(0.5+[0 max(y1)])
% set(gca,'YTick',y1,'YTickLabel',pinfo.plotlabels71)
% xlabel('DPS (thousands)')
% title('Tank weapons, sorted by DPS')
% legend('4% hit 18 exp','8% hit 26 exp','Location','Best')
