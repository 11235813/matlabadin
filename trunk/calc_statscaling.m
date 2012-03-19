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
for m=1:M; icv(m,1)=eval(['ipconv.' stat{m}]); end;

%% Strength calcs
%reset extra structure
str_range=-100+linspace(1,1500,250);
[~, idx]=min(abs(str_range));
sdps=zeros(M,length(str_range),length(cfg));shps=sdps;
sdps0=zeros(size(sdps));shps0=sdps0;

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
    sdps0(1:M,:,g)=repmat(c.rot.dps,[M 1 1]);
    shps0(1:M,:,g)=repmat(c.rot.hps,[M 1 1]);
    
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
        
        sdps(m,:,g)=c.rot.dps;
        shps(m,:,g)=c.rot.hps;
        
        %set each stat back to 0 extra
        eval(char(['c.extra.itm.' stat{m} '=0;']))

    end
    close(csswb)
    
    %store variables for plots
    xS(:,g)=c.player.armorystr';
end
toc
%% Strength Graphs / Table
yS=(sdps-sdps0);
ySh=(shps-shps0);

for g=1:length(cfg)
figure(50+g-1)
set(gcf,'Position',[290    92   706   414])
plot(xS(:,g),yS(:,:,g))
xlim([min(xS(:,g)) max(xS(:,g))])
legend(stat,'Location','EastOutside')
xlabel('Armory Strength')
ylabel('DPS per 10 itemization points')
title([cfg(g).exec.queue ', ' cfg(g).exec.seal ', '  num2str(cfg(g).exec.veng*100,'%2.1f') '% Veng, ' num2str(cfg(g).player.mehit,'%2.1f') '% hit, ' num2str(cfg(g).player.exp,'%2.1f') '% expertise'])


disp(['DPS and SHPS stat weights for ' cfg(g).exec.queue ', ' cfg(g).exec.seal])
ldat=2+(1:M);
li=DataTable();
li{ldat,1}=stat;
li{1:2,2}={'DPS';'ppt'};
li{ldat,2}=yS(:,idx,g)./dstat./icv;
li{1:2,3}={'SHPS';'ppt'};
li{ldat,3}=ySh(:,idx,g)./dstat./icv;
li{1:2,4}={'DPS';'pipt'};
li{ldat,4}=yS(:,idx,g)./dstat;
li{1:2,5}={'SHPS';'pipt'};
li{ldat,5}=ySh(:,idx,g)./dstat;

% li.setColumnTextAlignment(2,'left')
% li.setColumnTextAlignment(3:6,'center')
% li.setColumnFormat(2:4,'%6.0f')
li.setColumnFormat(2:5,'%1.3f')
li.toText()

end

%% Hit calcs
hit_range=(-c.player.mehit+linspace(0,12,100)).*cnv.hit_hit;
% [temp idx]=min(abs(hit_range));
hdps=zeros(M,length(hit_range),length(cfg));hhps=hdps;
hdps0=zeros(size(hdps));hhps0=hdps0;

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
    hdps0(1:M,:,g)=repmat(c.rot.dps,[M 1 1]);
    hhps0(1:M,:,g)=repmat(c.rot.hps,[M 1 1]);
    
    %waitbar
    csswb=waitbar(0,'Calculating STR Scaling');
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
        
        hdps(m,:,g)=c.rot.dps;
        hhps(m,:,g)=c.rot.hps;
        
        %set each stat back to 0 extra
        eval(char(['c.extra.itm.' stat{m} '=0;']))

    end
    close(csswb)
    
    %store variables for plots
    xH(:,g)=c.player.mehit';
end
toc
%% Hit Graphs
yH=(hdps-hdps0);
yHh=(hhps-hhps0);

for g=1:length(cfg)
figure(60+g-1)
set(gcf,'Position',[290    92   706   414])
plot(xH(:,g),yH(:,:,g))
xlim([min(xH(:,g)) max(xH(:,g))])
legend(stat,'Location','EastOutside')
xlabel('Melee Hit %')
ylabel('DPS per 10 itemization points')
title([cfg(g).exec.queue ', ' cfg(g).exec.seal ', '  num2str(cfg(g).exec.veng*100,'%2.1f') '% Veng, ' num2str(cfg(g).player.mehit,'%2.1f') '% hit, ' num2str(cfg(g).player.exp,'%2.1f') '% expertise'])

end

    
%% Exp Calcs
exp_range=(-c.player.exp+linspace(0,15,100)).*cnv.exp_exp;
% [temp idx]=min(abs(exp_range));
edps=zeros(M,length(exp_range),length(cfg));ehps=edps;
edps0=zeros(size(hdps));ehps0=edps0;

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
    edps0(1:M,:,g)=repmat(c.rot.dps,[M 1 1]);
    ehps0(1:M,:,g)=repmat(c.rot.hps,[M 1 1]);
    
    %waitbar
    csswb=waitbar(0,'Calculating STR Scaling');
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
        
        edps(m,:,g)=c.rot.dps;
        ehps(m,:,g)=c.rot.hps;
        
        %set each stat back to 0 extra
        eval(char(['c.extra.itm.' stat{m} '=0;']))

    end
    close(csswb)
    
    %store variables for plots
    xE(:,g)=c.player.exp';
end
toc
%% Exp Graphs
yE=(edps-edps0);
yEh=(ehps-ehps0);

for g=1:length(cfg)
figure(70+g-1)
set(gcf,'Position',[290    92   706   414])
plot(xE(:,g),yE(:,:,g))
xlim([min(xE(:,g)) max(xE(:,g))])
legend(stat,'Location','EastOutside')
xlabel('Expertise %')
ylabel('DPS per 10 itemization points')
title([cfg(g).exec.queue ', ' cfg(g).exec.seal ', '  num2str(cfg(g).exec.veng*100,'%2.1f') '% Veng, ' num2str(cfg(g).player.mehit,'%2.1f') '% hit, ' num2str(cfg(g).player.exp,'%2.1f') '% expertise'])

end
