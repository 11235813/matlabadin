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
cfg(1)=build_config('hit',2,'exp',5);

%low hit, WoG/SoI build
cfg(2)=build_config('hit',2,'exp',5,'seal','SoI');

%% Stat components
stat={'exp';'hit';'str';'haste';'ap';'sta';'crit';'agi';'sp';'int';'mas'};
M=length(stat);  %number of "extra" stats

%load itemization factors (i.e. because 10 STR = 20 AP = 15 STA = 11.6 SP)
stat_conversions

%This is the amount of itemization to add for each stat
dstat=30;

%this array is only for the table, so that we can generate per-point (ppt)
%entries to go with the per-itemization-point (pipt) entries
for m=1:M; icv(m,1)=eval(['ipconv.' stat{m}]); end;

%% Strength calcs
%reset extra structure
str_range=-100+linspace(1,1500,250);
[~, idx]=min(abs(str_range));
str_dps=zeros(M,length(str_range),length(cfg));str_hps=str_dps;
str_dps0=zeros(size(str_dps));str_hps0=str_dps0;
xStr=zeros(length(str_range),length(cfg));

tic
for g=1:length(cfg)
    %set configuration variables
    c=cfg(g);
    
    %construct extra fields
    c.extra=extra_init;
    c.extra.val.str=str_range;
    
    %calculate baseline DPS
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    %store baseline
    str_dps0(1:M,:,g)=repmat(c.rot.dps,[M 1 1]);
    str_hps0(1:M,:,g)=repmat(c.rot.hps,[M 1 1]);
    
    %waitbar
    csswb=waitbar(0,'Calculating STR Scaling');
    set(csswb,'Position',get(csswb,'Position')+[0 85 0 0]);
    
    %for each stat
    for m=1:M
        waitbar(m./M,csswb,['Calculating STR scaling for ' stat{m} ...
                            ' in cfg ' int2str(g) '/' int2str(length(cfg))]);
                        
        %set each stat to dstat extra
        eval(char(['c.extra.itm.' stat{m} '=dstat;']))

        %recalculate DPS
        c=stat_model(c);
        c=ability_model(c);
        c=rotation_model(c);
        
        str_dps(m,:,g)=c.rot.dps;
        str_hps(m,:,g)=c.rot.hps;
        
        %set each stat back to 0 extra
        eval(char(['c.extra.itm.' stat{m} '=0;']))

    end
    close(csswb)
    
    %store variables for plots
    xStr(:,g)=c.player.armorystr';
end
disp('Str calc finished')
toc
%% Strength Graphs / Table
yStr=(str_dps-str_dps0).*10./dstat; % parenthetical is for dstat increase, 10/dstat scales bonus for 10 ipoints
zStr=(str_hps-str_hps0).*10./dstat;

for g=1:length(cfg)
figure(50+g-1)
set(gcf,'Position',[290    92   706   414])
set(gcf,'DefaultAxesLineStyleOrder','-|--|:')
plot(xStr(:,g),yStr(:,:,g))
xlim([min(xStr(:,g)) max(xStr(:,g))])
legend(stat,'Location','EastOutside')
xlabel('Armory Strength')
ylabel('DPS per 10 itemization points')
title([ strrep(cfg(g).exec.queue,'^','\^') ', ' cfg(g).exec.seal ', '  ...
        num2str(cfg(g).exec.veng*100,'%2.1f') '% Veng, ' ...
        num2str(cfg(g).player.mehit,'%2.1f') '% hit, ' ...
        num2str(cfg(g).player.exp,'%2.1f') '% expertise'])


disp(['DPS and SHPS stat weights for ' cfg(g).exec.queue ', ' cfg(g).exec.seal])
ldat=2+(1:M);
li=DataTable();
li{ldat,1}=stat;
li{1:2,2}={'DPS';'ppt'};
li{ldat,2}=yStr(:,idx,g)./dstat./icv;
li{1:2,3}={'SHPS';'ppt'};
li{ldat,3}=zStr(:,idx,g)./dstat./icv;
li{1:2,4}={'DPS';'pipt'};
li{ldat,4}=yStr(:,idx,g)./dstat;
li{1:2,5}={'SHPS';'pipt'};
li{ldat,5}=zStr(:,idx,g)./dstat;

% li.setColumnTextAlignment(2,'left')
% li.setColumnTextAlignment(3:6,'center')
% li.setColumnFormat(2:4,'%6.0f')
li.setColumnFormat(2:5,'%1.3f')
li.toText()

end

%% Hit calcs
hit_range=(-c.player.mehit+linspace(0,12,100)).*cnv.hit_hit;
% [temp idx]=min(abs(hit_range));
hit_dps=zeros(M,length(hit_range),length(cfg));hit_hps=hit_dps;
hit_dps0=zeros(size(hit_dps));hit_hps0=hit_dps0;
xHit=zeros(length(hit_range),length(cfg));

tic
for g=1:length(cfg)
    %set configuration variables
    c=cfg(g);
    
    %construct extra fields
    c.extra=extra_init;
    c.extra.val.hit=hit_range;
    
    %calculate baseline DPS
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    %store baseline
    hit_dps0(1:M,:,g)=repmat(c.rot.dps,[M 1 1]);
    hit_hps0(1:M,:,g)=repmat(c.rot.hps,[M 1 1]);
    
    %waitbar
    csswb=waitbar(0,'Calculating hit Scaling');
    set(csswb,'Position',get(csswb,'Position')+[0 85 0 0]);
    
    %for each stat
    for m=1:M
        waitbar(m./M,csswb,['Calculating hit scaling for ' stat{m} ...
                            ' in cfg ' int2str(g) '/' int2str(length(cfg))]);
                        
        %set each stat to dstat extra
        eval(char(['c.extra.itm.' stat{m} '=dstat;']))

        %recalculate DPS
        c=stat_model(c);
        c=ability_model(c);
        c=rotation_model(c);
        
        hit_dps(m,:,g)=c.rot.dps;
        hit_hps(m,:,g)=c.rot.hps;
        
        %set each stat back to 0 extra
        eval(char(['c.extra.itm.' stat{m} '=0;']))

    end
    close(csswb)
    
    %store variables for plots
    xHit(:,g)=c.player.mehit';
end
disp('Hit calc finished')
toc
%% Hit Graphs
yHit=(hit_dps-hit_dps0).*10./dstat;
zHit=(hit_hps-hit_hps0).*10./dstat;

for g=1:length(cfg)
figure(60+g-1)
set(gcf,'Position',[290    92   706   414])
set(gcf,'DefaultAxesLineStyleOrder','-|--|:')
plot(xHit(:,g),yHit(:,:,g))
xlim([min(xHit(:,g)) max(xHit(:,g))])
legend(stat,'Location','EastOutside')
xlabel('Melee Hit %')
ylabel('DPS per 10 itemization points')
title([ strrep(cfg(g).exec.queue,'^','\^') ', ' cfg(g).exec.seal ', ' ...
        num2str(cfg(g).exec.veng*100,'%2.1f') '% Veng, ' ...
        num2str(cfg(g).player.exp,'%2.1f') '% expertise'])

end

    
%% Exp Calcs
exp_range=(-c.player.exp+linspace(0,16,100)).*cnv.exp_exp;
% [temp idx]=min(abs(exp_range));
exp_dps=zeros(M,length(exp_range),length(cfg));exp_hps=exp_dps;
exp_dps0=zeros(size(exp_dps));exp_hps0=exp_dps0;
xExp=zeros(length(exp_range),length(cfg));

tic
for g=1:length(cfg)
    %set configuration variables
    c=cfg(g);
    
    %construct extra fields
    c.extra=extra_init;
    c.extra.val.exp=exp_range;
    
    %calculate baseline DPS
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    %store baseline
    exp_dps0(1:M,:,g)=repmat(c.rot.dps,[M 1 1]);
    exp_hps0(1:M,:,g)=repmat(c.rot.hps,[M 1 1]);
    
    %waitbar
    csswb=waitbar(0,'Calculating exp Scaling');
    set(csswb,'Position',get(csswb,'Position')+[0 85 0 0]);
    
    %for each stat
    for m=1:M
        waitbar(m./M,csswb,['Calculating exp scaling for ' stat{m} ...
                            ' in cfg ' int2str(g) '/' int2str(length(cfg))]);
                        
        %set each stat to dstat extra
        eval(char(['c.extra.itm.' stat{m} '=dstat;']))

        %recalculate DPS
        c=stat_model(c);
        c=ability_model(c);
        c=rotation_model(c);
        
        exp_dps(m,:,g)=c.rot.dps;
        exp_hps(m,:,g)=c.rot.hps;
        
        %set each stat back to 0 extra
        eval(char(['c.extra.itm.' stat{m} '=0;']))

    end
    close(csswb)
    
    %store variables for plots
    xExp(:,g)=c.player.exp';
end
disp('Exp calc finished')
toc
%% Exp Graphs
yExp=(exp_dps-exp_dps0).*10./dstat;
zExp=(exp_hps-exp_hps0).*10./dstat;

for g=1:length(cfg)
figure(70+g-1)
set(gcf,'Position',[290    92   706   414])
set(gcf,'DefaultAxesLineStyleOrder','-|--|:')
plot(xExp(:,g),yExp(:,:,g))
xlim([min(xExp(:,g)) max(xExp(:,g))])
legend(stat,'Location','EastOutside')
xlabel('Expertise %')
ylabel('DPS per 10 itemization points')
title([ strrep(cfg(g).exec.queue,'^','\^') ', ' cfg(g).exec.seal ', '  ...
        num2str(cfg(g).exec.veng*100,'%2.1f') '% Veng, ' ...
        num2str(cfg(g).player.mehit,'%2.1f') '% hit'])

end
%% Haste Calcs
haste_range=linspace(0,15,100).*cnv.haste_sphaste;
% [temp idx]=min(abs(exp_range));
haste_dps=zeros(M,length(haste_range),length(cfg));haste_hps=haste_dps;
haste_dps0=zeros(size(haste_dps));haste_hps0=haste_dps0;
xHas=zeros(length(haste_range),length(cfg));

tic
for g=1:length(cfg)
    %set configuration variables
    c=cfg(g);
    
    %construct extra fields
    c.extra=extra_init;
    c.extra.val.haste=haste_range;
    
    %calculate baseline DPS
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    
    %store baseline
    haste_dps0(1:M,:,g)=repmat(c.rot.dps,[M 1 1]);
    haste_hps0(1:M,:,g)=repmat(c.rot.hps,[M 1 1]);
    
    %waitbar
    csswb=waitbar(0,'Calculating haste Scaling');
    set(csswb,'Position',get(csswb,'Position')+[0 85 0 0]);
    
    %for each stat
    for m=1:M
        waitbar(m./M,csswb,['Calculating haste scaling for ' stat{m} ...
                            ' in cfg ' int2str(g) '/' int2str(length(cfg))]);
                        
        %set each stat to dstat extra
        eval(char(['c.extra.itm.' stat{m} '=dstat;']))

        %recalculate DPS
        c=stat_model(c);
        c=ability_model(c);
        c=rotation_model(c);
        
        haste_dps(m,:,g)=c.rot.dps;
        haste_hps(m,:,g)=c.rot.hps;
        
        %set each stat back to 0 extra
        eval(char(['c.extra.itm.' stat{m} '=0;']))

    end
    close(csswb)
    
    %store variables for plots
    xHas(:,g)=c.player.sphaste';
end
disp('Haste calc finished')
toc
%% Haste Graphs
yHas=(haste_dps-haste_dps0).*10./dstat;
zHas=(haste_hps-haste_hps0).*10./dstat;

for g=1:length(cfg)
figure(80+g-1)
set(gcf,'Position',[290    92   706   414])
set(gcf,'DefaultAxesLineStyleOrder','-|--|:')
plot(xHas(:,g),yHas(:,:,g))
xlim([min(xHas(:,g)) max(xHas(:,g))])
legend(stat,'Location','EastOutside')
xlabel('Spell Haste %')
ylabel('DPS per 10 itemization points')
title([ strrep(cfg(g).exec.queue,'^','\^') ', ' cfg(g).exec.seal ', '  ...
        num2str(cfg(g).exec.veng*100,'%2.1f') '% Veng, ' ...
        num2str(cfg(g).player.mehit,'%2.1f') '% hit'])

end