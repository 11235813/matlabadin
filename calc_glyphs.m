%%CALC_GLYPHS calculates DPS output in a variety of different glyph
%%configurations to determine DPS per glyph

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

%low hit, WoG/SoI build
cfg(2)=build_config('hit',2,'exp',5,'glyph',[0 0 0],'queue','^WB>CS>J>AS>^SS>Cons>HW>WoG');

%hit-cap and exp soft-cap
cfg(3)=build_config('hit',7.5,'exp',7.5,'glyph',[0 0 0]);

%multiple targets
cfg(4)=build_config('hit',2,'exp',5,'glyph',[0 0 0],'npccount',3); 


%% sim 
qmax=length(fieldnames(cfg(1).glyph))-3;
% tabledps=zeros(length(gtree),length(rot),2);

for g=1:length(cfg)
    %set configuration variables
    
    c=cfg(g);
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    dps0(1:qmax,g)=c.rot.dps;
    hps0(1:qmax,g)=c.rot.hps;
    
    wb=waitbar(0,['Calculating CFG # ' int2str(g) ' / ' int2str(length(cfg))]);
    tic
    for q=1:qmax

        c.glyph=glyph_model([q 0 0]);
        c=stat_model(c);
        c=ability_model(c);
        c=rotation_model(c);
                    
        %store DPS & HPS
        dps(q,g)=c.rot.dps;
        hps(q,g)=c.rot.hps;
                
        waitbar(q/qmax,wb)
        
    end
    close(wb)
    toc
end


glyphdps=dps-dps0;
glyphhps=hps-hps0;


%% construct output arrays
ldat=3+[1:qmax]; %offset by header rows

li=DataTable();
li{1:3,1}={' ';'Glyph';'Base DPS (k)'};      
li{ldat,1}=c.glyph.labels;

for g=1:length(cfg)
    
li{1:3,2*g}={['cfg' int2str(g)];'DPS';num2str(roundn(dps0(1,g)./1e3,-1),'%2.1f')};
li{ldat,2*g}=round(glyphdps(:,g));

li{1:3,2*g+1}={['cfg' int2str(g)];'HPS';num2str(roundn(hps0(1,g)./1e3,-1),'%2.1f')};
li{ldat,2*g+1}=round(glyphhps(:,g));

end

% li.setColumnTextAlignment(2,'left')
% li.setColumnTextAlignment(3:6,'center')
% li.setColumnFormat(3:4,'%6.0f')
% li.setColumnFormat(5:6,'%2.1f')
li.toText()

%% plots
% 
% dpspg_temp=dpspg;
% 
% 
% %sorted
% si=2; %939
% [temp indd]=sort(dpspg_temp(:,si));
% icols=[1 2 3 4];
% dpspgplot=dpspg_temp(indd,icols);
%     
% N=size(dpspgplot,1);
% 
% figure(41)
% bar41=barh(dpspgplot(2:N,:),'BarWidth',1,'BarLayout','grouped');
% set(bar41(2),'FaceColor',[0.749 0.749 0]);
% set(bar41(3),'FaceColor',[0.5 0 0]);
% set(bar41(4),'FaceColor',[0.45 0.75 0.3]);
% ylim([length(find(sum(dpspgplot,2)==0)) N]-0.5)
% set(gca,'YTickLabel',name(indd(2:N)))
% legend({cfg(icols).plabel},'Location','Best')
% xlabel('DPS')
% title('100% Veng, legend contains rotation/seal/hit/exp')
