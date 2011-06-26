%constants
k=0.9560;
K=32573;
C=0.65631440;
Cm=179.28004455;
Ca=176.71890258;
m2b=2.25./100;

%player info
Ar=40000;
Av=0.35;
Ad=0.1;
Bc=0.55;
Bv=[0.3 0.3667 0.4 0.5];


%Mastery v. Armor post
dRm_dAr=Cm./(m2b.*Bv).*(1.024-Av-Bv.*Bc)./(Ar+K);
dAr_1m=1./dRm_dAr;

%pretty print table
vals1=[dRm_dAr;dAr_1m;Cm.*dAr_1m;160./dAr_1m];
spacer=repmat('  ',5,1);
table=[char({'Mast/Armor','dRm/dAr','dAr_1r','dAr_1s','160/dAr_1'}) spacer ...
       char({' ',num2str(vals1(:,1),4)}) spacer ...
       char({' ',num2str(vals1(:,2),4)}) spacer ...
       char({' ',num2str(vals1(:,3),4)}) spacer ...
       char({' ',num2str(vals1(:,3),4)}) spacer]
   
   
%Avoidance v. Armor post
dRv_dAr=(100*k*Ca)./(1-Ad./C).^2.*(1.024-Av-Bv.*Bc)./(Ar+K);
dAr_1v=1./dRv_dAr;

%pretty print table
vals2=[dRv_dAr;dAr_1v;Ca.*dAr_1v];
spacer2=repmat('  ',4,1);
table2=[char({'Avoid/Armor','dRv/dAr','dAr_1r','dAr_1s'}) spacer2 ...
       char({' ',num2str(vals2(:,1),4)}) spacer2 ...
       char({' ',num2str(vals2(:,2),4)}) spacer2 ...
       char({' ',num2str(vals2(:,3),4)}) spacer2 ...
       char({' ',num2str(vals2(:,3),4)}) spacer2]
   

%Mastery v. Avoidance post
dRv_dRm = (2.25.*Bv.*Ca.*k./Cm)./(1-Ad./C).^2;
Acrossover=C.*(1-sqrt(2.25.*Bv.*Ca.*k./Cm)).*100;
Rcrossover=100.*k.*Ca./(100./Acrossover-1./C);

%pretty print table
vals3=[dRv_dRm;Acrossover;Acrossover+5;Rcrossover];
spacer3=repmat('  ',5,1);
table3=[char({'Avoid/Mast','dRv/dRm','A_x','A_x+5','R_x'}) spacer3 ...
       char({' ',num2str(vals3(:,1),4)}) spacer3 ...
       char({' ',num2str(vals3(:,2),4)}) spacer3 ...
       char({' ',num2str(vals3(:,3),4)}) spacer3 ...
       char({' ',num2str(vals3(:,3),4)}) spacer3]
   
dRv_dRm_CTC=(2.25*k*Ca)./(Cm.*(1-Ad./C).^2)
   
   
%Meta Gems
xmdr=(0.02.*Ar./Bc).*(1.024-Av-Bv.*Bc)./(1.02.*Ar+K);
xctc=(0.02.*Ar./Bc).*(1.024-(Av-0.05)-Bv.*(Bc-0.05))./(1.02.*Ar+K);

%pretty print table
vals4=[xmdr;xctc];
spacer4=repmat('  ',3,1);
table4=[char({'Meta','x_mdr','x_ctc'}) spacer4 ...
       char({' ',num2str(vals4(:,1),4)}) spacer4 ...
       char({' ',num2str(vals4(:,2),4)}) spacer4 ...
       char({' ',num2str(vals4(:,3),4)}) spacer4 ...
       char({' ',num2str(vals4(:,3),4)}) spacer4]

%Reforging
Caprime=k.*Ca./(1-Ad./C).^2;
Cmprime=Cm./2.25;

dRt_dRv=1-Cm./(2.25.*k.*Bv.*Ca).*(1-Ad./C).^2;
% 1-Cmprime./Caprime

%pretty print table
vals5=[[Caprime 0 0 0];[Cmprime 0 0 0];dRt_dRv;[1-Cmprime./Caprime 0 0 0]];
spacer5=repmat('  ',5,1);
table5=[char({'Reforge','Ca''','Cm''','dRt_dRv','1-Cm''/Ca'''}) spacer5 ...
       char({' ',num2str(vals5(:,1),4)}) spacer5 ...
       char({' ',num2str(vals5(:,2),4)}) spacer5 ...
       char({' ',num2str(vals5(:,3),4)}) spacer5 ...
       char({' ',num2str(vals5(:,3),4)}) spacer5]