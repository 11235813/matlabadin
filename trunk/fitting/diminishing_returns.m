%Values Rogue Druid Hunter Mage Paladin Priest Shaman Warlock Warrior Death Knight Monk
ParryFactor = [ 1 1 1 1 0.634 1 1 1 0.634 0.634 1.659];
DodgeFactor = [ 1 1 1 1 2.259 1 1 1 1.659 1.659 0.3];
MissFactor = [ 1 6.555555 1 1 8.5 1 1 1 8.5 8.5 6.555555];
BlockFactor = [ 1 1 1 1 1 1 1 1 1 1 1];
VerticalStretch = [ 0.00687 0.00665 0.00687 0.00665 0.00665 0.00665 0.00687 0.00665 0.00665 0.00665 0.00665];
HorizontalShift = [ 0.988 1.222 0.988 0.983 0.886 0.983 0.988 0.983 0.956 0.956 1.422];



% totalDodge = baseDodge + bonusDodge / (DodgeFactor .* bonusDodge * 100 * VerticalStretch + HorizontalShift );

k = HorizontalShift;
Cd = 1./(DodgeFactor.*100.*VerticalStretch)*100;
Cp = 1./(ParryFactor.*100.*VerticalStretch)*100;
Cm = 1./(MissFactor.*100.*VerticalStretch)*100;
Cb = 1./(BlockFactor.*100.*VerticalStretch)*100;


[k' Cd' Cp' Cm' Cb']

ids=[9 5 3 1 6 10 7 4 8 11 2];

parry_str='{ 0,';
dodge_str='{ 0,';
miss_str='{ 0,';
block_str='{ 0,';
vert_str='{ 0,';
hori_str='{ 0,';

for i=ids;
    
    parry_str = [parry_str ' ' num2str(ParryFactor(i),'%1.3f')];
    dodge_str = [dodge_str ' ' num2str(DodgeFactor(i),'%1.3f')];
    miss_str = [miss_str ' ' num2str(MissFactor(i),'%1.6f')];
    block_str = [block_str ' ' num2str(BlockFactor(i),'%1.3f')];
    vert_str = [vert_str ' ' num2str(VerticalStretch(i),'%1.5f')];
    hori_str = [hori_str ' ' num2str(HorizontalShift(i),'%1.3f')];
    
    if i~=ids(length(ids))
        parry_str = [ parry_str ','];
        dodge_str = [ dodge_str ','];
        miss_str = [ miss_str ','];
        block_str = [ block_str ','];
        vert_str = [ vert_str ','];
        hori_str = [ hori_str ','];
    end
end

parry_str=[parry_str ' };']
dodge_str=[dodge_str ' };']
miss_str=[miss_str ' };']
block_str=[block_str ' };']
vert_str=[vert_str ' };']
hori_str=[hori_str ' };']
    

% parry_str