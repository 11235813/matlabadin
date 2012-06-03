%constants
k=0.9560;           %Diminishing Returns k coefficient
K=32573;            %Armor coefficient
Cd=0.65631440;      %Diminishing Returns C coefficient - avoidance
Cb=1.351;           %Diminishing Returns C coefficient - block 
fm=179.28004455;    %mastery rating-> mastery conversions
fmb=fm/0.01;        %mastery -> block pct conversion
fms=fm/0.01;        %mastery -> sotr pct conversion
fd=176.71890258/0.01;  	%avoidance rating->pct conversion
fs=128.05715942/0.01; 	%haste rating->pct conversion
fe=120.10880279/0.01;  	%expertise rating->pct conversion
fh=120.10880279/0.01;   %hit rating->pct conversion

alpha_DP=0.15;      %Divine Purpose proc rate
alpha_GC=0.2;       %Grand Crusader proc rate
Tbuff=3;            %Duration of SotR buff, in seconds

%player info
Ar=40000;       %armor
A=0.3;          %decimal avoidance chance
Ad=0.1;         %decimal dodge chance
h=0.02;        %decimal hit percentage (2%=0.02)
e=0.02;        %decimal exp percentage (2%=0.02)
s=0.05;         %decimal haste percentage (10%=0.1)
m=20.*fm;       %mastery rating
Bcdr=1/(1/Cb+k/(m./fmb)); %DR-affected block
Bc=Bcdr+0.15;   %decimal block chance
Bv=0.3;         %decimal block value 

%boss info
Tatt0=2;    %swing timer in seconds

%% prefactors
Far  = K./(Ar+K);
Fav  = (1-A);
Fb   = 1-Bc.*Bv;

%HPG calcs
Rcs = 1/4.5;  %From FsotrM sims (or intuited)
Rj  = 1/6.75; %From FsotrM sims (or intuited)
Rbl = 0;

theta = 1-max((0.075-h),0)-max((0.15-e),0);
thetas= 1-max((0.15-h-e),0);

Rhpg = theta.*(1+alpha_GC).*(1+s).*Rcs...
      +thetas.*(1+s).*Rj + Rbl;

%SotR factors
Rsotr = Rhpg./(3.*(1-alpha_DP));
S = Rsotr.*Tbuff;S=min(S,ones(size(S)));
Msotr = 0.3 + m./fms;

Fsotr = 1-S.*Msotr;

sigma_h = (1+s).*((1+alpha_GC).*Rcs+Rj)./(3.*(1-alpha_DP));
sigma_s = ((1+alpha_GC).*theta.*Rcs + thetas.*Rj)./(3.*(1-alpha_DP));

Phi_h = sigma_h.*Msotr;
Phi_s = sigma_s.*Msotr;
Phi_m = S;

%avoidance factor
Phi_av=(1/k).*(1-Ad./Cd).^2;

%block fator
Phi_b = (Bv/k).*(1-Bcdr./Cb).^2;

%% sanity checks

% if (Rsotr.*Tbuff)>1 
%     error('SotR buff uptime exceeds 1')
% elseif Rsotr>Ratt 
%     error('Rsotr exceeds Ratt ((Ratt-Rsotr)<0)')
% elseif (Ratt-Rsotr)>Ratt 
%     error('Ratt-Rsotr out of bounds (>Ratt)')
% end

%% normalized damage reduction factors
Delta_ar = 4.*Far.*Fav.*Fb.*Fsotr./(Ar+K);
Delta_d = (1./fd).*Far.*Phi_av.*Fb.*Fsotr;
Delta_h = (1./fh).*Far.*Fav.*Fb.*Phi_h;
Delta_e = (1./fe).*Far.*Fav.*Fb.*Phi_h;
Delta_s = (1./fs).*Far.*Fav.*Fb.*Phi_s;
Delta_m = Far.*Fav.*((1./fmb).*Phi_b.*Fsotr + (1./fms).*Fb.*Phi_m);

[Delta_ar Delta_d Delta_h Delta_e Delta_s Delta_m]'.*1e5
