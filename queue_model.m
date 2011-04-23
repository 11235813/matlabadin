%QUEUE_MODEL contains the rotation queues for CALC_ROT_ST

queue.st={...
    %barebones first
    %default queues 
    'SotR>CS>AS>J';
    'SotR>HotR>AS>J';
    'SotR>CS>J>AS';
    'SotR>AS>CS>J';
    'AS>SotR>CS>J';
    'SotR>CS>AS+>J>AS';
    'SotR>AS+>CS>J>AS';
    %fishing
    'sdAS>sdJ>SotR>CS>AS>J';
    'sdAS>SotR>CS>AS>J';
    %complete queues
    'SotR>CS>AS>J>HW';
    'SotR>CS>AS>J>Cons>HW';
    'SotR>AS+>CS>AS>J>Cons>HW';
    %fishing
    'sdAS>sdJ>SotR>AS+>CS>AS>J>Cons>HW';
    %Inq variants 
    'Inq>CS>AS>J';
    'Inq>HotR>AS>J';
    'iInq>SotR>CS>AS>J';
    'ISotR>Inq>CS>AS>J';
    'SDSotR>ISotR>Inq>CS>AS>J';
    'ISotR>SDSotR>Inq>CS>AS>J';
    'ISDSotR>Inq>CS>AS>J';
    'Inq>CS>AS>J>Cons>HW';
    'Inq>HotR>AS>J>Cons>HW';
    'ISotR>Inq>CS>AS>J>Cons>HW';
    'SDSotR>ISotR>Inq>CS>AS>J>Cons>HW';
    'SDSotR>ISotR>Inq>CS>AS>J>ICons>HW';
    'SDSotR>Inq>CS>AS>J>Cons>HW';
    'ISDSotR>Inq>CS>AS>J>Cons>HW';
    %WoG
    'WoG>SotR>CS>AS>J>Cons>HW';
    'WoG>SotR>HotR>AS>J>Cons>HW';
    'WoG>Inq>CS>AS>J>Cons>HW';
    'WoG>Inq>HotR>AS>J>Cons>HW';
    'WoG>Inq>AS+>CS>AS>J>Cons>HW';
    'WoG>ISotR>Inq>CS>AS>J>Cons>HW';
    'WoG>iInq>SotR>CS>AS>J>Cons>HW';
    %HoW queues
    'SotR>CS>AS>J>HoW';                
	'SotR>CS>AS>HoW>J';
    'SotR>CS>HoW>AS>J';
    'SotR>HoW>CS>AS>J';
    'HoW>SotR>CS>AS>J';
    'SotR>CS>AS+>HoW>AS>J';
    'SotR>CS>HoW>AS>J>Cons>HW';
    'SotR>HoW>CS>AS>J>Cons>HW';
    'HoW>SotR>CS>AS>J>Cons>HW';
    'ISotR>Inq>CS>HoW>AS>J>Cons>HW';
    'HoW>ISotR>Inq>CS>AS>J>Cons>HW';
    'WoG>HoW>SotR>CS>AS>J>Cons>HW';
    'WoG>SotR>HoW>CS>AS>J>Cons>HW';
    };



queue.aoe={'Inq>HotR>AS>Cons>HW>J';'iInq>SotR>HotR>AS>Cons>HW>J'}