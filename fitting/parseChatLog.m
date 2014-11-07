function [ set ] = parseChatLog( filename , tag )
%PARSECHATLOG parses a combat log to import data from the statslog addon

    fid = fopen(filename, 'rt');
	i = 1;
%     str=0;agi=0;postDodge=0;postParry=0;dodgeRating=0;preDodge=0;
%     parryRating=0;preParry=0;mastery=0;preMastery=0;postBlock=0;
%     pvpPowerRating=0;pvpPower=0;
    
	while not(feof(fid))
		txt = fgetl(fid);
		k=strfind(txt,tag);
        if ~isempty(k)
            [m s e]=regexp(txt(k:length(txt)),'\s(\d+\.?\d*)','match');
            if ~isempty(m)
                for j=1:11
                    data(i,j)=str2num(char(m(j)));
                end
                i = i + 1;
            end
        end
    end
    fclose (fid);

    set.str=data(:,1);
    set.agi=data(:,2);
    set.postDodge=data(:,3);
    set.postParry=data(:,4);
    set.dodgeRating=data(:,5);
    set.preDodge=data(:,6);
    set.parryRating=data(:,7);
    set.preParry=data(:,8);
    set.mastery=data(:,9);
    set.preMastery=data(:,10);
    set.postBlock=data(:,11);
%     set.pvpPowerRating=data(:,12);
%     set.pvpPower=data(:,13);

end

