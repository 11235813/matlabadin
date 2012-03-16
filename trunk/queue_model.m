%QUEUE_MODEL contains the rotation queues for CALC_ROT_ST

queue.st={...
    %barebones first
    %default queues 
    'SotR5>CS>J>AS>Cons';
    'SotR5>CS>AS>J>Cons';
    'SotR5>HotR>J>AS>Cons';
    'SotR5>J>CS>AS>Cons';
    'SotR5>CS>AS+>J>AS>Cons';
    
    %Defensive queues
    '^WB>^SS5>SotR5>CS>J>AS>Cons';

    %WoG
    'WoG5>CS>J>AS';
    'WoG5>CS>J>AS>Cons';
    'WoG5>CS>AS+>J>AS';
    };



queue.aoe={...
    'SotR>CS>AS>J>Cons';
    'SotR>HotR>AS>J>Cons';
    'SotR>HotR>Cons>AS>J';
    };