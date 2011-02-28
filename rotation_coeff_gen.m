%ROTATION_COEFF_GEN generates coefficient weight factors for
%rotation_model.  It does so as a function of mdf.mehit for every possible
%combination of talents that significantly changes the spell cast order or
%is not sufficiently covered by [AM]


%There are a limited number of effects that do this:
%mdf.mehit (automatically handled in [RCD] and [RCF]
%Grand Crusader
%Sacred Duty (sort of?)
%Eternal Glory (unless changed)

%% Setup Tasks
clear;
gear_db;
def_db;

exec=execution_model('veng',1);  %placeholder, set in cfg
base=player_model('race','Human');
npc=npc_model(base);
egs=ddb.gearset{2};  %1=pre-raid , 2=raid
gear_stats;
talent=ddb.talentset{1}; %placeholder, all relevant talents set in sim
glyph=ddb.glyphset{4}; %placeholder, glyphs irrelevant
talents;
buff=buff_model;
stat_model;
ability_model;



%% Sim
for gc=1:3
    for sd=1:3
        for eg=1:3
            
            %set talent environment
            talent.prot(4,3)=gc-1;
            talent.prot(6,2)=sd-1;
            talent.prot(1,3)=eg-1;
            talents;
            
            %recalculate stats
            stat_model;
            
            %generate data
            rotation_coeff_data
            
            %store data for later scrutiny
            rcgd.h=h;
            rcgd.allcoeffs(:,:,:,gc,sd,eg)=rcgd.coeff;
            
            %fit data
            rcgd.showplots=0; %plot flag, set to 1 to show plots
            rotation_coeff_fit
            
            %initialize mdf.pvals if not already created
            if ~isfield(rcgd,'allpvals')
                rcgd.allpvals=zeros(length(priolist),size(rcgd.pvals,2),3,3,3);
            end
            
            %store generated polynomial coefficients
            rcgd.allpvals(:,:,gc,sd,eg)=rcgd.pvals;
            
            %debugging
            pause(0.1)
            close all

        end
    end
end
clear gc sd eg

%generate matlab-readable code for copy/pasting into rotation_model
rcgd.print.ids=find(rcgd.allpvals);
rcgd.print.vals=rcgd.allpvals(rcgd.print.ids);
rcgd.comm{1}=['clear rotdb;rotdb.tempvals=zeros(' int2str(length(rcgd.allpvals(:))) ',1);'];
rcgd.comm{2}=['rotdb.ids=[' int2str(rcgd.print.ids') '];'];
rcgd.comm{3}=['rotdb.vals=[' num2str(rcgd.print.vals') '];'];
rcgd.comm{4}=['rotdb.tempvals(rotdb.ids)=rotdb.vals;'];
rcgd.comm{5}=['rotdb.pvals=reshape(rotdb.tempvals,' int2str(length(priolist)) ',' int2str(size(rcgd.pvals,2)) ',3,3,3);'];
rcgd.command=char({'%% Copy/Paste this code into rotation_model',rcgd.comm{1},rcgd.comm{2},rcgd.comm{3},rcgd.comm{4},rcgd.comm{5}});
rcgd.command
save zzRCD_data rcgd


%debugging
%Check AS plot to see what effect GrCr has
figure(1);
H=repmat(h,1,size(rcgd.allcoeffs,3));
plot(H,squeeze(rcgd.allcoeffs(7,:,:,1,3,3)),'b.-',H,squeeze(rcgd.allcoeffs(7,:,:,3,3,3)),'r.-')

%See what effect SD has
figure(2)
plot(H,squeeze(rcgd.allcoeffs(3,:,:,3,1,3)),'b.-',H,squeeze(rcgd.allcoeffs(3,:,:,3,3,3)),'r.-')

%EG, won't work until support for mulitple queues is added
figure(3)
plot(H,squeeze(rcgd.allcoeffs(4,:,:,3,3,1)),'b.-',H,squeeze(rcgd.allcoeffs(4,:,:,3,3,3)),'r.-')
