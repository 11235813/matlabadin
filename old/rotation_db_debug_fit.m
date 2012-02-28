%Figures for debugging
%called during rdb_fit


%we have an rdbgen structure
p=rdbfit.coeff{a};

[xsurf,ysurf]=meshgrid([0.71:0.01:1],[0.92:0.005:1]);
z=polyvaln(p,[xsurf(:),ysurf(:)]);
zsurf=griddata(xsurf(:),ysurf(:),z,xsurf,ysurf);

xc=x;xc=xc(:);
yc=y;yc=yc(:);
zc=zcoeff;zc=zc(:);

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
p=rdbfit.cps{a};
z=polyvaln(p,[xsurf(:),ysurf(:)]);
zsurf=griddata(xsurf(:),ysurf(:),z,xsurf,ysurf);

zc=zcps;zc=zc(:);

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

% pause(0.001)