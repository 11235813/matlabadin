%CALC_STATSCALING calculates the scaling of our abilites with different
%stats



%The construction of this module is that we have a coefficient matrix
%(cmat) which is an NxM matrix of ability coefficients Cij for each of the
%M abilities in N different rotations.  We thus want to construct an MxL
%matrix (adam) of damage values for the M abilities as they scale with a
%particular stat (L different values).  If we matrix multiply cmat*adam, we
%get an NxL matrix containing the DPS values for each rotation as it scales
%with that stat.
%
%When using rotation_model, cmat is 1xM, which simplifies a lot of things.


%% construct adam
clear;
gear_db;
def_db;

% lvl 85
base=player_model('lvl',80,'race','Human','prof','');
npc=npc_model(base);
gear_sample
glyph=ddb.glyphset{1}; %no glyphs
talent=ddb.talentset{3};  %0/31/5

%execution
exec=execution_model('npccount',1,'timein',1,'timeout',1,'seal','Truth');
%activate buffs
buff=buff_model('mode',3);
%invoke talents & glyphs
talents
%calculate relevant stats
gear_stats
%calculate final stats
stat_model
ability_model_80
rotation_model

%arrays for varying things
vary=1:1000;
novary=zeros(size(vary));
stat={'exp';'hit';'str';'ap';'sta';'crit';'agi';'haste';'mas';'sp';'int'};
M=length(stat);  %number of "extra" stats
dstat=10.*ones(1,M);


%% Strength graph

extra_init;

extra.val.str=vary;


for m=1:M
    %set each stat to dstat extra
    eval(char(['extra.itm.' stat{m} '=dstat(m);']))

    stat_model;ability_model_80;rotation_model;cmat=rot.coeff';

    dps1(m,:)=cmat*pridmg;
    
    
    
    %set each stat back to 0 extra
    eval(char(['extra.itm.' stat{m} '=0;']))

    stat_model;ability_model_80;rotation_model;cmat=rot.coeff';

    dps0(m,:)=cmat*pridmg;

end
diffdps=dps1-dps0;

figure(50)
plot(player.armorystr',diffdps')
legend(stat)
