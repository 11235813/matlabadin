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
% clear;
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

%% Queue number
QQ=[1 8 23 2 9 32];

for iq=1:length(QQ);
    Q=QQ(iq);
%% Sim
clear rcgd
Ngc=[1 2 3];    %grand crusader 
Nsd=[1 2 3];      %sacred duty
Neg=[1 2 3];        %eternal glory
Ntot=length(Neg)*length(Nsd)*length(Ngc);
t1=clock;
uwb=waitbar(0,['Calculating config #1/' int2str(Ntot)]);tic;
set(uwb,'Position',get(uwb,'Position')+[1600 80 0 0])
for igc=1:length(Ngc)
    for isd=1:length(Nsd)
        for ieg=1:length(Neg)
            
            %define indices
            gc=Ngc(igc);
            sd=Nsd(isd);
            eg=Neg(ieg);
            
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
            if length(size(rcgd.coeff))>2
                rcgd.allcoeffs(:,:,:,gc,sd,eg)=rcgd.coeff;
                rcgd.allcps(:,:,:,gc,sd,eg)=rcgd.cps;
            else
                rcgd.allcoeffs(:,:,1,gc,sd,eg)=rcgd.coeff;
                rcgd.allcps(:,:,1,gc,sd,eg)=rcgd.cps;
            end
            
            %fit data
            rcgd.showplots=0; %plot flag, set to 1 to show plots
            rotation_coeff_fit
            
            %initialize if not already created
            if ~isfield(rcgd,'allpvals')
                rcgd.allcoeffpvals=zeros(length(priolist),size(rcgd.coeffpvals,2),3,3,3);
                rcgd.allcpspvals=zeros(length(priolist),size(rcgd.cpspvals,2),3,3,3);
            end
            
            %store generated polynomial coefficients
            rcgd.allcoeffpvals(:,:,gc,sd,eg)=rcgd.coeffpvals;
            rcgd.allcpspvals(:,:,gc,sd,eg)=rcgd.cpspvals;
            
            %debugging
            pause(0.1)
            close all
            
            %waitbar updating
            currind=((igc-1)*length(Neg)*length(Nsd)+(isd-1)*length(Neg)+ieg);
            waitbar(currind/(Ntot),uwb, ...
                ['Calculating #' int2str(currind) '/' int2str(Ntot) ', est=' num2str((Ntot-currind)*(etime(clock,t1)./currind),'%3.1f') 'sec']);

        end
    end
end
clear gc sd eg
close(uwb)

%generate matlab-readable code for copy/pasting into rotation_model
rcgd.print.coeffids=find(rcgd.allcoeffpvals);
rcgd.print.coeffvals=rcgd.allcoeffpvals(rcgd.print.coeffids);
rcgd.print.cpsids=find(rcgd.allcpspvals);
rcgd.print.cpsvals=rcgd.allcpspvals(rcgd.print.cpsids);
rcgd.comm{1}=['rotdb(i).tempvals=zeros(' int2str(length(rcgd.allcoeffpvals(:))) ',1);'];
rcgd.comm{2}=['rotdb(i).coeffids=[' int2str(rcgd.print.coeffids') '];'];
rcgd.comm{3}=['rotdb(i).coeffvals=[' num2str(rcgd.print.coeffvals') '];'];
rcgd.comm{4}=['rotdb(i).tempvals(rotdb(i).coeffids)=rotdb(i).coeffvals;'];
rcgd.comm{5}=['rotdb(i).tempvals=zeros(' int2str(length(rcgd.allcoeffpvals(:))) ',1);'];
rcgd.comm{6}=['rotdb(i).cpsids=[' int2str(rcgd.print.cpsids') '];'];
rcgd.comm{7}=['rotdb(i).cpsvals=[' num2str(rcgd.print.cpsvals') '];'];
rcgd.comm{8}=['rotdb(i).tempvals(rotdb(i).cpsids)=rotdb(i).cpsvals;'];
rcgd.comm{9}=['rotdb(i).cpspvals=reshape(rotdb(i).tempvals,' int2str(length(priolist)) ',' int2str(size(rcgd.coeffpvals,2)) ',3,3,3);'];
rcgd.command=char({'%% Copy/Paste this code into rotation_model','clear rotdb',rcgd.comm{1},rcgd.comm{2},rcgd.comm{3},rcgd.comm{4},rcgd.comm{5},rcgd.comm{6},rcgd.comm{7},rcgd.comm{8},rcgd.comm{9}});
rcgd.command
save zzRCD_data rcgd


%debugging
%Check AS plot to see what effect GrCr has
figure(1+3*iq);
H=repmat(h,1,size(rcgd.allcoeffs,3));
f=fittype('poly5');
tempfit=rcgd.allpvals(7,:,1,3,3);
c11=cfit(f,tempfit(1),tempfit(2),tempfit(3),tempfit(4),tempfit(5),tempfit(6));
tempfit=rcgd.allpvals(7,:,3,3,3);
c12=cfit(f,tempfit(1),tempfit(2),tempfit(3),tempfit(4),tempfit(5),tempfit(6));
plot(H,squeeze(rcgd.allcoeffs(7,:,:,1,3,3)),'b.-',H,squeeze(rcgd.allcoeffs(7,:,:,3,3,3)),'r.-',h,c11(h),'ko-',h,c12(h),'ko-')

%See what effect SD has
figure(2+3*iq)
tempfit=rcgd.allpvals(3,:,3,1,3);
c21=cfit(f,tempfit(1),tempfit(2),tempfit(3),tempfit(4),tempfit(5),tempfit(6));
tempfit=rcgd.allpvals(3,:,3,3,3);
c22=cfit(f,tempfit(1),tempfit(2),tempfit(3),tempfit(4),tempfit(5),tempfit(6));
plot(H,squeeze(rcgd.allcoeffs(3,:,:,3,1,3)),'b.-',H,squeeze(rcgd.allcoeffs(3,:,:,3,3,3)),'r.-',h,c21(h),'k-',h,c22(h),'ko-')

%EG, won't work until support for mulitple queues is added
figure(3+3*iq)
tempfit=rcgd.allpvals(4,:,3,3,1);f=fittype('poly5');c3b=cfit(f,tempfit(1),tempfit(2),tempfit(3),tempfit(4),tempfit(5),tempfit(6));
plot(H,squeeze(rcgd.allcoeffs(4,:,:,3,3,1)),'b.-',H,squeeze(rcgd.allcoeffs(4,:,:,3,3,3)),'r.-',h,c3b(h),'k-')

end