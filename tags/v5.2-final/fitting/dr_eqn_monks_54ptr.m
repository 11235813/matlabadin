%% monk DR data/fitting

%data imported from excel and sorted into useful fields, loaded from
%associated .mat file
load dr_eqn_monks_54ptr.mat

%macro: /script DEFAULT_CHAT_FRAME:AddMessage("dodge: "..GetDodgeChance() ..", parry: "..GetParryChance())

%% arrange data appropriately

%row 1 must contain naked agi and str
base_agi=data(1,1);
base_str=data(1,2);

%indices of dodge and parry rows
kd=[1:2 4:59];
kp=60:66;

%create dodge vectors
agi=data(kd,1);
dodge_rating=data(kd,3);
dodge_cs=data(kd,5);
dodge_pct=data(kd,7);

%create parry vectors
str=data(kp,2);
parry_rating=data(kp,4);
parry_cs=data(kp,6);
parry_pct=data(kp,8);

%bonus agi and str are what's left after subtracting out base
bonus_agi=agi-base_agi;
bonus_str=str-base_str;

%sanity checks
dodge_ratio=dodge_rating./dodge_pct;
mean(dodge_ratio(~isnan(dodge_ratio)))

parry_ratio=parry_rating./parry_pct;
mean(parry_ratio(~isnan(parry_ratio)))

[dfit dgof]=monkDodgeSurfaceFit(base_agi, bonus_agi, dodge_rating./885, dodge_cs)


[pfit pgof]=monkParryLineFit(parry_rating./885, parry_cs)

%% results
k=1.422; %with fairly tight bounds (+/- 0.001, likely exact)
Cd=499.8; %+/-4.1, need better data
Cp=87.97; %+/-3.78, again, better data