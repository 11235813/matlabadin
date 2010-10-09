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

%Naked
tempegs(15)=equip(1);
ddb.gearset{3}=tempegs;

%premade gear set
tempegs(1)=equip(00101);  %head
tempegs(2)=equip(55888); %neck
tempegs(3)=equip(56124);%shoulders
tempegs(4)=equip(56219);%back
tempegs(5)=equip(66933);%chest
tempegs(6)=equip(55992);%wrists
tempegs(7)=equip(56099);%hands
tempegs(8)=equip(00103);%waist
tempegs(9)=equip(10103);%legs
tempegs(10)=equip(10104);%feet
tempegs(11)=equip(56111);%finger0
tempegs(12)=equip(10105);%finger1
tempegs(13)=equip(56121);%trinket0
tempegs(14)=equip(10106);%trinket1
tempegs(15)=equip(63799);%main hand
tempegs(16)=equip(56096);%off hand
tempegs(17)=equip(63888);%ranged
%%Enchants (21-37)
tempegs(21)=equip(86931,'s');%head
% tempegs(22)=equip(2);%neck
tempegs(23)=equip(86847,'s');%shoulders
tempegs(24)=equip(74234,'s');%back
tempegs(25)=equip(74251,'s');%chest
tempegs(26)=equip(62256,'s');%wrists
tempegs(27)=equip(74255,'s');%hands
% tempegs(28)=equip(4);%waist
tempegs(29)=equip(78170,'s');%legs
tempegs(30)=equip(74189,'s');%feet
tempegs(31)=equip(1,'s');%finger0
tempegs(32)=equip(1,'s');%finger1
% tempegs(33)=equip(2);%trinket0
% tempegs(34)=equip(2);%trinket1
tempegs(35)=equip(59619,'s');%main hand
tempegs(36)=equip(74207,'s');%off hand
% tempegs(37)=equip(4);%ranged
ddb.gearset{4}=tempegs;



%% Talent Specs
%38 points in prot, 0 in holy/ret
temptree.holy=zeros(2,4);temptree.ret=zeros(2,4);temptree.prot=zeros(7,4);
temptree.prot=[3 2 2 0; 2 3 2 0; 2 3 1 2; 2 1 2 0; 1 1 2 1; 0 2 3 0; 0 1 0 0];
ddb.talentset{1}=temptree;

temptree.prot=[3 2 0 0; 2 3 2 0; 2 3 1 2; 2 1 2 0; 1 1 0 0; 0 2 3 0; 0 1 0 0];
temptree.ret=[0 3 2 0; 0 0 0 0];
ddb.talentset{2}=temptree;

%% Glyphs
tempglyphs.prime=[0 0 0 0 0 0 0];
tempglyphs.minor=[0 0 0 0 0 0 0];
tempglyphs.major=[0 0 0 0 0 0 0 0 0 0];
ddb.glyphset{1}=tempglyphs;