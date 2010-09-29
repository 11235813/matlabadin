%DEF_DB is a database of default configurations for gear, talents, glyphs,
%etc.  This is for easy swapping between setups.

%% Gear Sets

%%Naked gear set with premade mace/shield
tempegs(1)=equip(1);  %head
tempegs(2)=equip(1); %neck
tempegs(3)=equip(1);%shoulders
tempegs(4)=equip(1);%back
tempegs(5)=equip(1);%chest
tempegs(6)=equip(1);%wrists
tempegs(7)=equip(1);%hands
tempegs(8)=equip(1);%waist
tempegs(9)=equip(1);%legs
tempegs(10)=equip(1);%feet
tempegs(11)=equip(1);%finger0
tempegs(12)=equip(1);%finger1
tempegs(13)=equip(1);%trinket0
tempegs(14)=equip(1);%trinket1
tempegs(15)=equip(63799);%main hand
tempegs(16)=equip(56096);%off hand
tempegs(17)=equip(1);%ranged
%%Enchants (21-37)
tempegs(21)=equip(1,'s');%head
% tempegs(22)=equip(2);%neck
tempegs(23)=equip(1,'s');%shoulders
tempegs(24)=equip(1,'s');%back
tempegs(25)=equip(1,'s');%chest
tempegs(26)=equip(1,'s');%wrists
tempegs(27)=equip(1,'s');%hands
% tempegs(28)=equip(4);%waist
tempegs(29)=equip(1,'s');%legs
tempegs(30)=equip(1,'s');%feet
tempegs(31)=equip(1,'s');%finger0
tempegs(32)=equip(1,'s');%finger1
% tempegs(33)=equip(2);%trinket0
% tempegs(34)=equip(2);%trinket1
tempegs(35)=equip(1,'s');%main hand
tempegs(36)=equip(1,'s');%off hand
% tempegs(37)=equip(4);%ranged
ddb.gearset{1}=tempegs;

%Naked with Dalaran Sword
tempegs(15)=equip(44638);
tempegs(16)=equip(1);

ddb.gearset{2}=tempegs;



%% Talent Specs
%38 points in prot, 0 in holy/ret
temptree.holy=zeros(2,4);temptree.ret=zeros(2,4);temptree.prot=zeros(7,4);
temptree.prot=[3 2 2 0; 2 3 2 0; 2 3 1 2; 2 1 2 0; 1 1 2 1; 0 2 3 0; 0 1 0 0];
ddb.talentset{1}=temptree;

%% Glyphs