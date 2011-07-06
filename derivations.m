%constants
k=0.9560;
K=32573;
C=0.65631440;
Cm=179.28004455;
Ca=176.71890258;
m2b=2.25./100;

%player info
Ar=40000;
A=0.1;
Av=0.35;
Bc=0.55;
Bv=[0.3 0.3667 0.4 0.5]+0.01;


%% Mastery v. Armor post
dRm_dAr=Cm./(m2b.*Bv).*(1.024-Av-Bv.*Bc)./(Ar+K);
dAr_1m=1./dRm_dAr;

%pretty print table
vals1=[Bv;dRm_dAr;dAr_1m;Cm.*dAr_1m;160./dAr_1m];
labels={'Bv','dRm/dAr','dAr_1r','dAr_1s','160/dAr_1r'};
spacer=repmat('  ',size(vals1,1),1);
Mast_v_Armor=[char(labels) spacer num2str(vals1,4)]
   
   
%% Avoidance v. Armor post
dRv_dAr=(100*k*Ca)./(1-A./C).^2.*(1.024-Av-Bv.*Bc)./(Ar+K);
dAr_1v=1./dRv_dAr;

%pretty print table
vals2=[Bv;dRv_dAr;dAr_1v;Ca.*dAr_1v];
labels={'Bv','dRv/dAr','dAr_1r','dAr_1%'};
spacer=repmat('  ',size(vals2,1),1);
Avoid_v_Armor=[char(labels) spacer num2str(vals2,4)]
   

%% Mastery v. Avoidance post
dRv_dRm = (2.25.*Bv.*Ca.*k./Cm)./(1-A./C).^2;
Acrossover=C.*(1-sqrt(2.25.*Bv.*Ca.*k./Cm)).*100;
Rcrossover=100.*k.*Ca./(100./Acrossover-1./C);

%pretty print table
vals3=[Bv;dRv_dRm;Acrossover;Acrossover+5;Rcrossover];
labels={'Bv','dRv/dRm','A_x','A_x+5','R_x'};
spacer=repmat('  ',size(vals3,1),1);
Mast_v_Avoid=[char(labels) spacer num2str(vals3,4)]
   
   
%% Meta Gems
x1=(0.02.*Ar./Bc).*(1.024-Av-Bv.*Bc)./(1.02.*Ar+K);
x2=(0.02.*Ar./Bc).*(1.024-(Av-0.05)-Bv.*(Bc-0.05))./(1.02.*Ar+K);

%pretty print table
vals4=[Bv;x1;x2];
labels={'Bv','x','x_2'};
spacer=repmat('  ',size(vals4,1),1);
Meta=[char(labels) spacer num2str(vals4,4)]

%% Reforging
Caprime=k.*Ca./(1-A./C).^2;
Cmprime=Cm./2.25;

Rt_Rv=1-Cm./(2.25.*k.*Bv.*Ca).*(1-A./C).^2;
% 1-Cmprime./Caprime

%pretty print table
vals5=[Bv;Rt_Rv;[Caprime 0 0 0];[Cmprime 0 0 0];[1-Cmprime./Caprime 0 0 0]];
labels={'Bv','Rt/Rv (TDR)','Ca''','Cm''','1-Cm''/Ca'''};
spacer=repmat('  ',size(vals5,1),1);
Reforge=[char(labels) spacer num2str(vals5,4)]