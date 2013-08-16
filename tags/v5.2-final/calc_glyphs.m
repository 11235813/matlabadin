%%CALC_GLYPHS calculates DPS output in a variety of different glyph
%%configurations to determine DPS per glyph

%% Setup Tasks
clear;
disp('------------- CALC_GLYPHS -------------')
%load gear database
gear_db;
%load defaults database
def_db;

%% Configurations
%create the first configuation
%set melee hit to 7.5%, expertise to 15%
cfg(1)=build_config('hit',7.5,'exp',15,'glyph',[0 0 0]); 

%WoG queue for GoWoG & HW
cfg(2)=build_config('hit',7.5,'exp',15,'glyph',[0 0 0],'queue','^WB>CS>J>AS>HW>Cons>WoG');

%special queue to emphasize HW during execute
cfg(3)=build_config('hit',7.5,'exp',15,'glyph',[0 0 0],'queue','HW>HoW>AS>CS>J>Cons>SotR');

%multiple targets SoR
cfg(4)=build_config('hit',7.5,'exp',15,'glyph',[0 0 0],'npccount',3,'seal','SoR','queue','HotR>J>AS>HW>Cons>SotR'); 

%multiple targets SoI
cfg(5)=build_config('hit',7.5,'exp',15,'glyph',[0 0 0],'npccount',3,'seal','SoI','queue','HotR>J>AS>HW>Cons>SotR'); 

%SoT for Immediate Truth
cfg(6)=build_config('hit',7.5,'exp',15,'glyph',[0 0 0],'seal','SoT'); 

%% Vengeance levels
for v=[ddb.v1,ddb.v2]


%% sim 
qmax=length(fieldnames(cfg(1).glyph))-3;
% tabledps=zeros(length(gtree),length(rot),2);

for g=1:length(cfg)
    %set configuration variables
    
    c=cfg(g);
    c.exec.veng=v;
    c=stat_model(c);
    c=ability_model(c);
    c=rotation_model(c);
    dps0(1:qmax,g)=c.rot.dps+c.rot.aoe;
    hps0(1:qmax,g)=c.rot.hps;
    
    wb=waitbar(0,['Calculating CFG # ' int2str(g) ' / ' int2str(length(cfg))]);
    tic
    for q=1:qmax

        c.glyph=glyph_model([q 0 0]);
        c.exec.veng=v;
        c=stat_model(c);
        c=ability_model(c);
        c=rotation_model(c);
                    
        %store DPS & HPS
        dps(q,g)=c.rot.dps+c.rot.aoe;
        hps(q,g)=c.rot.hps;
                
        waitbar(q/qmax,wb)
        
    end
    close(wb)
%     toc
end


glyphdps=dps-dps0;
glyphhps=hps-hps0;


%% construct output arrays
%logical array to eliminate zero rows
outputIDs=sum(abs(glyphdps)+abs(glyphhps),2)~=0;
ldat=3+[1:sum(outputIDs)]; %offset by header rows

li=DataTable();
li{1:3,1}={' ';'Glyph';'Base DPS (k)'};      
li{ldat,1}=c.glyph.labels(outputIDs);

for g=1:length(cfg)
    
li{1:3,2*g}={['cfg' int2str(g)];'DPS';num2str(roundn(dps0(1,g)./1e3,-1),'%2.1f')};
li{ldat,2*g}=round(glyphdps(outputIDs,g));

li{1:3,2*g+1}={['cfg' int2str(g)];'HPS';num2str(roundn(hps0(1,g)./1e3,-1),'%2.1f')};
li{ldat,2*g+1}=round(glyphhps(outputIDs,g));

end

% li.setColumnTextAlignment(2,'left')
% li.setColumnTextAlignment(3:6,'center')
% li.setColumnFormat(3:4,'%6.0f')
% li.setColumnFormat(5:6,'%2.1f')
disp(' ');disp(' ');
disp(['---' int2str(round(c.player.VengAP./1000)) 'k Vengeance ---[code]'])
li.toText()
disp('[/code]')

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

%% close Veng loop
end