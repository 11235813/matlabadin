clear
%simulation conditions
simMins=10000;


%% set up stat configs
i=1;
statSetup(i).plotNum=i;
statSetup(i).buffedStr=9208;
statSetup(i).parryRating=4834;
statSetup(i).dodgeRating=4892;
statSetup(i).masteryRating=6758;
statSetup(i).hitRating=1521;
statSetup(i).expRating=1777;
statSetup(i).hasteRating=0;
i=i+1;
statSetup(i).plotNum=i;
statSetup(i).buffedStr=9208;
statSetup(i).parryRating=2834;
statSetup(i).dodgeRating=2892;
statSetup(i).masteryRating=6758;
statSetup(i).hitRating=2521;
statSetup(i).expRating=2777;
statSetup(i).hasteRating=2000;
i=i+1;
statSetup(i).plotNum=i;
statSetup(i).buffedStr=9208;
statSetup(i).parryRating=2834;
statSetup(i).dodgeRating=2892;
statSetup(i).masteryRating=5758;
statSetup(i).hitRating=2521;
statSetup(i).expRating=2777;
statSetup(i).hasteRating=3000;
i=i+1;
statSetup(i).plotNum=i;
statSetup(i).buffedStr=9208;
statSetup(i).parryRating=7834;
statSetup(i).dodgeRating=6892;
statSetup(i).masteryRating=5758;
statSetup(i).hitRating=21;
statSetup(i).expRating=277;
statSetup(i).hasteRating=0;


%% crank
% if matlabpool('size')>0
%     matlabpool close
% end

% matlabpool(3)
for j=1:i
% parfor j=1:i
%     tic
    [dtps(j) statblock(j)]=pally_mc(' ',0,simMins,'plot','toc',statSetup(j));
    Rhpg(j)   =statblock(j).Rhpg;
    S(j)      =statblock(j).S;
    Tsotr(j)  =statblock(j).Tsotr;
    MAmean(j) =statblock(j).meanma;
    MAstd(j)  =statblock(j).stdma;
%     toc
end


    
% matlabpool close
fbase=['pally_smooth_data_' int2str(simMins)];
i=0;
while exist([fbase int2str(i) '.mat'])==2
    i=i+1;
end
save([fbase int2str(i) '.mat'])
% save(['pally_sw_data_' int2str(simMins) '_' int2str(numSims) '_' int2str(statAmount) '.mat'])

%% calculate stats
%what do we want to know?