%QUEUE_MODEL contains the rotation queues for CALC_ROT_ST

queue.st={...
    %barebones first
    'CS>J>AS>Cons>HW>SotR';
    'J>CS>AS>Cons>HW>SotR';
    'CS>AS>J>Cons>HW>SotR';
    'J>AS>CS>Cons>HW>SotR';
    'HotR>J>AS>Cons>HW>SotR';
    'CS>AS+>J>AS>Cons>HW>SotR';
    'CS>J>AS>HW>Cons>SotR';
    
        
    %Defensive queues
    '^WB>CS>J>AS>Cons>HW>SotR';
    '^WB>CS>J>AS>Cons>HW>SotR5';
    '^WB>^SS>CS>J>AS>Cons>HW>SotR';
    '^WB>CS>^SS>J>AS>Cons>HW>SotR';
    '^WB>CS>J>^SS>AS>Cons>HW>SotR';
    '^WB>CS>J>AS>^SS>Cons>HW>SotR';
    '^WB>CS>J>AS>Cons>^SS>HW>SotR';
    '^WB>CS>J>AS>Cons>HW>^SS>SotR';

    %WoG
    '^WB>CS>J>AS>Cons>HW>WoG5';
    '^WB>CS>J>AS>Cons>HW>EF';
    '^WB>CS>J>AS>Cons>HW>^EF>SotR5';
    '^WB>CS>J>AS>^SS>Cons>HW>WoG';
    };



queue.aoe={...
    'SotR>CS>AS>J>Cons';
    'SotR>HotR>AS>J>Cons';
    'SotR>HotR>Cons>AS>J';
    };