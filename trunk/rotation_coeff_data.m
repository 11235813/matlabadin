%ROTATION_COEFF_DATA generates a data set of prio_sim ability weight
%coefficients as a function of melee hit for the current variable
%environment.

h=[0.7:0.02:1]';
N=2500;
dt=1.5;
M=10;
rcgd.coeff=zeros(13,length(h),M);
tic
wb=waitbar(0,'Calculating');tic;
set(wb,'Position',get(wb,'Position')+[1600 0 0 0])
for qq=1:length(h)
    mdf.mehit=h(qq);
    prio_model;
    for mm=1:M;
        rdata=prio_sim(Q,'N',N,'dt',dt);
        rcgd.coeff(:,qq,mm)=rdata.coeff;
        rcgd.numcasts(:,qq,mm)=rdata.numcasts;  %TODO: include in fits?
        rcgd.cps(:,qq,mm)=rdata.cps;            %TODO: include in fits?
    end
    waitbar(qq/length(h),wb,['Calculating #' int2str(qq) '/' int2str(length(h)) ', est=' num2str((length(h)-qq)*(toc/qq),'%3.1f') 'sec']);
end
toc
close(wb)

save zzRCD_data rcgd