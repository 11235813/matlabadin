%CALC_WEAPONS calculates the relative DPS output of different weapons

%% Setup Tasks
clear;
disp('------------- CALC_WEAPONS -------------')
%load gear database
gear_db;
%load defaults database
def_db;

%% Configurations
%create the first configuation
%set melee hit to 2%, expertise to 5%
%do this by altering shirt stats
cfg(1)=build_config('hit',2.5,'exp',7.5,'race','Belf'); 

%human setup, for racial expertise bonus
cfg(2)=cfg(1);
cfg(2).base=player_model('race','Human');
cfg(2)=stat_model(cfg(2));

%hit-cap and exp cap
cfg(3)=build_config('hit',7.5,'exp',15,'race','Belf');


%% List of weapons
%ordered pairs of [itemid category], categories are 1=tank, 2=DPS, 3=Agi
weaplist=[  
%             81061 1;    %Ook's Hozen Slicer (Heroic)
%             81063 2;    %Dubious Handaxe (Heroic)
%             81089 3;    %Crescent of Ichor
%             82971 3;    %Masterwork Ghost-Forged Blade
%             82972 2;    %Masterwork Phantasmal Hammer
%             89396 2;    %Amber Espada of Klaxxi'vess
%             89400 3;    %Amber Sledge of Klaxxi'vess
%             81062 3;    %Gao's Keg Tapper (Heroic)
%             81273 3;    %Siege-Captain's Scimitar (Heroic)
            84968 2;    %Malevolent Gladiator's Slicer
            87570 3;    %The Horseman's Sinister Slicer
            87545 1;    %Inelava, Spirit of Inebriation
            86789 1;    %Elegion, the Fanged Crescent (LFR)
            88150 1;    %Krol Scimitar
            86863 1;    %Scimitar of Seven Stars (LFR)
            86906 1;    %Kilrak, Jaws of Terror (LFR)
            86130 1;    %Elegion, the Fanged Crescent
            85134 2;    %Malevolent Gladiator's Slicer (Elite)
            86219 1;    %Scimitar of Seven Stars
            86387 1;    %Kilrak, Jaws of Terror
            87062 1;    %Elegion, the Fanged Crescent (Heroic)
            86987 1;    %Scimitar of Seven Stars
            87173 1;    %Kilrak, Jaws of Terror (Heroic)
            2 1;    %Kilrak, Jaws of Terror (LFR+Gem)
            3 1;    %Kilrak, Jaws of Terror (Norm+Gem)
            4 1;    %Kilrak, Jaws of Terror (Heroic+Gem)
            95504 3; %Zeeg's Ancient Kegsmasher
            95758 1; %Acid-Spine Bonemace (LFR)
            95632 1; %Worldbreaker's Stormscythe (Heroic)
            95666 3; %Kura-Kura, Kazra'jin's Skullcleaver (LFR)
            95686 2; %Shellsplitter Greataxe (LFR)
            95770 3; %Hand of the Dark Animus (LFR)
            95790 1; %Qon's Flaming Scimitar (LFR)
            95861 3; %Zeeg's Ancient Kegsmasher (LFR)
            95876 1; %Do-tharak, the Swordbreaker (LFR)
            95502 1; %Do-tharak, the Swordbreaker
            95504 3; %Zeeg's Ancient Kegsmasher
            94964 1; %Qon's Flaming Scimitar
            94954 3; %Hand of the Dark Animus
            94937 1; %Acid-Spine Bonemace
            94768 2; %Shellsplitter Greataxe
            94759 3; %Kura-Kura, Kazra'jin's Skullcleaver
            94722 1; %Worldbreaker's Stormscythe
            96130 1; %Acid-Spine Bonemace (Thunderforged)
            96058 2; %Shellsplitter Greataxe (Thunderforged)
            96004 1; %Worldbreaker's Stormscythe (Thunderforged)
            96620 1; %Do-tharak, the Swordbreaker (Heroic)
            96605 3; %Zeeg's Ancient Kegsmasher (Heroic)
            96534 1; %Qon's Flaming Scimitar (heroic)
            96514 3; %Hand of the Dark Animus (Heroic)
            96502 1; %Acid-Spine Bonemace (Heroic)
            96430 2; %Shellsplitter Greataxe (Heroic)
            96410 3; %Kura-Kura, Kazra'jin's Skullcleaver (Heroic)
            96376 1; %Worldbreaker's Stormscythe (Heroic)
            
            
          ];
      
wids=weaplist(:,1);
wcat=weaplist(:,2);
          
M=length(wids);  %total number of weapons
N(1)=sum(wcat==1);N(2)=sum(wcat==2);N(3)=sum(wcat==3); %length of each individual section


%% Crank

for g=1:length(cfg)
    %set configuration variables
    
    c=cfg(g);
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    wb=waitbar(0,['Calculating Weapons for config #' int2str(g) ', ' c.egs(15).name]);
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
        waitbar(m/M,wb,['Calculating Weapons for config #' int2str(g) ', ' c.egs(15).name])
        c=rotation_model(c);
        
        wdps(m,g)=c.rot.dps;
        whps(m,g)=c.rot.hps;
        toc
        
    end
    close(wb)
    
end

toc

    
%% Table
sortdata=[weaplist(:,2) winfo.ilvl];
[ilvlsorted ind]=sortrows(sortdata);
n=[0 cumsum(N)];

%this constructs the table but divides it by weapon type, inserting a blank
%line in between sections
li=DataTable();
for type=1:3
    
    %row indices for the table
    ldat=2+ ...         %header
        n(type)+ ...    %previous full rows
        [1:N(type)]+... %new rows
        (type-1);       %extra spaces    
    
    %indices of table for this weapon type
    subind=ind(n(type)+[1:N(type)]);
    
    %fill in the name and ilvl columns
    li{1:2,1}={' ';'Weapon'};
    li{ldat,1}=winfo.name(subind);
    li{1:2,2}={' ';'ilvl'};
    li{ldat,2}=winfo.ilvl(subind);
    
    %fill in DPS columns for each configuration
    for g=1:length(cfg)
        
        %DPS
        li{1:2,2*g+1}={['cfg' int2str(g)];'DPS'};
        li{ldat,2*g+1}=round(wdps(subind,g));
        
        %HPS
        li{1:2,2*g+2}={['cfg' int2str(g)];'HPS'};
        li{ldat,2*g+2}=round(whps(subind,g));
        
    end
    
end
li.setColumnTextAlignment(1,'left')
% li.setColumnFormat(3:4,'%6.0f')
disp('[code]')
li.toText()
disp('[/code]')

%% Weapon plots, by section

wtype={'Tank';'DPS';'Spell power'};
for type=1:3
    
    subind=ind(n(type)+[1:N(type)]);
    plotdps=[wdps(subind,1) diff(wdps(subind,1:2),1,2) diff(wdps(subind,2:3),1,2)]./1e3;
    spacer=repmat(' ',N(type),1);
    plotaxislabels=strcat([spacer],winfo.name(subind), ...
                    [spacer spacer int2str(winfo.ilvl(subind))]);
    
    figure(70+type)
    % set(gcf,'Position',[2240 88 724 579])
    bar7x=barh(plotdps,'BarWidth',0.5,'BarLayout','stacked');
    set(bar7x(2),'FaceColor',[0 0.5 0]);
    set(bar7x(3),'FaceColor',[0.749 0.749 0]);
    xlim([0.99.*min(plotdps(:,1)) 1.01.*max(sum(plotdps,2))])
    ylim(0.5+[0 N(type)])
    set(gca,'YTick',1:N(type),'YTickLabel',plotaxislabels, ...
            'OuterPosition',[0.01 0 0.99 1])
    xlabel('DPS (thousands)')
    title([char(wtype(type)) ' weapons, sorted by ilvl, then DPS'])
    legend([num2str(cfg(1).player.mehit,'%g') '% hit, ' num2str(cfg(1).player.exp,'%g') '% exp'], ...
       [num2str(cfg(2).player.mehit,'%g') '% hit, ' num2str(cfg(2).player.exp,'%g') '% exp'], ...
       [num2str(cfg(3).player.mehit,'%g') '% hit, ' num2str(cfg(3).player.exp,'%g') '% exp'], ...
        'Location','Best')

end


%% All weapons, sorted by type and ilvl
% spacer=repmat(' ',M,1);
% allplotilvl=[wdps(ind,1) diff(wdps(ind,1:2),1,2) diff(wdps(ind,2:3),1,2)]./1e3;
% allplotaxislabels=strcat([spacer],winfo.name(ind),[spacer spacer int2str(winfo.ilvl(ind))]);
% y74=[0 cumsum(diff(ilvlsorted(:,1)))']+(1:M);
% 
% figure(74)
% bar74=barh(y74,allplotilvl,'BarWidth',0.5,'BarLayout','stacked');
% set(bar74(2),'FaceColor',[0.0 0.5 0]);
% set(bar74(3),'FaceColor',[0.749 0.749 0]);
% xlim([0.99.*min(allplotilvl(:,1)) 1.01.*max(sum(allplotilvl,2))])
% ylim(0.5+[0 max(y74)])
% set(gca,'YTick',y74,'YTickLabel',allplotaxislabels, ...
%     'OuterPosition',[0.01 0 0.99 1])
% xlabel('DPS (thousands)')
% title(['All weapons, sorted by type and DPS'])
% legend([num2str(cfg(1).player.mehit,'%g') '% hit, ' num2str(cfg(1).player.exp,'%g') '% exp'], ...
%        [num2str(cfg(2).player.mehit,'%g') '% hit, ' num2str(cfg(2).player.exp,'%g') '% exp'], ...
%        [num2str(cfg(3).player.mehit,'%g') '% hit, ' num2str(cfg(3).player.exp,'%g') '% exp'], ...
%         'Location','Best')
    
%% All weapons, sorted by DPS
spacer=repmat(' ',M,1);
[dpssorted inddps]=sortrows(wdps,1);
%arrange array for plottin
allplotdps=[wdps(inddps,1) diff(wdps(inddps,1:2),1,2) diff(wdps(inddps,2:3),1,2)]./1e3;
allplotdpsaxislabels=strcat([spacer],winfo.name(inddps),[spacer spacer int2str(winfo.ilvl(inddps))]);
y75=[1:M];

figure(75)
bar75=barh(y75,allplotdps,'BarWidth',0.5,'BarLayout','stacked');
set(bar75(2),'FaceColor',[0.0 0.5 0]);
set(bar75(3),'FaceColor',[0.749 0.749 0]);
xlim([0.99.*min(allplotdps(:,1)) 1.01.*max(sum(allplotdps,2))])
ylim(0.5+[0 max(y75)])
set(gca,'YTick',y75,'YTickLabel',allplotdpsaxislabels, ...
    'OuterPosition',[0.01 0 0.99 1])
xlabel('DPS (thousands)')
title(['All weapons, sorted by DPS'])
legend([num2str(cfg(1).player.mehit,'%g') '% hit, ' num2str(cfg(1).player.exp,'%g') '% exp'], ...
       [num2str(cfg(2).player.mehit,'%g') '% hit, ' num2str(cfg(2).player.exp,'%g') '% exp'], ...
       [num2str(cfg(3).player.mehit,'%g') '% hit, ' num2str(cfg(3).player.exp,'%g') '% exp'], ...
        'Location','Best')