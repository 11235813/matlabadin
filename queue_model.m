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
%     'SotR>AS+>CS>J>AS';
    'SotR>AS+>CS>AS>J';
    'SotR>AS[buffGC<2][buffGC>0]>CS>AS>J';
    %fishing
%     'sdAS>sdJ>SotR>CS>AS>J';
%     'sdAS>SotR>CS>AS>J';
    %complete queues
    'SotR>CS>AS>J>HW';
    'SotR>CS>AS>J>Cons>HW';
    'SotR>AS+>CS>AS>J>Cons>HW';
    %fishing
    'sdAS>sdJ>SotR>CS>AS>J>Cons>HW';
    %Inq variants 
    'Inq>CS>AS>J';
    'Inq>HotR>AS>J';
    'Inq>AS+>CS>AS>J';
%     'iInq>SotR>CS>AS>J';
    'Inq[buffInq<2]>SotR>CS>AS>J';
%     'Inq[buffInq<4]>SotR>CS>AS>J';
%     'iInq>SotR2>CS>AS>J';
    'ISotR>Inq>CS>AS>J';
    'SDSotR>Inq>CS>AS>J';
    'SDSotR>ISotR>Inq>CS>AS>J';
%     'SDSotR>ISotR>Inq>AS[buffGC<2][buffGC>0]>CS>AS>J';
    'ISDSotR>Inq>CS>AS>J';
    'Inq>CS>AS>J>Cons>HW';
    'Inq>HotR>AS>J>Cons>HW';
    'ISotR>Inq>CS>AS>J>Cons>HW';
    'SDSotR>Inq>CS>AS>J>Cons>HW';
    'SDSotR>ISotR>Inq>CS>AS>J>Cons>HW';
%     'SDSotR>ISotR>Inq>AS[buffGC<2][buffGC>0]>CS>AS>J>Cons>HW';
%     'SDSotR>ISotR>Inq>CS>AS>J>ICons>HW';
    'ISDSotR>Inq>CS>AS>J>Cons>HW';
    %WoG
    'WoG>CS>AS>J';
    'WoG>SotR>CS>AS>J';
    'WoG>SotR[cdWoG>10]>CS>AS>J';
%     'WoG>SotR[cdWoG>10]>SotR2[cdWoG>10]>CS>AS>J';
%     'WoG>SotR[cdWoG>10]>SotR2[cdWoG<10][cdWoG>5]>CS>AS>J';
%     'WoG>SotR[cdWoG>15]>SotR2[cdWoG<15][cdWoG>10]>CS>AS>J';
    'WoG>Inq>CS>AS>J';
%     'WoG>Inq2[cdWoG>10]>CS>AS>J';
    'WoG>CS>AS>J>Cons>HW';
    'WoG>SotR>CS>AS>J>Cons>HW';
    'WoG>SotR2>CS>AS>J>Cons>HW';
    'WoG>Inq>CS>AS>J>Cons>HW';
%     'WoG>Inq>HotR>AS>J>Cons>HW';
    'WoG>Inq>AS+>CS>AS>J>Cons>HW';
    'WoG>ISotR>Inq>CS>AS>J>Cons>HW';
%     'WoG>iInq>SotR>CS>AS>J>Cons>HW';
    'WoG>SDSotR>ISotR>Inq>CS>AS>J>Cons>HW';
    %HoW queues
    'SotR>CS>AS>J>HoW';                
	'SotR>CS>AS>HoW>J';
    'SotR>CS>AS+>HoW>AS>J';
    'SotR>CS>HoW>AS>J';
    'SotR>HoW>CS>AS>J';
    'HoW>SotR>CS>AS>J';
%     'SotR>CS>AS>J>HoW>Cons>HW';
    'SotR>CS>AS>HoW>J>Cons>HW';
%     'SotR>CS>HoW>AS>J>Cons>HW';
%     'SotR>HoW>CS>AS>J>Cons>HW';
%     'HoW>SotR>CS>AS>J>Cons>HW';
%     'ISotR>SDSotR>Inq>CS>AS>J>HoW>Cons>HW';
    'ISotR>SDSotR>Inq>CS>AS>HoW>J>Cons>HW';
%     'ISotR>SDSotR>Inq>CS>HoW>AS>J>Cons>HW';
%     'ISotR>SDSotR>Inq>HoW>CS>AS>J>Cons>HW';
%     'ISotR>SDSotR>HoW>Inq>CS>AS>J>Cons>HW';
%     'HoW>ISotR>SDSotR>Inq>CS>AS>J>Cons>HW';
%     'WoG>SotR>CS>AS>J>HoW>Cons>HW';
    'WoG>SotR>CS>AS>HoW>J>Cons>HW';
%     'WoG>SotR>CS>HoW>AS>J>Cons>HW';
%     'WoG>SotR>HoW>CS>AS>J>Cons>HW';
%     'WoG>HoW>SotR>CS>AS>J>Cons>HW';
    };



queue.aoe={'Inq>HotR>AS>Cons>HW>J';'iInq>SotR>HotR>AS>Cons>HW>J'};