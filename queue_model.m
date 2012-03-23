%QUEUE_MODEL contains the rotation queues for CALC_ROT_ST

queue.st={...
    %barebones first
    %default queues 
    'SotR5>CS>J>AS>Cons>HW';
    'SotR5>CS>AS>J>Cons>HW';
    'SotR5>HotR>J>AS>Cons>HW';
    'SotR5>J>CS>AS>Cons>HW';
    'SotR5>CS>AS+>J>AS>Cons>HW';
    
    %Defensive queues
    '^WB>^SS5>SotR5>CS>J>AS>Cons>HW';

    %WoG
    'WoG5>CS>J>AS>HW';
    'WoG5>CS>J>AS>Cons>HW';
    'WoG5>CS>AS+>J>AS>Cons>HW';
    };



queue.aoe={...
    'SotR>CS>AS>J>Cons';
    'SotR>HotR>AS>J>Cons';
    'SotR>HotR>Cons>AS>J';
    };