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

%% Queue number
QQ=[1 6 21 2 7 30 17];
% QQ=[17];  %for testing

%waitbar stuff
mon=1600; %set to 1600 if using dual-monitor setup, 0 otherwise
uuwb=waitbar(0,['Calculating queue #1/' int2str(length(QQ))]);tq=clock;
set(uuwb,'Position',get(uuwb,'Position')+[mon 160 0 0])
for iq=1:length(QQ);
    Q=QQ(iq);
    %% Sim
    clear rdbgen
    Ngc=[1 2 3];    %grand crusader
    Nsd=[1 2 3];      %sacred duty
    Neg=[1 2 3];        %eternal glory
    Ntot=length(Neg)*length(Nsd)*length(Ngc);
    tc=clock;
    uwb=waitbar(0,['Calculating config #1/' int2str(Ntot)]);tic;
    set(uwb,'Position',get(uwb,'Position')+[mon 80 0 0])
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
                rotation_db_data

                %initialize if not already created
                if ~exist('rdbgen','var') || ~isfield(rdbgen,'allpvals')
                    rdbgen.coeff=zeros([size(rdbdata.coeff) 3 3 3]);
                    rdbgen.cps=zeros([size(rdbdata.cps) 3 3 3]);
                end

                %store data for later scrutiny
                rdbgen.h=h;
                if length(size(rdbdata.coeff))>2
                    rdbgen.coeff(:,:,:,gc,sd,eg)=rdbdata.coeff;
                    rdbgen.cps(:,:,:,gc,sd,eg)=rdbdata.cps;
                    rdbgen.inqup(1,:,:,gc,sd,eg)=rdbdata.inqup;
                else
                    rdbgen.coeff(:,:,1,gc,sd,eg)=rdbdata.coeff;
                    rdbgen.cps(:,:,1,gc,sd,eg)=rdbdata.cps;
                    rdbgen.inqup(1,:,1,gc,sd,eg)=rdbdata.inqup;
                end

                %fit data
                rdbgen.showplots=0; %plot flag, set to 1 to show plots
                rotation_db_fit

                %initialize if not already created
                if ~isfield(rdbgen,'coeffpvals') || ~isfield(rdbgen,'cpspvals') || ~isfield(rdbgen,'inqpvals')
                    rdbgen.coeffpvals=zeros([size(rdbfit.coeffpvals) 3 3 3]);
                    rdbgen.cpspvals=zeros([size(rdbfit.cpspvals) 3 3 3]);
                    rdbgen.inqpvals=zeros([size(rdbfit.inqpvals) 3 3 3]);
                end

                %store generated polynomial coefficients
                rdbgen.coeffpvals(:,:,gc,sd,eg)=rdbfit.coeffpvals;
                rdbgen.cpspvals(:,:,gc,sd,eg)=rdbfit.cpspvals;
                rdbgen.inqpvals(:,:,gc,sd,eg)=rdbfit.inqpvals;  

                %debugging
                pause(0.1)
                close all

                %waitbar updating
                currind=((igc-1)*length(Neg)*length(Nsd)+(isd-1)*length(Neg)+ieg);
                waitbar(currind/(Ntot),uwb, ...
                    ['Calculating #' int2str(currind) '/' int2str(Ntot) ', est=' num2str((Ntot-currind)*(etime(clock,tc)./currind),'%3.1f') 'sec']);

            end
        end
    end
    clear gc sd eg
    close(uwb)

    %generate matlab-readable code for copy/pasting into rotation_model
    rdbgen.print.coeffids=find(rdbgen.coeffpvals);
    rdbgen.print.coeffvals=rdbgen.coeffpvals(rdbgen.print.coeffids);
    rdbgen.print.cpsids=find(rdbgen.cpspvals);
    rdbgen.print.cpsvals=rdbgen.cpspvals(rdbgen.print.cpsids);
    rdbgen.print.inqids=find(rdbgen.inqpvals);
    rdbgen.print.inqvals=rdbgen.inqpvals(rdbgen.print.inqids);
    
    %generate text output
    rdbgen.comm{1}=['rotdb(i).tempvals=zeros(' int2str(length(rdbgen.coeffpvals(:))) ',1);'];
    rdbgen.comm{2}=['rotdb(i).coeffids=[' int2str(rdbgen.print.coeffids') '];'];
    rdbgen.comm{3}=['rotdb(i).coeffvals=[' num2str(rdbgen.print.coeffvals') '];'];
    rdbgen.comm{4}=['rotdb(i).tempvals(rotdb(i).coeffids)=rotdb(i).coeffvals;'];
    rdbgen.comm{5}=['rotdb(i).coeffpvals=reshape(rotdb(i).tempvals,' int2str(length(priolist)) ',' int2str(size(rdbgen.coeffpvals,2)) ',3,3,3);'];
    rdbgen.comm{6}=['rotdb(i).tempvals=zeros(' int2str(length(rdbgen.coeffpvals(:))) ',1);'];
    rdbgen.comm{7}=['rotdb(i).cpsids=[' int2str(rdbgen.print.cpsids') '];'];
    rdbgen.comm{8}=['rotdb(i).cpsvals=[' num2str(rdbgen.print.cpsvals') '];'];
    rdbgen.comm{9}=['rotdb(i).tempvals(rotdb(i).cpsids)=rotdb(i).cpsvals;'];
    rdbgen.comm{10}=['rotdb(i).cpspvals=reshape(rotdb(i).tempvals,' int2str(length(priolist)) ',' int2str(size(rdbgen.coeffpvals,2)) ',3,3,3);'];
    rdbgen.comm{11}=['rotdb(i).tempvals=zeros(' int2str(length(rdbgen.inqpvals(:))) ',1);'];
    rdbgen.comm{12}=['rotdb(i).inqids=[' int2str(rdbgen.print.inqids') '];'];
    rdbgen.comm{13}=['rotdb(i).inqvals=[' num2str(rdbgen.print.inqvals') '];'];
    rdbgen.comm{14}=['rotdb(i).tempvals(rotdb(i).inqids)=rotdb(i).inqvals;'];
    rdbgen.comm{15}=['rotdb(i).inqpvals=reshape(rotdb(i).tempvals,1,' int2str(size(rdbgen.inqpvals,2)) ',3,3,3);'];
    rdbgen.command=char({['%% ' prio(QQ(iq)).name],['i=' int2str(iq) ';'],strvcat(rdbgen.comm),' ',' '});
%     rdbgen.command

    rdbg(iq)=rdbgen; %for storing cumulative data
    
    
    %waitbar updating
    waitbar(iq/length(QQ),uuwb, ...
        ['Calculating #' int2str(currind) '/' int2str(Ntot) ', est=' num2str((length(QQ)-iq)*(etime(clock,tq)./iq),'%3.1f') 'sec']);

end
close(uuwb)

%write the results to a text file for easy copy/pasting into rotation_db
ftext=char({rdbg.command});
fid=fopen('rotation_db_gen.txt','w');
fprintf(fid,'%s \n', ['%Coeffs generated ' date ', N=' int2str(N) ', M=' int2str(M)]);
for i=1:size(ftext,1)
    fprintf(fid,'%s \n',ftext(i,:));
end
fclose(fid);

%save the rdbg structure for debugging purposes
save zzRCD_data rdbg


%% Debugging
%Figures for debugging

%check an arbitrary coeff & cps & inq fit
a=3; 
figure(1)
tmp.gc=3;
tmp.sd=3;
tmp.eg=3;
H=repmat(h,1,size(rdbgen.coeff,3));
f=fittype('poly5');
tempfit=rdbgen.coeffpvals(a,:,tmp.gc,tmp.sd,tmp.eg);
c1=cfit(f,tempfit(1),tempfit(2),tempfit(3),tempfit(4),tempfit(5),tempfit(6));
tempfit=rdbgen.cpspvals(a,:,tmp.gc,tmp.sd,tmp.eg);
c2=cfit(f,tempfit(1),tempfit(2),tempfit(3),tempfit(4),tempfit(5),tempfit(6));
tempfit=rdbgen.inqpvals(1,:,tmp.gc,tmp.sd,tmp.eg);
c3=cfit(f,tempfit(1),tempfit(2),tempfit(3),tempfit(4),tempfit(5),tempfit(6));
plot(H,squeeze(rdbgen.coeff(a,:,:,tmp.gc,tmp.sd,tmp.eg)),'b.-', ...
     H,squeeze(rdbgen.cps(a,:,:,tmp.gc,tmp.sd,tmp.eg)),'r.-', ...
     H,squeeze(rdbgen.inqup(1,:,:,tmp.gc,tmp.sd,tmp.eg)),'m.-',...
     h,c1(h),'ko-',h,c2(h),'ko-',h,c3(h),'ko-')

% %Check AS plot to see what effect GrCr has
% a=7; %as
% figure(10);
% H=repmat(h,1,size(rdbgen.allcoeff,3));
% f=fittype('poly5');
% tempfit=rdbgen.allcoeffpvals(a,:,1,3,3);
% c11=cfit(f,tempfit(1),tempfit(2),tempfit(3),tempfit(4),tempfit(5),tempfit(6));
% tempfit=rdbgen.allcoeffpvals(a,:,3,3,3);
% c12=cfit(f,tempfit(1),tempfit(2),tempfit(3),tempfit(4),tempfit(5),tempfit(6));
% plot(H,squeeze(rdbgen.allcoeff(a,:,:,1,3,3)),'b.-',H,squeeze(rdbgen.allcoeff(a,:,:,3,3,3)),'r.-',h,c11(h),'ko-',h,c12(h),'ko-')
% 
% %See what effect SD has
% a=3; %sotr
% figure(11)
% tempfit=rdbgen.allcoeffpvals(a,:,3,1,3);
% c21=cfit(f,tempfit(1),tempfit(2),tempfit(3),tempfit(4),tempfit(5),tempfit(6));
% tempfit=rdbgen.allcoeffpvals(a,:,3,3,3);
% c22=cfit(f,tempfit(1),tempfit(2),tempfit(3),tempfit(4),tempfit(5),tempfit(6));
% plot(H,squeeze(rdbgen.allcoeff(a,:,:,3,1,3)),'b.-',H,squeeze(rdbgen.allcoeff(a,:,:,3,3,3)),'r.-',h,c21(h),'k-',h,c22(h),'ko-')
% 
% %See what effect EG has
% a=4; %wog
% figure(12)
% tempfit=rdbgen.allcoeffpvals(a,:,3,3,1);f=fittype('poly5');c3b=cfit(f,tempfit(1),tempfit(2),tempfit(3),tempfit(4),tempfit(5),tempfit(6));
% plot(H,squeeze(rdbgen.allcoeff(a,:,:,3,3,1)),'b.-',H,squeeze(rdbgen.allcoeff(a,:,:,3,3,3)),'r.-',h,c3b(h),'k-')
% pause(0.001)