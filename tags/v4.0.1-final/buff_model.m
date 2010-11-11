function [buff] =  buff_model(varargin)
%% Buffs/Debuffs
%TODO insert comment later on
%Inputs [default value] :
%mode - master switch; 0-custom exclusions, 1-none, 2-self, 3-exhaustive, 4-custom inclusions [3]
%item - inclusions/exclusions; individual entries are separated by white spaces ['']
%flask - flask option; name or SID (0 if none) [79469,'Flask of Steelskin']
%belixir - battle elixir option; name or SID (0 if none) [0]
%gelixir - guardian elixir option; name or SID (0 if none) [0]
%potion - potion option; name or SID (0 if none) [79475,'Earthen Potion']
%food - food option; name or SID (0 if none) [87584,'Beer-Basted Crocolisk']
%Note on custom modes : mode==0 is basically a subset of mode==3, where the
%item argument configures the exclusions. Likewise, mode==4 is a
%generalization of mode==2, where the item argument configures the
%inclusions. Examples :
%buff_model('mode',0) = buff_model('mode',3) = buff_model()
%buff_model('mode',0,'item','bok thORnS') enables all mode==3 environmental buffs, sans BoK and Thorns.
%buff_model('mode',4) = buff_model('mode',2)
%buff_model('mode',4,'item','BOK') enables all mode==2 buffs, plus BoK.
%The item inputs are case-insensitive.

%% Input handling
%populate all entries with empty arrays
mode=[];item=[];flask=[];belixir=[];gelixir=[];potion=[];food=[];
%start filling entries with inputs
if nargin>1
    for i=1:2:length(varargin)
        name=varargin{i};         
        value=varargin{i+1};
        switch name
            case 'mode'
                mode=value;
            case 'item'
                item=value;
            case 'flask'
                flask=value;
            case 'belixir'
                belixir=value;
            case 'gelixir'
                gelixir=value;
            case 'potion'
                potion=value;
            case 'food'
                food=value;
        end
    end
end
%default values of the input arguments
if isempty(mode)==1 mode=3; end;
if isempty(item)==1 item=''; end;
if isempty(flask)==1 flask=79469; end;
if isempty(belixir)==1 belixir=0; end;
if isempty(gelixir)==1 gelixir=0; end;
if isempty(potion)==1 potion=79475; end;
if isempty(food)==1 food=87584; end;


%% Buffs
%5% stats, resistance : Blessing of Kings / Mark of the Wild / Embrace of the Shale Spider
buff.BoK=((mode==0&&(isempty(item)||max(strcmpi('BoK',strread(item,'%s')))==0)) ...
    ||mode==2||mode==3||mode==4);
%agility&strength : Strength of Earth / Horn of Winter / Battle Shout / Roar of Courage
buff.SoE=((mode==0&&(isempty(item)||max(strcmpi('SoE',strread(item,'%s')))==0))||mode==3 ...
    ||(mode==4&&((isempty(item)==0)&&max(strcmpi('SoE',strread(item,'%s')))==1)));
%stamina : Power word Fortitude / Commanding Shout / Blood Pact / Quiraji Fortitude
buff.PWF=((mode==0&&(isempty(item)||max(strcmpi('PWF',strread(item,'%s')))==0))||mode==3 ...
    ||(mode==4&&((isempty(item)==0)&&max(strcmpi('PWF',strread(item,'%s')))==1)));
%mana : Arcane Brilliance / Fel Intelligence
buff.FelInt=((mode==0&&(isempty(item)||max(strcmpi('FelInt',strread(item,'%s')))==0))||mode==3 ...
    ||(mode==4&&((isempty(item)==0)&&max(strcmpi('FelInt',strread(item,'%s')))==1)));
%multiplicative AP : Unleashed Rage / Blessing of Might / Trueshot Aura / Abomination's Might
buff.UnRage=((mode==0&&(isempty(item)||max(strcmpi('UnRage',strread(item,'%s')))==0))||mode==3 ...
    ||(mode==4&&((isempty(item)==0)&&max(strcmpi('UnRage',strread(item,'%s')))==1)));
%lesser multiplicative SP : Flametongue Totem / Arcane Brilliance
buff.FMT=((mode==0&&(isempty(item)||max(strcmpi('FMT',strread(item,'%s')))==0))||mode==3 ...
    ||(mode==4&&((isempty(item)==0)&&max(strcmpi('FMT',strread(item,'%s')))==1)));
%greater multiplicative SP : Totemic Wrath / Demonic Pact
buff.TW=((mode==0&&(isempty(item)||max(strcmpi('TW',strread(item,'%s')))==0))||mode==3 ...
    ||(mode==4&&((isempty(item)==0)&&max(strcmpi('TW',strread(item,'%s')))==1)));
%global damage dealt : Sanctified Retribution / Ferocious Inspiration / Arcane Tactics
buff.ArcTac=((mode==0&&(isempty(item)||max(strcmpi('ArcTac',strread(item,'%s')))==0))||mode==3 ...
    ||(mode==4&&((isempty(item)==0)&&max(strcmpi('ArcTac',strread(item,'%s')))==1)));
%global crit : Leader of the Pack / Rampage / Moonkin Aura / Elemental Oath / Honor Among Thieves
buff.LotP=((mode==0&&(isempty(item)||max(strcmpi('LotP',strread(item,'%s')))==0))||mode==3 ...
    ||(mode==4&&((isempty(item)==0)&&max(strcmpi('LotP',strread(item,'%s')))==1)));
%physical attack speed : Windfury Totem / Improved Icy Talons / Hunting Party
buff.WF=((mode==0&&(isempty(item)||max(strcmpi('WF',strread(item,'%s')))==0))||mode==3 ...
    ||(mode==4&&((isempty(item)==0)&&max(strcmpi('WF',strread(item,'%s')))==1)));
%spell haste : Wrath of Air Totem / Improved Moonkin Form / Mind Quickening
buff.WoA=((mode==0&&(isempty(item)||max(strcmpi('WoA',strread(item,'%s')))==0))||mode==3 ...
    ||(mode==4&&((isempty(item)==0)&&max(strcmpi('WoA',strread(item,'%s')))==1)));
%active haste : Bloodlust / Heroism / Time Warp
buff.BL=((mode==0&&(isempty(item)||max(strcmpi('BL',strread(item,'%s')))==0))||mode==3 ...
    ||(mode==4&&((isempty(item)==0)&&max(strcmpi('BL',strread(item,'%s')))==1)));
%armor : Devotion Aura / Stoneskin Totem
buff.Devo=((mode==0&&(isempty(item)||max(strcmpi('Devo',strread(item,'%s')))==0)) ...
    ||mode==2||mode==3||mode==4);
%Thorns
buff.Thorns=((mode==0&&(isempty(item)||max(strcmpi('Thorns',(strread(item,'%s'))))==0))||mode==3 ...
    ||(mode==4&&((isempty(item)==0)&&max(strcmpi('Thorns',strread(item,'%s')))==1)));
%Retribution Aura
buff.RA=((mode==0&&(isempty(item)||max(strcmpi('RA',strread(item,'%s')))==0))||mode==3 ...
    ||(mode==4&&((isempty(item)==0)&&max(strcmpi('RA',strread(item,'%s')))==1)));
%Avenging Wrath
buff.AW=((mode==0&&(isempty(item)||max(strcmpi('AW',strread(item,'%s')))==0)) ...
    ||mode==2||mode==3||mode==4);
%Replenishment : Judgements of the Wise / Hunting Party / Improved Soul Leech
buff.JotW=((mode==0&&(isempty(item)||max(strcmpi('JotW',strread(item,'%s')))==0)) ...
    ||mode==2||mode==3||mode==4);
%Divine Plea
buff.DivPlea=((mode==0&&(isempty(item)||max(strcmpi('DivPlea',strread(item,'%s')))==0)) ...
    ||mode==2||mode==3||mode==4);
%Righteous Fury
buff.RF=((mode==0&&(isempty(item)||max(strcmpi('RF',strread(item,'%s')))==0)) ...
    ||mode==2||mode==3||mode==4);
%Focus Magic (disabled by default, even in exhaustive mode)
buff.Focus=0;

%% Debuffs
%physical damage taken : Savage Combat / Blood Frenzy / Brittle Bones
buff.SavCom=((mode==0&&(isempty(item)||max(strcmpi('SavCom',strread(item,'%s')))==0))||mode==3 ...
    ||(mode==4&&((isempty(item)==0)&&max(strcmpi('SavCom',strread(item,'%s')))==1)));
%bleed damage taken : Mangle / Trauma / Hemorrhage
buff.Hemo=((mode==0&&(isempty(item)||max(strcmpi('Hemo',strread(item,'%s')))==0))||mode==3 ...
    ||(mode==4&&((isempty(item)==0)&&max(strcmpi('Hemo',strread(item,'%s')))==1)));
%spell damage taken : Ebon Plaguebringer / Earth and Moon / Curse of the Elements / Master Poisoner
buff.CoE=((mode==0&&(isempty(item)||max(strcmpi('CoE',strread(item,'%s')))==0))||mode==3 ...
    ||(mode==4&&((isempty(item)==0)&&max(strcmpi('CoE',strread(item,'%s')))==1)));
%spell crit : Critical Mass / Improved Shadowbolt
buff.ISB=((mode==0&&(isempty(item)||max(strcmpi('ISB',strread(item,'%s')))==0))||mode==3 ...
    ||(mode==4&&((isempty(item)==0)&&max(strcmpi('ISB',strread(item,'%s')))==1)));
%multiplicative armor : Sunder Armor / Expose Armor / Faerie Fire / Scorpid Venom
buff.Sund=((mode==0&&(isempty(item)||max(strcmpi('Sund',strread(item,'%s')))==0))||mode==3 ...
    ||(mode==4&&((isempty(item)==0)&&max(strcmpi('Sund',strread(item,'%s')))==1)));
%multiplicative armor : Shattering Throw
buff.ST=((mode==0&&(isempty(item)||max(strcmpi('ST',strread(item,'%s')))==0))||mode==3 ...
    ||(mode==4&&((isempty(item)==0)&&max(strcmpi('ST',strread(item,'%s')))==1)));

%% Player debuffs
%Chill_up=0; %PLACEHOLDER

%% Consumables
if (mode==1||flask==0) buff.flask=equip(1,'s'); else buff.flask=equip(flask,'s'); end;
if (mode==1||ischar(flask)||flask~=0||belixir==0) buff.belixir=equip(1,'s'); else buff.belixir=equip(belixir,'s'); end;
if (mode==1||ischar(flask)||flask~=0||gelixir==0) buff.gelixir=equip(1,'s'); else buff.gelixir=equip(gelixir,'s'); end;
if (mode==1||potion==0) buff.potion=equip(1,'s'); else buff.potion=equip(potion,'s'); end;
if (mode==1||food==0) buff.food=equip(1,'s'); else buff.food=equip(food,'s'); end;
end