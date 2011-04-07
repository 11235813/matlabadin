%ROTATION_COEFF_DATA generates a data set of prio_sim ability weight
%coefficients as a function of melee hit for the current variable
%environment.

% h=[0.7:0.02:1]';
[ex hi]=meshgrid(linspace(0,20.5,4),linspace(0,8,4));
mh=1-(0.065+0.14+0.08)+(hi+ex)./100;
rh=1-(0.08)+hi./100;
sh=1-(0.17-0.08)+hi.*cnv.hit_sphit./cnv.hit_phhit./100;
sh=max(sh,ones(size(sh)));
N=1000;
dt=1.5;
M=3;
%initialize for speed
rdbdata.coeff=zeros(13,size(h,1),size(h,2),M);
rdbdata.cps=zeros(13,size(h,1),size(h,2),M);
rdbdata.inqup=zeros(1,size(h,1),size(h,2),M);
tic
wb=waitbar(0,'Calculating');
set(wb,'Position',get(wb,'Position')+[mon 0 0 0])
tic;
pause(0.01);
for qq=1:size(mh,1)
    for rr=1:size(mh,2)
        mdf.mehit=mh(qq,rr);
        mdf.rahit=rh(qq,rr);
        mdf.sphit=sh(qq,rr);
        prio_model;
        for mm=1:M;
            rdata=prio_sim(Q,'N',N,'dt',dt);
            rdbdata.coeff(:,qq,rr,mm)=rdata.coeff;
            %         rdbgen.numcasts(:,qq,mm)=rdata.numcasts;  %TODO: include in fits?
            rdbdata.cps(:,qq,rr,mm)=rdata.scps; %we only want successful casts per second
            rdbdata.inqup(1,qq,rr,mm)=rdata.Inqup;
        end
        tempind=(rr+(qq-1)*size(h,1));
        waitbar(tempind/length(mh(:)),wb,['Calculating #' int2str(tempind) '/' int2str(length(mh(:))) ', est=' num2str((length(mh(:))-tempind)*(toc/tempind),'%3.1f') 'sec']);
    end
end
toc
close(wb)

%store h locally
rdbdata.mh=mh;
rdbdata.rh=rh;
rdbdata.sh=sh;
