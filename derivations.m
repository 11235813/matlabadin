%constants
k=0.9560;           %Diminishing Returns k coefficient
K=32573;            %Armor coefficient
Cd=0.65631440;      %Diminishing Returns C coefficient - avoidance
Cb=1.351;               %Diminishing Returns C coefficient - block 
fm=179.28004455/0.0225; %mastery rating->pct conversion
fd=176.71890258/0.01;  	%avoidance rating->pct conversion
fs=128.05715942/0.01; 	%haste rating->pct conversion
fe=120.10880279/0.01;  	%expertise rating->pct conversion
fh=120.10880279/0.01;   %hit rating->pct conversion

alpha_DP=0.15;      %Divine Purpose proc rate
alpha_GC=0.2;       %Grand Crusader proc rate
Tbuff=6;            %Duration of SotR buff, in seconds

%player info
Ar=40000;   %armor
A=0.3;     %decimal avoidance chance
Ad=0.1;     %decimal dodge chance
Bc=0.55;    %decimal block chance
Bcdr=Bc-0.05; %block chance subject to DR
Bv2=0.75;   %decimal block value - SotR guaranteed block
Bv1=0.5;    %decimal block value - SotR buff
Bv0=0.3;    %decimal block value - default
h=0.02;     %decimal hit percentage (2%=0.02)
e=0.02;     %decimal exp percentage (2%=0.02)
s=0.1;      %decimal haste percentage (10%=0.1)

%boss info
Tatt0=2;    %swing timer in seconds

%% prefactors
Fa  = K./(Ar+K);
Fav = (1-A);

Rcs = 1/4.5;  %From FSM sims (or intuited)
Rj  = 1/6.75; %From FSM sims (or intuited)
Rbl = 0;

Rhpg = (1-max((0.075-h),0)-max((0.15-e),0)).*(1+alpha_GC).*(1+s).*Rcs...
      +(1-max((0.15-h-e),0)).*(1+s).*Rj + Rbl;

Rsotr = Rhpg./(3.*(1-alpha_DP));
Ratt = Fav./Tatt0;

G = Rsotr./Ratt; G = min(G,ones(size(G))); %SotR guaranteed block uptime, bounded by 1
S = Rsotr.*(Ratt.*Tbuff - 1)./(Ratt-Rsotr); S=min(S,ones(size(S)));
 
% G=0; %uncomment to disable SotR effects

Fb  = 1 - G.*Bv2 - (1-G).*Bc.*S.*Bv1 - (1-G).*Bc.*(1-S).*Bv0;

FbG = Bv2-Bc.*S.*Bv1-Bc.*(1-S).*Bv0;
FbB = (1-G).*(S.*Bv1 + (1-S).*Bv0);
FbS = (1-G).*Bc.*(Bv1-Bv0);

% FbG=0;

beta_h = ((1+alpha_GC).*Rcs+Rj).*(1+s)./(3.*(1-alpha_DP)).* ...
         (FbG./Ratt+S.*FbS./((Ratt-Rsotr).*Rsotr));
beta_s = (Rhpg-Rbl)./(3.*(1-alpha_DP).*(1+s)).*...
         (FbG./Ratt+S.*FbS./((Ratt-Rsotr).*Rsotr));
beta_d = (1-Ad./Cd).^2./(k.*Tatt0).* ...
         (Rsotr.*FbG./Ratt.^2 + (1-Rsotr.^2.*Tbuff).*FbS./(Ratt-Rsotr).^2);     
beta_m = (1-Bcdr./Cb).^2./k.*FbB;     

%% sanity checks

if (Rsotr.*Tbuff)>1 
    error('SotR buff uptime exceeds 1')
elseif Rsotr>Ratt 
    error('Rsotr exceeds Ratt ((Ratt-Rsotr)<0)')
elseif (Ratt-Rsotr)>Ratt 
    error('Ratt-Rsotr out of bounds (>Ratt)')
end

%% normalized damage reduction factors
gamma_ar = Fa.*Fav.*Fb./(Ar+K);
gamma_d = (Fa./fd).*((1-Ad./Cd).^2./k.*Fb + beta_d.*Fa);
gamma_h = beta_h.*Fa.*Fav./fh;
gamma_e = beta_h.*Fa.*Fav./fe;
gamma_s = beta_s.*Fa.*Fav./fs;
gamma_m = beta_m.*Fa.*Fav./fm;

[gamma_ar gamma_d gamma_h gamma_e gamma_s gamma_m]'.*1e5
