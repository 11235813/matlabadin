%constants
k=0.885;        %Diminishing Returns k coefficient
K=58370;        %Armor coefficient
Cd=0.65631440;  %Diminishing Returns C coefficient - dodge
Cp=2.361;        %Diminishing Returns C coefficient - parry 
Cb=1.491;       %Diminishing Returns C coefficient - block
fm=600/0.01;    %mastery rating-> mastery conversions
% fmb=fm/0.01;        %mastery -> block pct conversion
% fms=fm/0.01;        %mastery -> sotr pct conversion
fd=885/0.01;  	%dodge rating->pct conversion
fp=885/0.01;    %parry rating->pct conversion
fS=951.1586/0.01/1.05;  %Str->parry pct conversion, Kings-corrected
fs=425/0.01; 	%haste rating->pct conversion
fe=340/0.01;  	%expertise rating->pct conversion
fh=340/0.01;    %hit rating->pct conversion

alpha_DP=0.0;      %Divine Purpose proc rate
alpha_HA=1;         %Holy Avenger HP multiplier
alpha_SW=0;         %Sanctified Wrath toggle
alpha_GC=0.2;       %Grand Crusader proc rate
Tbuff=3;            %Duration of SotR buff, in seconds

%player info
Ar=55000;       %armor
CSp=0.1;       %char sheet parry (total)
CSd=0.07;       %char sheet dodge (total)
baseStr=178;
% CSd=[0.05:0.0025:0.3];
% CSp=[0.03:0.0025:0.4];

Ad=CSd-0.0501;    %post-dr dodge (DR sources only)
Ap=CSp-0.03-baseStr/fS/1.05;    %post-dr parry (DR sources only)
A0=0.08;        %base avoidance (dodge/parry, miss=0 after boss)
A=max(CSd-0.045,0)...
  +max(CSp-0.045,0);  %total avoidance, should be CSd+CSp-9 (for boss)

h=0.075;         %decimal hit percentage (2%=0.02)
e=0.075;         %decimal exp percentage (2%=0.02)
s=0.05;         %decimal haste percentage (10%=0.1)
m=0.25;          %mastery 
% s=[0.00:0.01:0.5];
% h=[0.00:0.0025:0.075];
% e=[0.00:0.0025:0.15];
% m=[0.08:0.01:0.5];
beta=1./(1./Cb+k./m);
Bc=0.13+beta-0.045; %decimal block chance
Bv=0.3;         %decimal block value 

%boss info
% Tatt0=2;    %swing timer in seconds

%% factors
Far  = K./(Ar+K);
Fav  = (1-A);
Fb   = 1-Bc.*Bv;

%HPG calcs
Rcs = 1/4.5-alpha_SW/18;  %From FSM sims (or intuited)
Rj  = 1/6.75+alpha_SW/5.4; %From FSM sims (or intuited)
% Rbl = 0;

thetam = 1-max((0.075-h),0)-max((0.15-e),0);
thetar = 1-max((0.075-h),0);

Rhpg = (thetam.*(1+alpha_GC).*(1+s).*Rcs...
      +thetar.*(1+s).*Rj)*(alpha_HA);

%SotR factors
Us = Rhpg./(1-alpha_DP);Us=min(Us,ones(size(Us)));
Ms = 0.3 + m;   
Fs = 1-Us.*Ms;

if Us==1
    sigma_s=0;sigma_h=0;sigma_e=0;
else
    sigma_s = ((1+alpha_GC).*thetam.*Rcs + thetar.*Rj)./(1-alpha_DP);
    sigma_h = (1+s).*((1+alpha_GC).*Rcs+Rj)./(1-alpha_DP);
    sigma_e = (1+s).*(1+alpha_GC).*Rcs./(1-alpha_DP);
end

Phi_h = sigma_h.*Ms;
Phi_e = sigma_e.*Ms;
Phi_s = sigma_s.*Ms;
Phi_m = Us;

%block factor
Phi_b = (k.*Bv./m.^2).*(1./Cb+k./m).^(-2);

%avoidance factor
Phi_d = (1/k).*(1-Ad./Cd).^2;
Phi_p = (1/k).*(1-Ap./Cp).^2;

TDR=(1-0.9*Far.*Fav.*Fb.*Fs)*100;
%% sanity checks

% if (Rsotr.*Tbuff)>1 
%     error('SotR buff uptime exceeds 1')
% elseif Rsotr>Ratt 
%     error('Rsotr exceeds Ratt ((Ratt-Rsotr)<0)')
% elseif (Ratt-Rsotr)>Ratt 
%     error('Ratt-Rsotr out of bounds (>Ratt)')
% end

%% normalized damage reduction factors
Delta_ar = 3.*Far.*Fav.*Fb.*Fs./(Ar+K);
Delta_d = (1./fd).*Far.*Phi_d.*Fb.*Fs;
Delta_p = (1./fp).*Far.*Phi_p.*Fb.*Fs;
Delta_S = (1/fS).*Far.*Phi_p.*Fb.*Fs;
Delta_m = (1./fm).*Far.*Fav.*(Phi_b.*Fs + Fb.*Phi_m);
Delta_h = (1./fh).*Far.*Fav.*Fb.*Phi_h;
Delta_e = (1./fe).*Far.*Fav.*Fb.*Phi_e;
Delta_s = (1./fs).*Far.*Fav.*Fb.*Phi_s;

if length(Delta_h)>1 || length(Delta_s)>1 || length(Delta_p)>1 || length(Delta_h)>1
    figure(1);clf;
    if length(s)>1
        x=s.*100;
        xlbl='haste (%)';
    elseif length(h)>1
        x=h.*100;
        xlbl='hit (%)';
    elseif length(e)>1
        x=e.*100;
        xlbl='exp (%)';
    elseif length(m)>1
        x=m.*100;
        xlbl='mastery (%)';
    elseif length(CSd)>1
        x=CSd.*100;
        xlbl='Char Sheet Dodge (%)';
    elseif length(CSp)>1
        x=CSp.*100;
        xlbl='Char Sheet Parry (%)';
    end
    osx=ones(size(x));
    plot(x,Delta_d.*osx,x,Delta_p.*osx,x,Delta_S.*osx,x,Delta_m.*osx,x,Delta_h.*osx,x,Delta_e.*osx,x,Delta_s.*osx)
    xlabel(xlbl)
    xlim([min(x) max(x)])
    ylabel('TDR stat weight')
    legend('\Delta_d','\Delta_p','\Delta_\Sigma','\Delta_m','\Delta_h','\Delta_e','\Delta_s')
    
else

v=[Delta_ar Delta_d Delta_p Delta_S Delta_m Delta_h Delta_e Delta_s]'.*1e5;
l=char({'$latex 3\Delta_{ar}=';'$latex \Delta_d=';'$latex \Delta_p=';'$latex \Delta_\Sigma=';'$latex \Delta_m=';'$latex \Delta_h=';'$latex \Delta_e=';'$latex \Delta_s='});

output=horzcat(l,repmat(' ',size(l,1),2),num2str(v,'%1.4f'),repmat('$',size(l,1),1));
for j=1:size(output,1)
    output2{j}=regexprep(output(j,:),'\s*',' ');
end

disp('-----')
disp(['Ar=' int2str(Ar) ', Dodge=' num2str(CSd*100,'%2.1f') '%, Parry=' num2str(CSp*100,'%2.1f') '%, mastery=' num2str(m*100,'%2.1f') '%'])
disp(['hit=' num2str(h*100,'%1.2f') '%, exp=' num2str(e*100,'%1.2f') '%, haste=' num2str(s*100,'%2.2f') '%'])
disp(' ')
disp(char(output2))
disp(' ')
disp(['Far=' num2str(Far,'%1.4f') ', Fav=' num2str(Fav,'%1.4f') ', Fb=' num2str(Fb,'%1.4f') ', Fs=' num2str(Fs,'%1.4f')])
disp(' ')
disp(['TDR=' num2str(TDR,'%2.3f') '%'])
end