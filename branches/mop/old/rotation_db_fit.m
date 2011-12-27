%ROTATION_COEFF_FIT takes a set of rdbgen.coeff data generated by
%rotation_coeff_data and fits each data set with a 5th-order polynomial.
%The results are stored in rdbgen.pvals

%% Now for fits/plots

%define fit model
if exist('rdbgen')==0 || isfield(rdbgen,'model')==0
    rdbgen.model='constant x x^2 x^3 y y^2 y^3 x*y y*x^2 x*y^2';
end

rdbfit.maxlength=1;
for a=1:size(rdbdata.coeff,1)
    
    %fit coeffs
    x=[];y=[];zcoeff=[];zcps=[];zinq=[];
    x=repmat(rdbdata.mh,[1 1 M]);
    y=repmat(rdbdata.rh,[1 1 M]);
    zcoeff=squeeze(rdbdata.coeff(a,:,:,:));
    zcps=squeeze(rdbdata.cps(a,:,:,:));
    
    %fit data
    rdbfit.coeff{a} =polyfitn([x(:),y(:)],zcoeff(:),rdbgen.model);
    rdbfit.cps{a}   =polyfitn([x(:),y(:)],zcps(:),rdbgen.model);
    
    if rdbgen.showplots==1  %TODO: add exist/field check
        rotation_db_debug_fit;
        pause;
    end
    
end
    
rdbfit.maxlength=length(rdbfit.coeff{a}.Coefficients);
    
%fit Inq
zinq=squeeze(rdbdata.inqup(1,:,:,:));
rdbfit.inq=polyfitn([x(:),y(:)],zinq(:),rdbgen.model);

%% Collect and store coefficients
rdbfit.coeffpvals=zeros(size(rdbdata.coeff,1),rdbfit.maxlength);
rdbfit.cpspvals=zeros(size(rdbdata.cps,1),rdbfit.maxlength);
rdbfit.inqpvals=zeros(1,rdbfit.maxlength);
for a=1:size(rdbdata.coeff,1)
    rdbfit.coeffpvals(a,:)=rdbfit.coeff{a}.Coefficients;
    rdbfit.cpspvals(a,:)=rdbfit.cps{a}.Coefficients;
end
rdbfit.inqpvals(1,:)=rdbfit.inq.Coefficients;
