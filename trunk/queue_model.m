%QUEUE_MODEL contains the rotation queues for CALC_ROT_ST

queue.st={...
    %barebones first
    'CS>J>AS>SotR';
    'CS>J>AS>Cons>SotR';
    'CS>J>AS>Cons>HW>SotR';
    'J>CS>AS>Cons>HW>SotR';
    'CS>AS>J>Cons>HW>SotR';
    'J>AS>CS>Cons>HW>SotR';
    'HotR>J>AS>Cons>HW>SotR';
    'CS>AS+>J>AS>Cons>HW>SotR';
    'CS>J>AS>HW>Cons>SotR';
    'CS>J>AS+>Cons>AS>HW>SotR';
    'CS>J>Cons>AS>HW>SotR';
    'CS>Cons>J>AS>HW>SotR';
    'Cons>CS>J>AS>HW>SotR';
    
    %talents
    'CS>J>AS>ES>Cons>HW>SotR';
    'CS>J>AS>Cons>ES>HW>SotR';
    'CS>J>AS+>Cons>AS>ES>HW>SotR';
    'CS>J>AS+>Cons>ES>AS>HW>SotR';
    'CS>J>Cons>AS+>ES>AS>HW>SotR';
    'CS>J>Cons>ES>AS>HW>SotR';
    'CS>J>AS>HPr>Cons>HW>SotR';
    'CS>J>AS>Cons>HPr>HW>SotR';
    'CS>J>AS+>Cons>HPr>AS>HW>SotR';
    'CS>J>AS+>Cons>AS>HPr>HW>SotR';
    'CS>J>AS>LH>Cons>HW>SotR';
    'CS>J>AS>Cons>LH>HW>SotR';
    'CS>J>AS+>Cons>LH>AS>HW>SotR';
    'CS>J>AS+>Cons>AS>LH>HW>SotR';
            
    %Defensive queues
    '^WB>CS>J>AS>Cons>HW>SotR';
    '^WB>CS>J>AS>Cons>HW>SotR5';
    '^WB>^SS>CS>J>AS>Cons>HW>SotR';
    '^WB>CS>^SS>J>AS>Cons>HW>SotR';
    '^WB>CS>J>^SS>AS>Cons>HW>SotR';
    '^WB>CS>J>AS+>^SS>AS>Cons>HW>SotR';
    '^WB>CS>J>AS>^SS>Cons>HW>SotR';
    '^WB>CS>J>AS>Cons>^SS>HW>SotR';
    '^WB>CS>J>AS>Cons>HW>^SS>SotR';
    '^WB>CS>J>AS>Cons>SS[buffSS<5]>HW>SotR';
    
    %Execute range
    'CS>J>AS>Cons>HoW>SotR';
    'CS>J>AS>HoW>Cons>HW>SotR';
    'CS>J>AS+>HoW>AS>Cons>HW>SotR';
    'CS>J>HoW>AS>Cons>HW>SotR';
    'CS>HoW>J>AS>Cons>HW>SotR';
    'HoW>CS>J>AS>Cons>HW>SotR';
    'HoW>CS>J>AS>Cons>ES>HW>SotR';
    'HoW>CS>J>AS>Cons>HPr>HW>SotR';
    'HoW>CS>J>AS>Cons>LH>HW>SotR';

    %WoG
    '^WB>CS>J>AS>Cons>HW>WoG';
    '^WB>CS>J>AS>Cons>HW>EF';
    '^WB>CS>J>AS>Cons>HW>^EF>SotR5';
    '^WB>CS>J>AS>^SS>Cons>HW>WoG';
    };



queue.aoe={...
    'SotR>CS>AS>J>Cons';
    'SotR>HotR>AS>J>Cons';
    'SotR>HotR>Cons>AS>J';
    };