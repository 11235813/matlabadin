function [phr]=phr_model(exec,ps,bs,pp,pb,rp)
%TODO : umm, insert some words here
%Inputs :
%ps - player swing
%bs - boss swing
%pp - player parry (%)
%pb - player block (%)
%rp - Reckoning points

%runtime vars
Ra=1./ps;
Rb=1./bs;
parry=pp./100;
block=pb./100;
rk=1-0.1.*rp.*block;


%% Player Parryhaste
parry_opps=(Rb./Ra).*exec.npccount; %player parry opportunities inside unit swing timer
int_opps=[parry_opps 1]/[floor(parry_opps) 1;floor(parry_opps)+1 1]; %rearranging to integers (u*N+v*(N+1))
if floor(parry_opps)<1
    c=0.24.*binopdf(1,floor(parry_opps)+1,parry).*int_opps(2);
elseif floor(parry_opps)==1
    if parry_opps>1./0.6 %DDPEs are permitted
        c=0.24.*binopdf(1,floor(parry_opps),parry).*int_opps(1) ...
            +(0.24.*binopdf(1,floor(parry_opps)+1,parry) ...
            +0.272.*binopdf(2,floor(parry_opps)+1,parry)).*int_opps(2);
    else                 %DDPEs are not permitted
        c=0.24.*binopdf(1,floor(parry_opps),parry).*int_opps(1) ...
            +0.24.*(1-binopdf(0,floor(parry_opps)+1,parry) ...
            -binopdf(2,floor(parry_opps)+1,parry)).*int_opps(2);
    end
else
    tmp1=1-binopdf(0,floor(parry_opps),parry)-binopdf(1,floor(parry_opps),parry);
    tmp2=1-binopdf(0,floor(parry_opps)+1,parry)-binopdf(1,floor(parry_opps)+1,parry);
    c=(0.24.*binopdf(1,floor(parry_opps),parry) ...
        +0.272.*tmp1).*int_opps(1) ...
        +(0.24.*binopdf(1,floor(parry_opps)+1,parry) ...
        +0.272.*tmp2).*int_opps(2);
end
phr.ph=(Ra+c.*Rb.*exec.timein)./Ra;
phr.phs=1./(Ra.*phr.ph);

%% Reckoning
if (numel(rp)==1&&rp==0) || (numel(exec.timein)==1&&exec.timein==0)
    phr.reck=0;
else
   upt=@(x) 1-rk.^(floor(min(8,(x+min(3,8.*(Ra.*phr.ph)))./(Ra.*phr.ph)).*Rb) ...
       +(exec.npccount>1).*(min(8,(x+min(3,8.*(Ra.*phr.ph)))./(Ra.*phr.ph)).*Rb) ...
       .*(exec.npccount-1));
   if numel([exec.npccount exec.timein ps bs pb rp])>6
       phr.reck=quadv(upt,0,1,1.e-8);
   else
       phr.reck=quadl(upt,0,1,1.e-8);
   end
end
phr.reck=phr.reck.*exec.timein;
phr.phrs=phr.phs./(1+phr.reck);
end