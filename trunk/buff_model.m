function [buff] =  buff_model(varargin)
%% Buffs/Debuffs
%TODO insert comment later on
%Inputs [default value] :
%mode - master switch; 0-custom, 1-none, 2-self, 3-exhaustive [3]
%excl - exclusions; individual entries are separated by white spaces ['']
%flask - flask option; name or SID (0 if none) [79469,'Flask of Steelskin']
%belixir - battle elixir option; name or SID (0 if none) [0]
%gelixir - guardian elixir option; name or SID (0 if none) [0]
%potion - potion option; name or SID (0 if none) [79475,'Earthen Potion']
%food - food option; name or SID (0 if none) [87584,'Beer-Basted Crocolisk']
%Note on custom mode : mode==0 is basically a subset of mode==3, where the
%excl argument configures the missing entries. Examples :
%buff_model('mode',0) = buff_model('mode',3) = buff_model()
%buff_model('mode',0,'excl','bok thORnS') enables all mode==3 environmental buffs,
%sans BoK and Thorns. The excl inputs are case-insensitive.

%% Input handling
%populate all entries with empty arrays
mode=[];excl=[];flask=[];belixir=[];gelixir=[];potion=[];food=[];
%start filling entries with inputs
if nargin>1
    for i=1:2:length(varargin)
        name=varargin{i};         
        value=varargin{i+1};
        switch name
            case 'mode'
                mode=value;
            case 'excl'
                excl=value;
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
if isempty(excl)==1 excl=''; end;
if isempty(flask)==1 flask=79469; end;
if isempty(belixir)==1 belixir=0; end;
if isempty(gelixir)==1 gelixir=0; end;
if isempty(potion)==1 potion=79475; end;
if isempty(food)==1 food=87584; end;


%% Buffs
%5% stats, resistance : Blessing of Kings / Mark of the Wild
buff.BoK=((mode==0&&(isempty(excl)||max(strcmpi('BoK',strread(excl,'%s')))==0))||mode==2||mode==3);
%agility&strength : Strength of Earth / Horn of Winter / Battle Shout
buff.SoE=((mode==0&&(isempty(excl)||max(strcmpi('SoE',strread(excl,'%s')))==0))||mode==3);
%stamina : Power word Fortitude / Commanding Shout
buff.PWF=((mode==0&&(isempty(excl)||max(strcmpi('PWF',strread(excl,'%s')))==0))||mode==3);
%mana : Arcane Intellect / Fel Intelligence
buff.ArcInt=((mode==0&&(isempty(excl)||max(strcmpi('ArcInt',strread(excl,'%s')))==0))||mode==3);
%multiplicative AP : Unleashed Rage / Blessing of Might / Trueshot Aura / Abomination's Might
buff.UnRage=((mode==0&&(isempty(excl)||max(strcmpi('UnRage',strread(excl,'%s')))==0))||mode==3);
%lesser multiplicative SP : Flametongue Totem
buff.FMT=((mode==0&&(isempty(excl)||max(strcmpi('FMT',strread(excl,'%s')))==0))||mode==3);
%greater multiplicative SP : Totem of Wrath / Demonic Pact
buff.ToW=((mode==0&&(isempty(excl)||max(strcmpi('ToW',strread(excl,'%s')))==0))||mode==3);
%global hit : Heroic Presence (Draenei) /TODO check it up later
buff.HePr=((mode==0&&(isempty(excl)||max(strcmpi('HePr',strread(excl,'%s')))==0))||mode==3);
%global damage dealt : Communion / Ferocious Inspiration / Arcane Tactics
buff.ArcTac=((mode==0&&(isempty(excl)||max(strcmpi('ArcTac',strread(excl,'%s')))==0))||mode==3);
%global crit : Leader of the Pack / Rampage / Moonkin Aura / Elemental Oath / Honor Among Thieves
buff.LotP=((mode==0&&(isempty(excl)||max(strcmpi('LotP',strread(excl,'%s')))==0))||mode==3);
%physical haste : Windfury Totem / Improved Icy Talons
buff.WF=((mode==0&&(isempty(excl)||max(strcmpi('WF',strread(excl,'%s')))==0))||mode==3);
%spell haste : Wrath of Air Totem / Improved Moonkin Form
buff.WoA=((mode==0&&(isempty(excl)||max(strcmpi('WoA',strread(excl,'%s')))==0))||mode==3);
%active haste : Bloodlust / Heroism / Time Warp
buff.BL=((mode==0&&(isempty(excl)||max(strcmpi('BL',strread(excl,'%s')))==0))||mode==3);
%armor : Devotion Aura / Stoneskin Totem
buff.Devo=((mode==0&&(isempty(excl)||max(strcmpi('Devo',strread(excl,'%s')))==0))||mode==2||mode==3);
%Thorns
buff.Thorns=((mode==0&&(isempty(excl)||max(strcmpi('Thorns',(strread(excl,'%s'))))==0))||mode==3);
%Retribution Aura
buff.RA=((mode==0&&(isempty(excl)||max(strcmpi('RA',strread(excl,'%s')))==0))||mode==3);
%Avenging Wrath
buff.AW=((mode==0&&(isempty(excl)||max(strcmpi('AW',strread(excl,'%s')))==0))||mode==2||mode==3);
%Replenishment : Judgements of the Wise / Hunting Party / Improved Soul Leech
buff.JotW=((mode==0&&(isempty(excl)||max(strcmpi('JotW',strread(excl,'%s')))==0))||mode==2||mode==3);
%Divine Plea
buff.DivPlea=((mode==0&&(isempty(excl)||max(strcmpi('DivPlea',strread(excl,'%s')))==0))||mode==2||mode==3);
%Focus Magic (disabled by default, even in exhaustive mode)
buff.Focus=0;

%% Debuffs
%physical damage taken : Savage Combat / Blood Frenzy / Brittle Bones
buff.SavCom=((mode==0&&(isempty(excl)||max(strcmpi('SavCom',strread(excl,'%s')))==0))||mode==3);
%bleed damage taken : Mangle / Trauma / Hemorrhage
buff.Hemo=((mode==0&&(isempty(excl)||max(strcmpi('Hemo',strread(excl,'%s')))==0))||mode==3);
%spell damage taken : Ebon Plaguebringer / Earth and Moon / Curse of the Elements / Master Poisoner
buff.CoE=((mode==0&&(isempty(excl)||max(strcmpi('CoE',strread(excl,'%s')))==0))||mode==3);
%spell crit : Improved Scorch / Improved Shadowbolt
buff.ISB=((mode==0&&(isempty(excl)||max(strcmpi('ISB',strread(excl,'%s')))==0))||mode==3);
%multiplicative armor : Sunder Armor / Expose Armor / Faerie Fire / Scorpid Venom
buff.Sund=((mode==0&&(isempty(excl)||max(strcmpi('Sund',strread(excl,'%s')))==0))||mode==3);
%multiplicative armor : Shattering Throw
buff.ST=((mode==0&&(isempty(excl)||max(strcmpi('ST',strread(excl,'%s')))==0))||mode==3);

%% Player debuffs
%Chill_up=0; %PLACEHOLDER

%% Consumables
if (mode==1||flask==0) buff.flask=equip(1,'s'); else buff.flask=equip(flask,'s'); end;
if (mode==1||ischar(flask)||flask~=0||belixir==0) buff.belixir=equip(1,'s'); else buff.belixir=equip(belixir,'s'); end;
if (mode==1||ischar(flask)||flask~=0||gelixir==0) buff.gelixir=equip(1,'s'); else buff.gelixir=equip(gelixir,'s'); end;
if (mode==1||potion==0) buff.potion=equip(1,'s'); else buff.potion=equip(potion,'s'); end;
if (mode==1||food==0) buff.food=equip(1,'s'); else buff.food=equip(food,'s'); end;
end