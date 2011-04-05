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
buff.BoK=((mode==0&&(isempty(item)||isempty(regexpi(item,'BoK'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'BoK'))))));
%agility&strength : Strength of Earth / Horn of Winter / Battle Shout / Roar of Courage
buff.SoE=((mode==0&&(isempty(item)||isempty(regexpi(item,'SoE'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'SoE'))))));
%stamina : Power word Fortitude / Commanding Shout / Blood Pact / Quiraji Fortitude
buff.PWF=((mode==0&&(isempty(item)||isempty(regexpi(item,'PWF'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'PWF'))))));
%mana : Arcane Brilliance / Fel Intelligence
buff.FelInt=((mode==0&&(isempty(item)||isempty(regexpi(item,'FelInt'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'FelInt'))))));
%multiplicative AP : Unleashed Rage / Blessing of Might / Trueshot Aura / Abomination's Might
buff.UnRage=((mode==0&&(isempty(item)||isempty(regexpi(item,'UnRage'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'UnRage'))))));
%lesser multiplicative SP : Flametongue Totem / Arcane Brilliance
buff.FMT=((mode==0&&(isempty(item)||isempty(regexpi(item,'FMT'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'FMT'))))));
%greater multiplicative SP : Totemic Wrath / Demonic Pact
buff.ToWra=((mode==0&&(isempty(item)||isempty(regexpi(item,'ToWra'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'ToWra'))))));
%global damage dealt : Sanctified Retribution / Ferocious Inspiration / Arcane Tactics
buff.ArcTac=((mode==0&&(isempty(item)||isempty(regexpi(item,'ArcTac'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'ArcTac'))))));
%global crit : Leader of the Pack / Rampage / Moonkin Aura / Elemental Oath / Honor Among Thieves
buff.LotP=((mode==0&&(isempty(item)||isempty(regexpi(item,'LotP'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'LotP'))))));
%physical attack speed : Windfury Totem / Improved Icy Talons / Hunting Party
buff.WFury=((mode==0&&(isempty(item)||isempty(regexpi(item,'WFury'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'WFury'))))));
%spell haste : Wrath of Air Totem / Improved Moonkin Form / Mind Quickening
buff.WoA=((mode==0&&(isempty(item)||isempty(regexpi(item,'WoA'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'WoA'))))));
%active haste : Bloodlust / Heroism / Time Warp
buff.BLust=((mode==0&&(isempty(item)||isempty(regexpi(item,'BLust'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'BLust'))))));
%armor : Devotion Aura / Stoneskin Totem
buff.Devo=((mode==0&&(isempty(item)||isempty(regexpi(item,'Devo')))) ...
    ||mode==2||mode==3||mode==4);
%Thorns
buff.Thorns=((mode==0&&(isempty(item)||isempty(regexpi(item,'Thorns'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'Thorns'))))));
%Retribution Aura
buff.RetA=((mode==0&&(isempty(item)||isempty(regexpi(item,'RetA'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'RetA'))))));
%Avenging Wrath
buff.AWra=((mode==0&&(isempty(item)||isempty(regexpi(item,'AWra')))) ...
    ||mode==2||mode==3||mode==4);
%Replenishment : Judgements of the Wise / Hunting Party / Improved Soul Leech
buff.JotW=((mode==0&&(isempty(item)||isempty(regexpi(item,'JotW')))) ...
    ||mode==2||mode==3||mode==4);
%Divine Plea
buff.DivPlea=((mode==0&&(isempty(item)||isempty(regexpi(item,'DivPle')))) ...
    ||mode==2||mode==3||mode==4);
%Righteous Fury
buff.RFury=((mode==0&&(isempty(item)||isempty(regexpi(item,'RFury')))) ...
    ||mode==2||mode==3||mode==4);
%Focus Magic (disabled by default, even in exhaustive mode)
buff.Focus=0;

%% Debuffs
%physical damage taken : Savage Combat / Blood Frenzy / Brittle Bones
buff.SavCom=((mode==0&&(isempty(item)||isempty(regexpi(item,'SavCom'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'SavCom'))))));
%bleed damage taken : Mangle / Trauma / Hemorrhage
buff.Hemo=((mode==0&&(isempty(item)||isempty(regexpi(item,'Hemo'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'Hemo'))))));
%spell damage taken : Ebon Plaguebringer / Earth and Moon / Curse of the Elements / Master Poisoner
buff.CoE=((mode==0&&(isempty(item)||isempty(regexpi(item,'CoE'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'CoE'))))));
%spell crit : Critical Mass / Improved Shadowbolt
buff.ISB=((mode==0&&(isempty(item)||isempty(regexpi(item,'ISB'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'ISB'))))));
%multiplicative armor : Sunder Armor / Expose Armor / Faerie Fire / Scorpid Venom
buff.Sund=((mode==0&&(isempty(item)||isempty(regexpi(item,'Sund'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'Sund'))))));
%multiplicative armor : Shattering Throw
buff.SThrow=((mode==0&&(isempty(item)||isempty(regexpi(item,'SThrow'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'SThrow'))))));

%% Player debuffs
%Chill_up=0; %PLACEHOLDER

%% Consumables
if (mode==1||flask==0) buff.flask=equip(1,'s'); else buff.flask=equip(flask,'s'); end;
if (mode==1||ischar(flask)||flask~=0||belixir==0) buff.belixir=equip(1,'s'); else buff.belixir=equip(belixir,'s'); end;
if (mode==1||ischar(flask)||flask~=0||gelixir==0) buff.gelixir=equip(1,'s'); else buff.gelixir=equip(gelixir,'s'); end;
if (mode==1||potion==0) buff.potion=equip(1,'s'); else buff.potion=equip(potion,'s'); end;
if (mode==1||food==0) buff.food=equip(1,'s'); else buff.food=equip(food,'s'); end;
end