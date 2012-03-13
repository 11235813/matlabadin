%CALC_STATSCALING calculates the scaling of our abilites with different
%stats

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
c(1)=build_config('hit',2,'exp',5); 

%low hit, WoG/SoI build
c(2)=build_config('hit',2,'exp',5,'seal','SoI');

%% Stat components
stat={'exp';'hit';'str';'ap';'sta';'crit';'agi';'haste';'sp';'int';'mas'};
M=length(stat);  %number of "extra" stats

%load itemization factors (i.e. because 10 STR = 20 AP = 15 STA = 11.6 SP)
stat_conversions

%Note: this is confusing; the primary purpose of this array was to perform
%smoothing on the graphs by making larger increments, but that purpose has
%been mostly abandoned.  I was also using this to (erroneously) determine
%stat weights.  I've since corrected the error, but for 5.0 we should fix
%this nomenclature.
% FIXME (redundancy)
%stat itemization factors for weight calculations
% icv=10.*[ipconv.exp ipconv.hit ipconv.str ipconv.ap ipconv.sta ipconv.crit...
%     ipconv.agi ipconv.has ipconv.sp ipconv.int ipconv.mas];
dstat=10;


%% Strength calcs
%reset extra structure
str_range=-100+linspace(1,1500,250);
[temp idx]=min(abs(str_range));
sdps=zeros(M,length(str_range),length(c));
sdps0=zeros(size(sdps));

tic
for g=1:length(c)
    %set configuration variables
    cfg=c(g);
    
    %construct extra fields
    cfg.extra=extra_init;
    cfg.extra.val.str=str_range;
    
    %calculate baseline DPS
    cfg=stat_model(cfg);
    cfg=ability_model(cfg);
    cfg=rotation_model(cfg);
    
    %store baseline
    sdps0(1:M,:,g)=repmat(cfg.rot.dps,[M 1 1]);
    shps0(1:M,:,g)=repmat(cfg.rot.hps,[M 1 1]);
    
    %waitbar
    csswb=waitbar(0,'Calculating STR Scaling');
    set(csswb,'Position',get(csswb,'Position')+[0 85 0 0]);
    
    %for each stat
    for m=1:M
        waitbar(m./M,csswb,['Calculating STR Scaling for ' stat{m} ...
                            ' in cfg ' int2str(g) '/' int2str(length(c))]);
                        
        %set each stat to dstat extra
        eval(char(['extra.itm.' stat{m} '=dstat.*ipconv.' stat{m} ';']))

        %recalculate DPS
        cfg=stat_model(cfg);
        cfg=ability_model(cfg);
        cfg=rotation_model(cfg);
        
        sdps(m,:,c)=cfg.rot.dps;
        shps(m,:,c)=cfg.rot.hps;
        
        %set each stat back to 0 extra
        eval(char(['extra.itm.' stat{m} '=0;']))

        %recalculate DPS
        cfg=stat_model(cfg);
        cfg=ability_model(cfg);
        cfg=rotation_model(cfg);
        
        sdps0(m,:,c)=tmprot.dps+proc.dps;
        shps0(m,:,c)=tmprot.hps+proc.hps;

    end
    close(csswb)
end
toc
%% Strength Graphs / Table
sdiffdps=(sdps-sdps0).*10./repmat(dstat',[1 size(sdps,2) size(sdps,3)]);
sdiffhps=(shps-shps0).*10./repmat(dstat',[1 size(shps,2) size(shps,3)]);
xS=player.armorystr';
yS1=squeeze(sdiffdps(:,:,1))';
yS2=squeeze(sdiffdps(:,:,2))';

disp('SHPS and stat weights for config #1')
[char(stat) repmat(' ',length(stat),2)  num2str(sdiffhps(:,idx,1)) repmat(' ',length(stat),3) num2str(sdiffdps(:,idx,1)./dstat')]
disp('SHPS and stat weights for config #2')
[char(stat) repmat(' ',length(stat),2)  num2str(sdiffhps(:,idx,2)) repmat(' ',length(stat),3) num2str(sdiffdps(:,idx,2)./dstat')]
disp('Stat DPS values for config #1')

figure(50)
set(gcf,'Position',[290    92   706   414])
plot(xS,yS1)
xlim([min(player.armorystr) max(player.armorystr)])
legend(stat,'Location','EastOutside')
xlabel('Armory Strength')
ylabel('DPS per 10 itemization points')
title([cfg(1).label ', '  num2str(cfg(1).veng*100,'%2.1f') '% Veng, ' num2str(cfg(1).hit,'%2.1f') '% hit, ' num2str(cfg(1).exp,'%2.1f') ' expertise'])

figure(51)
set(gcf,'Position',[290    92   706   414])
plot(xS,yS2)
xlim([min(xS) max(xS)])
legend(stat,'Location','EastOutside')
xlabel('Armory Strength')
ylabel('DPS per 10 itemization points')
title([cfg(2).label ', ' num2str(cfg(2).veng*100,'%2.1f') '% Veng, ' num2str(cfg(2).hit,'%2.1f') '% hit, ' num2str(cfg(2).exp,'%2.1f') ' expertise'])

%% Hit graph
tic
for c=1:length(cfg)
    
    %reset extra structure
    extra_init;

    %set configuration variables
    egs(1)=cfg(c).helm;
    exec=execution_model('veng',cfg(c).veng,'seal',cfg(c).seal);
    glyph=cfg(c).glyph;
    talent=cfg(c).talent;
    queue.rot=cfg(c).queue;
    gear_stats;
    talents;
    stat_model;

    %store items in cfg for plots
    cfg(c).exp=player.exp;
    
    %define hit range such that it covers 0 to 10%
    extra.val.hit=(-player.phhit+linspace(0,10,100)).*cnv.hit_phhit;
[temp idx]=min(abs(extra.val.hit));
    
    csswb=waitbar(0,'Calculating Hit Scaling');
    set(csswb,'Position',get(csswb,'Position')+[0 85 0 0]);
    for m=1:M
        waitbar(m./M,csswb,['Calculating Hit Scaling for ' stat{m} ...
                            ' in cfg ' int2str(c) '/' int2str(length(cfg))]);
        %set each stat to dstat extra
        eval(char(['extra.itm.' stat{m} '=dstat(m);']))

        stat_model;ability_model;rotation_model;
        
        tmprot.dps=rot(cfg(c).rot).totdps;
        tmprot.hps=rot(cfg(c).rot).tothps;
        dynamic_model;
        hdps(m,:,c)=tmprot.dps+proc.dps;
        hhps(m,:,c)=tmprot.hps+proc.hps;

        %set each stat back to 0 extra
        eval(char(['extra.itm.' stat{m} '=0;']))

        stat_model;ability_model;rotation_model;
        tmprot.dps=rot(cfg(c).rot).totdps;
        tmprot.hps=rot(cfg(c).rot).tothps;
        dynamic_model;
        hdps0(m,:,c)=tmprot.dps+proc.dps;
        hhps0(m,:,c)=tmprot.hps+proc.hps;
        
        toc
        
    end
    close(csswb)
end
toc
hdiffdps=(hdps-hdps0).*10./repmat(dstat',[1 size(hdps,2) size(hdps,3)]);
hdiffhps=(hhps-hhps0).*10./repmat(dstat',[1 size(hhps,2) size(hhps,3)]);
xH=player.phhit';
yH1=squeeze(hdiffdps(:,:,1))';
yH2=squeeze(hdiffdps(:,:,2))';

% disp('SHPS per 10 stat points for config #1')
% [char(stat) num2str(hdiffhps(:,idx,1))]
% disp('SHPS per 10 stat points for config #2')
% [char(stat) num2str(hdiffhps(:,idx,2))]

figure(52)
set(gcf,'Position',[290    92   706   414])
plot(xH,yH1)
xlim([min(player.phhit) max(player.phhit)])
legend(stat,'Location','EastOutside')
xlabel('Melee hit % against lvl 80')
ylabel('DPS per 10 itemization points')
title([cfg(1).label ', '  num2str(cfg(1).veng*100,'%2.1f') '% Veng, ' num2str(cfg(1).exp(1),'%2.1f') ' expertise'])

figure(53)
set(gcf,'Position',[290    92   706   414])
plot(xH,yH2)
xlim([min(xH) max(xH)])
legend(stat,'Location','EastOutside')
xlabel('Melee hit % against lvl 80')
ylabel('DPS per 10 itemization points')
title([cfg(2).label ', '  num2str(cfg(2).veng*100,'%2.1f') '% Veng, '  num2str(cfg(2).exp(1),'%2.1f') ' expertise'])
    
%% Exp graph
tic
for c=1:length(cfg)
    
    %reset extra structure
    extra_init;

    %set configuration variables
    egs(1)=cfg(c).helm;
    exec=execution_model('veng',cfg(c).veng,'seal',cfg(c).seal);
    glyph=cfg(c).glyph;
    talent=cfg(c).talent;
    queue.rot=cfg(c).queue;
    gear_stats;
    talents;
    stat_model;
    
    %store items in cfg for plots
    cfg(c).hit=player.phhit;
    
    %Set expertise to cover range 0 to 60
    extra.val.exp=(-player.exp+linspace(0,60,100)).*cnv.exp_exp;

    csswb=waitbar(0,'Calculating Exp Scaling');
    set(csswb,'Position',get(csswb,'Position')+[0 85 0 0]);
    for m=1:M
        waitbar(m./M,csswb,['Calculating Exp Scaling for ' stat{m} ...
                            ' in cfg ' int2str(c) '/' int2str(length(cfg))]);
        %set each stat to dstat extra
        eval(char(['extra.itm.' stat{m} '=dstat(m);']))

        stat_model;ability_model;rotation_model;
        tmprot.dps=rot(cfg(c).rot).totdps;
        tmprot.hps=rot(cfg(c).rot).tothps;
        dynamic_model;
        edps(m,:,c)=tmprot.dps+proc.dps;
        ehps(m,:,c)=tmprot.hps+proc.hps;
                
        %set each stat back to 0 extra
        eval(char(['extra.itm.' stat{m} '=0;']))

        stat_model;ability_model;rotation_model;
        tmprot.dps=rot(cfg(c).rot).totdps;
        tmprot.hps=rot(cfg(c).rot).tothps;
        dynamic_model;
        edps0(m,:,c)=tmprot.dps+proc.dps;
        ehps0(m,:,c)=tmprot.hps+proc.hps;

    end
    close(csswb)
end
toc
ediffdps=(edps-edps0).*10./repmat(dstat',[1 size(edps,2) size(edps,3)]);
ediffhps=(ehps-ehps0).*10./repmat(dstat',[1 size(ehps,2) size(ehps,3)]);
xE=player.exp';
yE1=squeeze(ediffdps(:,:,1))';
yE2=squeeze(ediffdps(:,:,2))';


figure(54)
set(gcf,'Position',[290    92   706   414])
plot(xE,yE1)
xlim([min(player.exp) max(player.exp)])
legend(stat,'Location','EastOutside')
xlabel('Expertise skill')
ylabel('DPS per 10 itemization points')
title([cfg(1).label ', '  num2str(cfg(1).veng*100,'%2.1f') '% Veng, ' num2str(cfg(1).hit(1),'%2.1f') '% hit'])


figure(55)
set(gcf,'Position',[290    92   706   414])
plot(xE,yE2)
xlim([min(xE) max(xE)])
legend(stat,'Location','EastOutside')
xlabel('Expertise skill')
ylabel('DPS per 10 itemization points')
title([cfg(2).label ', '  num2str(cfg(2).veng*100,'%2.1f') '% Veng, ' num2str(cfg(2).hit(1),'%2.1f') '% hit'])