% generate unique haste points
uniqueHastePoints = [];
index = 1;
for i=1:64,
    for j=ceil( i * 2 / 3):i
        if gcd(i, j) == 1
            uniqueHastePoints(index, 1) = i;
            uniqueHastePoints(index, 2) = j;
            uniqueHastePoints(index, 3) = i / j;
            index = index + 1;
            fsm_gen('^WB>^SS>SotR5>CS>AS>J>Cons', 'Prot', '003000', i, j, 0.95, 0.95)
        end
    end       
end
% sort by haste
% sortrows(uniqueHastePoints, 3)
% fsm_gen('^WB>^SS>SotR5>CS>AS>J>Cons', 'Prot', '003000', uniqueHastePoints(:,1), uniqueHastePoints(:,2), 0.95, 0.95)