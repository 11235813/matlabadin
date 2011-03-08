%ROTATION_COEFF_DATA generates a data set of prio_sim ability weight
%coefficients as a function of melee hit for the current variable
%environment.

h=[0.7:0.02:1]';
N=2500;
dt=1.5;
M=10;
%initialize for speed
rdbdata.coeff=zeros(13,length(h),M);
rdbdata.cps=zeros(13,length(h),M);
rdbdata.inqup=zeros(1,length(h),M);
tic
wb=waitbar(0,'Calculating');
set(wb,'Position',get(wb,'Position')+[mon 0 0 0])
tic;
pause(0.01);
for qq=1:length(h)
    mdf.mehit=h(qq);
    prio_model;
    for mm=1:M;
        rdata=prio_sim(Q,'N',N,'dt',dt);
        rdbdata.coeff(:,qq,mm)=rdata.coeff;
%         rdbgen.numcasts(:,qq,mm)=rdata.numcasts;  %TODO: include in fits?
        rdbdata.cps(:,qq,mm)=rdata.scps; %we only want successful casts per second    
        rdbdata.inqup(1,qq,mm)=rdata.Inqup;
    end
    waitbar(qq/length(h),wb,['Calculating #' int2str(qq) '/' int2str(length(h)) ', est=' num2str((length(h)-qq)*(toc/qq),'%3.1f') 'sec']);
end
toc
close(wb)

%store h locally
rdbdata.h=h;
