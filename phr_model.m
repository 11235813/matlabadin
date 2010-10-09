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
    c=(0.24.*binopdf(1,floor(parry_opps),parry) ...
        +0.272.*binopdf(2,floor(parry_opps),parry)).*int_opps(1) ...
        +(0.24.*binopdf(1,floor(parry_opps)+1,parry) ...
        +0.272.*binopdf(2,floor(parry_opps)+1,parry)).*int_opps(2);
end
phr.ph=(Ra+c.*Rb.*exec.timein)./Ra;
phr.phs=1./(Ra.*phr.ph);

%% Reckoning
if rp==0||exec.timein==0
    phr.reck=0;
else
    if (8./phr.phs)>=3
        if (8./phr.phs)>4
            int1=1-(1./(phr.phs.*Rb.*exec.npccount.*log(rk))) ...
                .*(rk.^((3+1).*Rb.*exec.npccount.*phr.phs) ...
                -rk.^(3.*Rb.*exec.npccount.*phr.phs));
            phr.reck=int1.*exec.timein;
        else
            k=(8./phr.phs)-3;
            int1=k-(1./(phr.phs.*Rb.*exec.npccount.*log(rk))) ...
                .*(rk.^((3+k).*Rb.*exec.npccount.*phr.phs) ...
                -rk.^(3.*Rb.*exec.npccount.*phr.phs));
            int2=(1-k).*(1-rk.^(8.*Rb.*exec.npccount));
            phr.reck=(int1+int2).*exec.timein;
        end
    else
        int1=1-rk.^(8.*Rb.*exec.npccount);
        phr.reck=int1.*exec.timein;
    end
end
phr.phrs=phr.phs./(1+phr.reck);
end