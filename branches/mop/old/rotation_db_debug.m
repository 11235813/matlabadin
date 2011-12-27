%Figures for debugging
% function rotation_db_debug(rdbstruc,a,gc,sd,eg)

%check an arbitrary coeff & cps & inqup fit
a=3; %3=sotr
figure(1)
tmp.gc=3;
tmp.sd=3;
tmp.eg=3;
rdbgen=rdbg(1); %choose rotation

%we have an rdbgen structure
p.ModelTerms=rdbgen.modelterms;
p.Coefficients=rdbgen.coeffpvals(a,:,tmp.gc,tmp.sd,tmp.eg);

[xsurf,ysurf]=meshgrid([0.71:0.01:1],[0.92:0.005:1]);
z=polyvaln(p,[xsurf(:),ysurf(:)]);
zsurf=griddata(xsurf(:),ysurf(:),z,xsurf,ysurf);

xc=repmat(mh,[1 1 M]);xc=xc(:);
yc=repmat(rh,[1 1 M]);yc=yc(:);
zc=squeeze(rdbgen.coeff(a,:,:,:,tmp.gc,tmp.sd,tmp.eg));zc=zc(:);

%plot stuff
figure(1)
surf(xsurf,ysurf,zsurf)
colormap bone
shading interp
hold on
plot3(xc,yc,zc,'ro');
hold off
title('COEFF surface fit')
xlabel('mdf.mehit')
ylabel('mdf.rahit')
zlabel(['COEFF for ' priolist(a).alabel])

%repeat for cps
%recreate coeff fit from pvals
p.ModelTerms=rdbgen.modelterms;
p.Coefficients=rdbgen.cpspvals(a,:,tmp.gc,tmp.sd,tmp.eg);

z=polyvaln(p,[xsurf(:),ysurf(:)]);
zsurf=griddata(xsurf(:),ysurf(:),z,xsurf,ysurf);

zc=squeeze(rdbgen.cps(a,:,:,:,tmp.gc,tmp.sd,tmp.eg));zc=zc(:);

%plot stuff
figure(2)
surf(xsurf,ysurf,zsurf)
colormap bone
shading interp
hold on
plot3(xc,yc,zc,'ro');
hold off
title('CPS surface fit')
xlabel('mdf.mehit')
ylabel('mdf.rahit')
zlabel(['CPS for ' priolist(a).alabel])

%repeat for inq uptime
%recreate coeff fit from pvals
p.ModelTerms=rdbgen.modelterms;
p.Coefficients=rdbgen.inqpvals(1,:,tmp.gc,tmp.sd,tmp.eg);

z=polyvaln(p,[xsurf(:),ysurf(:)]);
zsurf=griddata(xsurf(:),ysurf(:),z,xsurf,ysurf);

zc=squeeze(rdbgen.inqup(1,:,:,:,tmp.gc,tmp.sd,tmp.eg));zc=zc(:);

%plot stuff
figure(3)
surf(xsurf,ysurf,zsurf)
colormap bone
shading interp
hold on
plot3(xc,yc,zc,'ro');
hold off
title('Inq uptime surface fit')
xlabel('mdf.mehit')
ylabel('mdf.rahit')
zlabel(['inqup for'])


% end
% H=repmat(h,1,size(rdbgen.coeff,3));
% f=fittype('poly5');
% tempfit=rdbgen.coeffpvals(a,:,tmp.gc,tmp.sd,tmp.eg);
% c1=cfit(f,tempfit(1),tempfit(2),tempfit(3),tempfit(4),tempfit(5),tempfit(6));
% tempfit=rdbgen.cpspvals(a,:,tmp.gc,tmp.sd,tmp.eg);
% c2=cfit(f,tempfit(1),tempfit(2),tempfit(3),tempfit(4),tempfit(5),tempfit(6));
% tempfit=rdbgen.inqpvals(1,:,tmp.gc,tmp.sd,tmp.eg);
% c3=cfit(f,tempfit(1),tempfit(2),tempfit(3),tempfit(4),tempfit(5),tempfit(6));
% plot(H,squeeze(rdbgen.coeff(a,:,:,tmp.gc,tmp.sd,tmp.eg)),'b.-', ...
%      H,squeeze(rdbgen.cps(a,:,:,tmp.gc,tmp.sd,tmp.eg)),'r.-', ...
%      H,squeeze(rdbgen.inqup(1,:,:,tmp.gc,tmp.sd,tmp.eg)),'m.-',...
%      h,c1(h),'ko-',h,c2(h),'ko-',h,c3(h),'ko-')

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