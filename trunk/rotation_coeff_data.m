%ROTATION_COEFF_DATA generates a data set of prio_sim ability weight
%coefficients as a function of melee hit for the current variable
%environment.

h=[0.7:0.02:1]';
N=10000;
dt=1.5;
M=5;
rcgd.coeff=zeros(13,length(h));
tic
wb=waitbar(0,'Calculating');tic;
for qq=1:length(h)
    mdf.mehit=h(qq);
    prio_model;
    for m=1:M;
        rdata=prio_sim(3,'N',N,'dt',dt);
        rcgd.coeff(:,qq,m)=rdata.coeff;
    end
    waitbar(qq/length(h),wb,['Calculating #' int2str(qq) '/' int2str(length(h)) ', est=' num2str((length(h)-qq)*(toc/qq),'%3.1f') 'sec']);
end
toc
close(wb)

save zzRCD_data rcgd