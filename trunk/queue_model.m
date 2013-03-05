%QUEUE_MODEL contains the rotation queues for CALC_ROT_ST

queue.st={...
    %Barebones queues
    '#Barebones Queues';
    'CS>J>AS>SotR';
    'CS>J>AS>Cons>SotR';
    'CS>J>AS>Cons>HW>SotR';
    'CS>J>AS>HW>Cons>SotR';
    'J>CS>AS>HW>Cons>SotR';
    'CS>AS>J>HW>Cons>SotR';
    'J>AS>CS>HW>Cons>SotR';
    'AS>CS>J>HW>Cons>SotR';
    'AS>J>CS>HW>Cons>SotR';
    'HotR>J>AS>HW>Cons>SotR';
    'AS+>CS>J>AS>HW>Cons>SotR';
    'CS>AS+>J>AS>HW>Cons>SotR';
    'CS>J>AS+>HW>AS>Cons>SotR';
    'CS>J>AS+>HW>Cons>AS>SotR';
    
    
    %talents
    '#Talents';
    'CS>J>ES>AS>HW>Cons>SotR';
    'CS>J>AS+>ES>AS>HW>Cons>SotR';
    'CS>J>AS>ES>HW>Cons>SotR';
    'CS>J>AS>HW>ES>Cons>SotR';
    'CS>J>AS>HW>Cons>ES>SotR';
    'CS>AS+>J>AS>HW>Cons>ES>SotR';
    'AS>CS>J>HW>Cons>ES>SotR';
    'CS>J>HPr>AS>HW>Cons>SotR';
    'CS>J>AS+>HPr>AS>HW>Cons>SotR';
    'CS>J>AS>HPr>HW>Cons>SotR';
    'CS>J>AS>HW>HPr>Cons>SotR';
    'CS>J>AS>HW>Cons>HPr>SotR';
    'CS>AS+>J>AS>HW>Cons>HPr>SotR';
    'AS>CS>J>HW>Cons>HPr>SotR';
    'CS>J>LH>AS>HW>Cons>SotR';
    'CS>J>AS+>LH>AS>HW>Cons>SotR';
    'CS>J>AS>LH>HW>Cons>SotR';
    'CS>J>AS>HW>LH>Cons>SotR';
    'CS>J>AS>HW>Cons>LH>SotR';
    'CS>AS+>J>AS>HW>Cons>LH>SotR';
    'AS>CS>J>HW>Cons>LH>SotR';
    
            
    %Defensive queues
    '#Defensive queues';
    '^WB>CS>J>AS>HW>Cons>SotR';
    '^WB>CS>J>AS>HW>Cons>SotR5';
    '^WB>^SS>CS>J>AS>HW>Cons>SotR';
    '^WB>CS>^SS>J>AS>HW>Cons>SotR';
    '^WB>CS>J>^SS>AS>HW>Cons>SotR';
    '^WB>CS>J>AS+>^SS>AS>HW>Cons>SotR';
    '^WB>CS>J>AS>^SS>HW>Cons>SotR';
    '^WB>CS>J>AS>HW>^SS>Cons>SotR';
    '^WB>CS>J>AS>HW>SS[buffSS<5]>Cons>SotR';
    '^WB>CS>J>AS>HW>Cons>^SS>SotR';
    '^WB>CS>J>AS>HW>Cons>SS>SotR';
    '^WB>CS>J>AS>HW>Cons>SS[buffSS<5]>SotR';
    '^WB>CS>J>AS>HW>SS[buffSS<5]>Cons>SS>SotR';
    '^WB>CS>J>AS>SS[buffSS<5]>HW>Cons>SS>SotR';
    '^WB>CS>J>AS>HW>Cons>ES>SS>SotR';
    '^WB>CS>J>AS>HW>Cons>^SS>ES>SotR';
    '^WB>CS>J>AS>HW>Cons>HPr>SS>SotR';
    '^WB>CS>J>AS>HW>Cons>^SS>HPr>SotR';
    
    %Execute range - no L90
    '#Execute range - no L90';
    'CS>J>AS>HW>HoW>Cons>SotR';
    'CS>J>AS>HoW>HW>Cons>SotR';
    'CS>J>AS+>HoW>AS>HW>Cons>SotR';
    'CS>J>HoW>AS>HW>Cons>SotR';
    'CS>HoW>J>AS>HW>Cons>SotR';
    'HoW>CS>J>AS>HW>Cons>SotR';
    'HoW>CS>AS+>J>AS>HW>Cons>SotR';
    'HoW>CS>AS>J>HW>Cons>SotR';
    'HoW>AS>CS>J>HW>Cons>SotR';
    'HoW>J>AS>CS>HW>Cons>SotR';
    'HoW>J>CS>AS>HW>Cons>SotR';
    
    %Execute range - ES placement
    '#Execute range - ES';
    'CS>J>AS>HW>HoW>Cons>ES>SotR';
    'CS>J>AS>HW>HoW>ES>Cons>SotR';
    'CS>J>AS>HW>ES>HoW>Cons>SotR';
    'CS>J>AS>ES>HW>HoW>Cons>SotR';
    'CS>J>AS+>ES>AS>HW>HoW>Cons>SotR';
    'CS>J>ES>AS>HW>HoW>Cons>SotR';
    'CS>ES>J>AS>HW>HoW>Cons>SotR';
    'ES>CS>J>AS>HW>HoW>Cons>SotR';
    'HoW>CS>J>AS>HW>ES>Cons>SotR';
    'HoW>CS>J>AS>ES>HW>Cons>SotR';
    'HoW>CS>J>AS+>ES>AS>HW>Cons>SotR';
    'HoW>CS>J>ES>AS>HW>Cons>SotR';
    'HoW>CS>ES>J>AS>HW>Cons>SotR';
    'HoW>ES>CS>J>AS>HW>Cons>SotR';
    'ES>HoW>CS>J>AS>HW>Cons>SotR';
    'ES>HoW>AS>CS>J>HW>Cons>SotR';
    'ES>AS>HoW>CS>J>HW>Cons>SotR';
    'AS>ES>HoW>CS>J>HW>Cons>SotR';
    
    %Execute range - other L90 talents
    '#Execute range - LH';
    'CS>J>AS>HW>HoW>Cons>LH>SotR';
    'CS>J>AS>HW>HoW>LH>Cons>SotR';
    'CS>J>AS>HW>LH>HoW>Cons>SotR';
    'CS>J>AS>LH>HW>HoW>Cons>SotR';
    'CS>J>AS+>LH>AS>HW>HoW>Cons>SotR';
    'CS>J>LH>AS>HW>HoW>Cons>SotR';
    'CS>LH>J>AS>HW>HoW>Cons>SotR';
    'LH>CS>J>AS>HW>HoW>Cons>SotR';
    'HoW>CS>J>AS>HW>LH>Cons>SotR';
    'HoW>CS>J>AS>LH>HW>Cons>SotR';
    'HoW>CS>J>AS+>LH>AS>HW>Cons>SotR';
    'HoW>CS>J>LH>AS>HW>Cons>SotR';
    'HoW>CS>LH>J>AS>HW>Cons>SotR';
    'HoW>LH>CS>J>AS>HW>Cons>SotR';
    'LH>HoW>CS>J>AS>HW>Cons>SotR';
    'LH>HoW>CS>AS>J>HW>Cons>SotR';
    'LH>HoW>AS>CS>J>HW>Cons>SotR';
    'LH>AS>HoW>CS>J>HW>Cons>SotR';
    'AS>LH>HoW>CS>J>HW>Cons>SotR';
    
    '#Execute range - HPr';
    'CS>J>AS>HW>HoW>Cons>HPr>SotR';
    'CS>J>AS>HW>HoW>HPr>Cons>SotR';
    'CS>J>AS>HW>HPr>HoW>Cons>SotR';
    'CS>J>AS>HPr>HW>HoW>Cons>SotR';
    'CS>J>AS+>HPr>AS>HW>HoW>Cons>SotR';
    'CS>J>HPr>AS>HW>HoW>Cons>SotR';
    'CS>HPr>J>AS>HW>HoW>Cons>SotR';
    'HPr>CS>J>AS>HW>HoW>Cons>SotR';
    'HoW>CS>J>AS>HW>Cons>HPr>SotR';
    'HoW>CS>J>AS>HW>HPr>Cons>SotR';
    'HoW>CS>J>AS>HPr>HW>Cons>SotR';
    'HoW>CS>J>AS+>HPr>AS>HW>Cons>SotR';
    'HoW>CS>J>HPr>AS>HW>Cons>SotR';
    'HoW>CS>HPr>J>AS>HW>Cons>SotR';
    'HoW>HPr>CS>J>AS>HW>Cons>SotR';
    'HPr>HoW>CS>J>AS>HW>Cons>SotR';
    'HPr>HoW>CS>AS>J>HW>Cons>SotR';
    'HPr>HoW>AS>CS>J>HW>Cons>SotR';
    'HPr>AS>HoW>CS>J>HW>Cons>SotR';
    'AS>HPr>HoW>CS>J>HW>Cons>SotR';

    %WoG
    '#WoG/EF';
    '^WB>CS>J>AS>HW>Cons>WoG';
    '^WB>CS>J>AS>HW>Cons>EF';
    '^WB>CS>J>AS>HW>Cons>^EF>SotR5';
    '^WB>CS>J>AS>HW>Cons>SS>WoG';
    };



queue.aoe={...
    'CS>J>AS>HW>Cons>SotR';
    'HotR>J>AS>HW>Cons>SotR';
    'HotR>J>AS>Cons>HW>SotR';
    'HotR>AS>J>Cons>HW>SotR';
    'HotR>AS>Cons>J>HW>SotR';
    'HotR>Cons>AS>J>HW>SotR';
    'HotR>Cons>AS>HW>J>SotR';
    'Cons>HotR>AS>HW>J>SotR';
    'HotR>Cons>AS>HW>J>LH>SotR';
    'HotR>Cons>AS>HW>LH>J>SotR';
    'HotR>Cons>AS>LH>HW>J>SotR';
    'HotR>Cons>LH>AS>HW>J>SotR';
    'HotR>LH>Cons>AS>HW>J>SotR';
    'LH>HotR>Cons>AS>HW>J>SotR';
%     'HotR>Cons>AS>HW>J>HPr>SotR';
%     'HotR>Cons>AS>HW>HPr>J>SotR';
%     'HotR>Cons>AS>HPr>HW>J>SotR';
%     'HotR>Cons>HPr>AS>HW>J>SotR';
%     'HotR>HPr>Cons>AS>HW>J>SotR';
    'HotR>Cons>AS>HW>J>HPrSC>SotR';
    'HotR>Cons>AS>HW>HPrSC>J>SotR';
    'HotR>Cons>AS>HPrSC>HW>J>SotR';
    'HotR>Cons>HPrSC>AS>HW>J>SotR';
    'HotR>HPrSC>Cons>AS>HW>J>SotR';
    'HPrSC>HotR>Cons>AS>HW>J>SotR';
    };

