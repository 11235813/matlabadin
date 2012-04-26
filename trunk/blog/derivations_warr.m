%player info
Ar=40000;   %armor
A=0.3;     %decimal avoidance chance
Ad=0.1;     %decimal dodge chance
Ap=Ad;
Ap0=0.05;
Bc=0.55;    %decimal block chance
Bcm=Bc-0.15; %block chance subject to DR
Bv=0.3;    %decimal block value - default
C=0.2;      %decimal crit block
h=0.03;     %decimal hit percentage (2%=0.02)
e=0.02;     %decimal exp percentage (2%=0.02)
s=0.1;      %decimal haste percentage (10%=0.1)
x=0.01;     %decimal crit chance
m=0.075;
d=m;
p=d;
g=0.24;
u=0.3;
Raa0=1/2.6;

%constants
k=0.9560;           %Diminishing Returns k coefficient
K=32573;            %Armor coefficient
Cd=0.65631440;      %Diminishing Returns C coefficient - avoidance
Cb=1.351;               %Diminishing Returns C coefficient - block 
far=Ar+K;
fm=179.28004455;        %mastery rating->mast conversion
fb=0.015;
fcb=0.015;
fd=176.71890258/0.01;  	%avoidance rating->pct conversion
fs=128.05715942/0.01; 	%haste rating->pct conversion
fe=120.10880279/0.01;  	%expertise rating->pct conversion
fh=120.10880279/0.01;   %hit rating->pct conversion
fx=179.28004/0.01;
fp=fd;

Tbuff=6;            %Duration of SB buff, in seconds



%boss info
Ratt=1/2;    %one / swing timer in seconds

%% Auto-attack
c=0.24.*(Ap0+Ap).*(Ratt./(Ratt0.*(1+s))-2.*Ratt.*(Ap0+Ap)./(Ratt0.*(1+s))+2.*(Ap0+Ap));
Raa = Raa0.*(1+s)+c.*Ratt;

%% armor and avoidance mitigation factors
Far  = K./(Ar+K);
Fav = (1-A); 

Phi_av = 1/k.*(1-Ad./Cd).^2;

%% rotation factors
Theta = 1-(m-h)-(d+p-e);
Theta_s = 1-(2.*m-h-e);

Pi_2 = 0.6.*Theta.*(1-0.6.*Theta);
Pi_3 = (1-0.6.*Theta).^2;
Pi_4 = 0.6.*Theta;

Rrss=Pi_2./4.5+Pi_3./6;
Rsnb=Pi_4./4.5;
Rss=Rrss+Rsnb;
Rr=Rss;
Rshout=1/60;
Rtc=1/6-(2/15).*Theta_s;
Rd0=(Pi_2+Pi_4)./4.5+2.*Pi_3./6;
Rd=Rd0-Rtc-Rshout;

chi_rss=0.6.*(1-1.2.*Theta)./4.5 - 1.2.*(1-0.6.*Theta)./6;
chi_snb=0.6/4.5;
chi_ss=chi_rss+chi_snb;
chi_r=chi_ss;
chi_tc=2/15;
chi_d0=0.6.*(2-1.2.*Theta)./4.5 - 1.2.*(1-0.6.*Theta)./3;

%% Enrage
q1 = 1-x;
q2 = 1-C;
q3 = 1-u;
N1 = 6.*((Rss+Rd+Rr).*Theta + Rtc.*Theta_s + Raa.*(Theta-g));
N3 = 6.*Rd.*Theta;

%unfortunately, N2 depends on G, while G depends on N2.  We deal with this
%by guessing at G and then re-calculating iteratively:

G=0.1; %guess
E=0.001; %guess
Rsb=1/12; %guess

delt=[1 1 1]; %track improvement
tracker=0;

while sum(abs(delt))>1e-15;
    tracker=tracker+1;
    old = [E Rsb G];
    
    N2 = 6.*Ratt.*(1-A).*(G + (1-G).*Bc);
    
    E = 1 - 0.8.*q1.^N1.*q2.^N2.*q3.^N3;
    %% Rage Generation / Shield Block
    RPS_shout=1/3;
    RPS_SS=Theta.*(10.*Rrss+15.*Rsnb);
    RPS_TC = 10/3 - 8/3.*Theta_s;
    RPS_AA = Theta.*(1+0.5.*E).*(5.*Raa./Raa0);
    
    RPS = RPS_AA+RPS_SS+RPS_shout-RPS_TC;
    
    Rsb=RPS/60;
    
    %% Block mitigation factors
    G = Rsb.*Tbuff;G=min(1,G);
    
    new=[E Rsb G];
    
    delt=(new-old)./old;
end

tracker

%% Block mitigation factors
phi_G = (1-Bc).*(1+C).*Bv;
phi_BC = (1+G).*(1+C).*Bv;
beta_cm = fb./k.*(1-Bcm./Cb).^2;
beta_vm = fcb;

Fb = 1-G.*(1+C).*Bv - (1-G).*Bc.*(1+C).*Bv;

%% parry-haste factors

pi_s = Raa0 - 0.24.*(Ap0+Ap).*(1-(Ap0+Ap)).*Ratt./(Ratt0.*(1+s).^2);
pi_p = 0.24.*Ratt.*Phi_av.*(Ratt.*(1-4.*(Ap0+Ap))./(Ratt0.*(1+s))+4.*(Ap0+Ap));

%% cyclic factors
%here, we run into another situation where there's cyclic dependence
%(eta_2m depends on rho_m, but rho_m depends on eta_2m).  Same trick

%guesses
gamma_m=0.1;
gamma_h=0.1;
gamma_s=0.1;
gamma_d=0.1;
eta_2m=1;  %eta guesses aren't important
eta_2h=1;
eta_2s=1;
eta_2d=1;

delt=[1 1 1 1 1 1 1 1];

while sum(abs(delt))>1e-15;
    tracker=tracker+1;
    old = [gamma_m gamma_h gamma_s gamma_d eta_2m eta_2h eta_2s eta_2d];
    
    sigma_h = 5.*(1+0.5.*E).*Raa./Raa0 + 10.*Rrss+15.*Rsnb.*Theta.*(10.*chi_rss + 15.*chi_snb)+8/3;
    sigma_E = 2.5.*Theta.*(1-E).*Raa./Raa0;
    sigma_AA = 5.*Theta.*(1+0.5.*E)./Raa0;
    
    eta_1h = 6.*(1/1.5-Rshout+Raa+Theta.*(chi_ss+chi_d0+chi_r)+chi_tc.*(m-d-p));
    eta_1s = 6.*pi_s.*(Theta-g);
    eta_1p = 6.*pi_p.*(Theta-g);
    
    eta_2d = 6.*Ratt.*(gamma_d.*(1-A).*(1-Bc)-Phi_av.*(G+(1-G).*Bc));
    eta_2m = 6.*Ratt.*(1-A).*(beta_cm.*(1-G)+gamma_m.*(1-Bc));
    eta_2h = 6.*Ratt.*(1-A).*(1-Bc).*gamma_h;
    eta_2s = 6.*Ratt.*(1-A).*(1-Bc).*gamma_s;
    
    eta_3h = 6.*(Rd+chi_d0-chi_tc);
    
    epsilon_x = N1./(1-x);
    epsilon_h = eta_1h.*log(x)+eta_2h.*log(C)+eta_3h.*log(u);
    epsilon_m = N2.*beta_vm./(1-C) + eta_2m.*log(C);
    epsilon_s = eta_1s.*log(x)+eta_2s.*log(C);
    epsilon_d = eta_2d.*log(C);
    epsilon_p = eta_1p.*log(x)+epsilon_d;
    
    %% Rage Generation / Shield Block
    
    rho_h = (sigma_h+sigma_E.*epsilon_h)./60;
    rho_s = (sigma_E.*epsilon_s + sigma_AA.*pi_s)./60;
    rho_m = sigma_E.*epsilon_m./60;
    rho_x = sigma_E.*epsilon_x./60;
    rho_d = sigma_E.*epsilon_d./60;
    rho_p = (sigma_E.*epsilon_p + sigma_AA.*pi_p)./60;
    
    %% Block mitigation factor
    
    gamma_h=rho_h.*Tbuff;
    gamma_s=rho_s.*Tbuff;
    gamma_m=rho_m.*Tbuff;
    gamma_x=rho_x.*Tbuff;
    gamma_p=rho_p.*Tbuff;
    gamma_d=rho_d.*Tbuff;
    
    new = [gamma_m gamma_h gamma_s gamma_d eta_2m eta_2h eta_2s eta_2d];
    delt=(new-old);

end
tracker

Phi_bh=gamma_h.*phi_G;
Phi_bs=gamma_s.*phi_G;
Phi_bx=gamma_x.*phi_G;
Phi_bp=gamma_p.*phi_G;
Phi_bd=gamma_d.*phi_G;
Phi_bm=gamma_m.*phi_G + beta_vm.*Bv + beta_cm.*phi_BC;


%% normalized damage reduction factors
Gamma_ar = Far.*Fav.*Fb./far;
Gamma_h = Far.*Fav.*Phi_bh./fh;
Gamma_s = Far.*Fav.*Phi_bs./fs;
Gamma_x = Far.*Fav.*Phi_bx./fx;
Gamma_m = Far.*Fav.*Phi_bm./fm;
Gamma_p = (Far.*Phi_av.*Fb + Far.*Fav.*Phi_bp)./fp;
Gamma_d = (Far.*Phi_av.*Fb + Far.*Fav.*Phi_bd)./fd;

[Gamma_ar Gamma_d Gamma_p Gamma_h Gamma_x Gamma_s Gamma_m]'.*1e5


%% sanity checks

if (Rsb.*Tbuff)>1 
    error('SB buff uptime exceeds 1')
end