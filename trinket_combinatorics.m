trinkets={
'vial_of_convulsive_shadows,id=113969,bonus_id=567'
'pols_blinded_eye,id=113834,bonus_id=567'
'pillar_of_the_earth,id=113650,bonus_id=567'
'blast_furnace_door,id=113893,bonus_id=567'
'battering_talisman,id=113987,bonus_id=567'
'petrified_flesheating_spore,id=113663,bonus_id=567'
'horn_of_screaming_spirits,id=119193,bonus_id=567'
'forgemasters_insignia,id=113983,bonus_id=567'
'tectus_beating_heart,id=113645,bonus_id=567'
'captive_microaberration,id=113853,bonus_id=567'
'evergaze_arcane_eidolon,id=113861,bonus_id=567'
'tablet_of_turnbuckle_teamwork,id=113905,bonus_id=567'
'quiescent_runestone,id=113859,bonus_id=567'
'goren_soul_repository,id=119194,bonus_id=567'
'ironspike_chew_toy,id=119192,bonus_id=567'
'meaty_dragonspine_trophy,id=118114,bonus_id=567'
'humming_blackiron_trigger,id=113985,bonus_id=567'
'blackiron_micro_crucible,id=113984,bonus_id=567'
'darmacs_unstable_talisman,id=113948,bonus_id=567'
'beating_heart_of_the_mountain,id=113931,bonus_id=567'
'shards_of_nothing,id=113835,bonus_id=567'
'bottle_of_infesting_spores,id=113658,bonus_id=567'
'scales_of_doom,id=113612,bonus_id=567'
};
tabb={
    'VCS';'PBE';'PotE';'BFD';'BT';'PFS';
    'HoSS';'FI';'TBH';'CM';'EAE';'ToTT';'QR';
    'GSR';'ICT';'MDT';'HBT';'BMC';'DUT';'BHotM';
    'SoN';'BoIS';'SoD';};

N=length(trinkets)
clc
%% one trinket
k=0;
for i=1:N
   disp('AMR_4P.simc');
   disp(strcat('trinket1=',trinkets{i}));
   disp(strcat('trinket2=fake,stats=10str'));
   disp(strcat('name=',tabb{i}));
   disp(' ');
end


disp('=====================================================')
disp('Two Trinkets')                
disp('=====================================================')

%% two trinkets
ignored={'BMC';'ICT';'SoN';'HBT';'BHotM';'QR';'SoD';'CM';'MDT';'GSR';'DUT'};
k=0;
for i=1:N
    for j=i+1:N
        ig=not_ignoring(tabb{j},ignored)&not_ignoring(tabb{i},ignored);
        if ig==true
            disp('AMR_4P.simc');
            disp(strcat('trinket1=',trinkets{i}));
            disp(strcat('trinket2=',trinkets{j}));
            disp(strcat('name=',tabb{i},'+',tabb{j}));
            disp(' ')
            k=k+1;
            if mod(k,64)==0
                disp('=====================================================')
                disp(strcat(int2str(k),' combinations'))
                disp('=====================================================')
                pause
            end
        end
    end
end

disp(strcat(int2str(k),' combinations'))
