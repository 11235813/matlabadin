%constants
k=0.885;        %Diminishing Returns k coefficient
K=58370;        %Armor coefficient
Cd=0.65631440;  %Diminishing Returns C coefficient - dodge
Cp=2.32;        %Diminishing Returns C coefficient - parry 
fm=600/0.01;    %mastery rating-> mastery conversions
% fmb=fm/0.01;        %mastery -> block pct conversion
% fms=fm/0.01;        %mastery -> sotr pct conversion
fd=885/0.01;  	%dodge rating->pct conversion
fp=885/0.01;    %parry rating->pct conversion
fS=951.1586/0.01;  %Str->parry pct conversion
fs=425/0.01; 	%haste rating->pct conversion
fe=340/0.01;  	%expertise rating->pct conversion
fh=340/0.01;    %hit rating->pct conversion

alpha_DP=0.25;      %Divine Purpose proc rate
alpha_GC=0.2;       %Grand Crusader proc rate
Tbuff=3;            %Duration of SotR buff, in seconds

%player info
Ar=50000;       %armor
CSd=0.08;       %char sheet dodge (total)
CSp=0.13;       %char sheet parry (total)
Ad=CSd-0.05;    %post-dr dodge (DR sources only)
Ap=CSp-0.03;    %post-dr parry (DR sources only)
A0=0.08;        %base avoidance (dodge/parry, miss=0 after boss)
A=max(0.05+Ad-0.045,0)...
  +max(0.03+Ap-0.045,0);  %total avoidance, should be CSd+CSp-9 (for boss)

h=0.075;         %decimal hit percentage (2%=0.02)
e=0.075;         %decimal exp percentage (2%=0.02)
s=0.30;         %decimal haste percentage (10%=0.1)
m=0.08;          %mastery 
Bc=0.1+m-0.045; %decimal block chance
Bv=0.3;         %decimal block value 

%boss info
% Tatt0=2;    %swing timer in seconds

%% factors
Far  = K./(Ar+K);
Fav  = (1-A);
Fb   = 1-Bc.*Bv;

%HPG calcs
Rcs = 1/4.5;  %From FSM sims (or intuited)
Rj  = 1/6.75; %From FSM sims (or intuited)
% Rbl = 0;

thetam = 1-max((0.075-h),0)-max((0.15-e),0);
thetar = 1-max((0.075-h),0);

Rhpg = thetam.*(1+alpha_GC).*(1+s).*Rcs...
      +thetar.*(1+s).*Rj;

%SotR factors
Us = Rhpg./(1-alpha_DP);Us=min(Us,ones(size(Us)));
Ms = 0.3 + m;
Fs = 1-Us.*Ms;


sigma_s = ((1+alpha_GC).*thetam.*Rcs + thetar.*Rj)./(1-alpha_DP);
sigma_h = (1+s).*((1+alpha_GC).*Rcs+Rj)./(1-alpha_DP);
sigma_e = (1+s).*(1+alpha_GC).*Rcs./(1-alpha_DP);

Phi_h = sigma_h.*Ms;
Phi_e = sigma_e.*Ms;
Phi_s = sigma_s.*Ms;
Phi_m = Us;

%block factor
Phi_b = Bv;

%avoidance factor
Phi_d = (1/k).*(1-Ad./Cd).^2;
Phi_p = (1/k).*(1-Ap./Cp).^2;


%% sanity checks

% if (Rsotr.*Tbuff)>1 
%     error('SotR buff uptime exceeds 1')
% elseif Rsotr>Ratt 
%     error('Rsotr exceeds Ratt ((Ratt-Rsotr)<0)')
% elseif (Ratt-Rsotr)>Ratt 
%     error('Ratt-Rsotr out of bounds (>Ratt)')
% end

%% normalized damage reduction factors
Delta_ar = 4.*Far.*Fav.*Fb.*Fs./(Ar+K);
Delta_d = (1./fd).*Far.*Phi_d.*Fb.*Fs;
Delta_p = (1./fp).*Far.*Phi_p.*Fb.*Fs;
Delta_S = (1/fS).*Far.*Phi_p.*Fb.*Fs;
Delta_h = (1./fh).*Far.*Fav.*Fb.*Phi_h;
Delta_e = (1./fe).*Far.*Fav.*Fb.*Phi_e;
Delta_s = (1./fs).*Far.*Fav.*Fb.*Phi_s;
Delta_m = (1./fm).*Far.*Fav.*(Phi_b.*Fs + Fb.*Phi_m);

v=[Delta_ar Delta_d Delta_p Delta_S Delta_h Delta_e Delta_s Delta_m]'.*1e5;
l=char({'4\Delta_ar';'\Delta_d';'\Delta_p';'\Delta_\Sigma';'\Delta_h';'\Delta_e';'\Delta_s';'\Delta_m'});

horzcat(l,repmat(' ',size(l,1),2),num2str(v,'%1.4f'))

0.9*Far.*Fav.*Fb.*Fs