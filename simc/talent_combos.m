temp45={'SH'; 'EF'; 'SS'};
temp75={'DP'; 'SW'; 'HA'};
temp90={'ES'; 'LH'; 'HPr'};
temp100={'MP'; 'SP'; 'HS'};

base='00';
m=1;
clear tcombos

for i=1:3
    for j=1:3
        for k=2:2
            for l=1:3
                tcombos{m}=[base int2str(i) '2' int2str(j) int2str(k) int2str(l)...
                    ' name=' temp45{i} '+' temp75{j} '+' temp90{k} '+' temp100{l}];
                m=m+1;
            end
        end
    end
end

disp('==================')
disp(['# num talent combos = ' int2str(length(tcombos))])
for i=1:length(tcombos)
    display(tcombos{i})
end