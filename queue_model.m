%QUEUE_MODEL contains the rotation queues for CALC_ROT_ST

queue.st={...
    %barebones first
    %default queues 
    'SotR>CS>J>AS>Cons';
    'SotR>CS>AS>J>Cons';
    'SotR>HotR>J>AS>Cons';
    'SotR>J>CS>AS>Cons';
    'SotR>CS>AS+>J>AS>Cons';

    %WoG
    'WoG>CS>J>AS';
    'WoG>SotR>CS>J>AS';
    'WoG>CS>AS+>J>AS';
    'WoG>CS>J>AS>Cons>HW';
    'WoG>SotR>CS>AS+>J>AS';
    'WoG>SotR>CS>J>AS>Cons>HW';
    'WoG>SotR>CS>AS+>J>AS>Cons>HW';
    };



queue.aoe={...
    'SotR>CS>AS>J>Cons';
    'SotR>HotR>AS>J>Cons';
    'SotR>HotR>Cons>AS>J';
    };