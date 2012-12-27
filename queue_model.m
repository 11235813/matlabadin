%QUEUE_MODEL contains the rotation queues for CALC_ROT_ST

queue.st={...
    %barebones first
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
    
    %Execute range
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
    'HoW>CS>J>AS>HW>ES>Cons>SotR';
    'HoW>CS>J>AS>HW>HPr>Cons>SotR';
    'HoW>CS>J>AS>HW>LH>Cons>SotR';
    'HoW>AS>CS>J>HW>ES>Cons>SotR';
    'HoW>AS>CS>J>HW>HPr>Cons>SotR';
    'HoW>AS>CS>J>HW>LH>Cons>SotR';

    %WoG
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
    'HotR>Cons>AS>HW>J>HPrAlt>SotR';
    'HotR>Cons>AS>HW>HPr>J>SotR';
    'HotR>Cons>AS>HPr>HW>J>SotR';
    'HotR>Cons>HPr>AS>HW>J>SotR';
    'HotR>HPr>Cons>AS>HW>J>SotR';
    };

