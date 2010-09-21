function [buff] =  buff_model(varargin)
%% Buffs/Debuffs
%TODO insert comment later on
%Inputs [default value] :
%mode - master switch; 0-custom, 1-none, 2-self, 3-exhaustive [3]
%flask - flask option; name or SID (0 if none) [79469,'Flask of Steelskin']
%belixir - battle elixir option; name or SID (0 if none) [0]
%gelixir - guardian elixir option; name or SID (0 if none) [0]
%potion - potion option; name or SID (0 if none) [79475,'Earthen Potion']
%food - food option; name or SID (0 if none) [87584,'Beer-Basted Crocolisk']

%% Input handling
%populate all entries with empty arrays
mode=[];flask=[];belixir=[];gelixir=[];potion=[];food=[];
%start filling entries with inputs
if nargin>1
    for i=1:2:length(varargin)
        name=varargin{i};         
        value=varargin{i+1};
        switch name
            case 'mode'
                mode=value;
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
if isempty(flask)==1 flask=79469; end;
if isempty(belixir)==1 belixir=0; end;
if isempty(gelixir)==1 gelixir=0; end;
if isempty(potion)==1 potion=79475; end;
if isempty(food)==1 food=87584; end;


%% Buffs
buff.BoK=(mode==2||mode==3);      %5% stats, resistance : Blessing of Kings / Mark of the Wild
buff.SoE=(mode==3);               %agility&strength : Strength of Earth / Horn of Winter / Battle Shout
buff.PWF=(mode==3);               %stamina : Power word Fortitude / Commanding Shout
buff.ArcInt=(mode==3);            %mana : Arcane Intellect / Fel Intelligence
buff.UnRage=(mode==3);            %multiplicative AP : Unleashed Rage / Blessing of Might / Trueshot Aura / Abomination's Might
buff.FMT=(mode==3);               %lesser multiplicative SP : Flametongue Totem
buff.ToW=(mode==3);               %greater multiplicative SP : Totem of Wrath / Demonic Pact
buff.HePr=(mode==3);              %global hit : Heroic Presence (Draenei) /TODO check it up later
buff.ArcTac=(mode==3);            %global damage dealt : Communion / Ferocious Inspiration / Arcane Tactics
buff.LotP=(mode==3);              %global crit : Leader of the Pack / Rampage / Moonkin Aura / Elemental Oath / Honor Among Thieves
buff.WF=(mode==3);                %physical haste : Windfury Totem / Improved Icy Talons
buff.WoA=(mode==3);               %spell haste : Wrath of Air Totem / Improved Moonkin Form
buff.BL=(mode==3);                %active haste : Bloodlust / Heroism / Time Warp
buff.Devo=(mode==2||mode==3);     %armor : Devotion Aura / Stoneskin Totem
buff.Thorns=(mode==3);            %Thorns
buff.RA=(mode==3);                %Retribution Aura
buff.AW=(mode==2||mode==3);       %Avenging Wrath
buff.JotW=(mode==2||mode==3);     %Replenishment : Judgements of the Wise / Hunting Party / Improved Soul Leech
buff.DivPlea=(mode==2||mode==3);  %Divine Plea
buff.Focus=0;                     %Focus Magic (disabled by default, even in exhaustive mode)

%% Debuffs
buff.SavCom=(mode==3);            %physical damage taken : Savage Combat / Blood Frenzy / Brittle Bones
buff.Hemo=(mode==3);              %bleed damage taken : Mangle / Trauma / Hemorrhage
buff.CoE=(mode==3);               %spell damage taken : Ebon Plaguebringer / Earth and Moon / Curse of the Elements / Master Poisoner 
buff.ISB=(mode==3);               %spell crit : Improved Scorch / Improved Shadowbolt
buff.Sund=(mode==3);              %multiplicative armor : Sunder Armor / Expose Armor / Faerie Fire / Scorpid Venom
buff.ST=(mode==3);                %multiplicative armor : Shattering Throw

%% Player debuffs
%Chill_up=0; %PLACEHOLDER

%% Consumables
if flask==0 buff.flask=equip(1,'s'); else buff.flask=equip(flask,'s'); end;
if (ischar(flask)||flask~=0||belixir==0) buff.belixir=equip(1,'s'); else buff.belixir=equip(belixir,'s'); end;
if (ischar(flask)||flask~=0||gelixir==0) buff.gelixir=equip(1,'s'); else buff.gelixir=equip(gelixir,'s'); end;
if potion==0 buff.potion=equip(1,'s'); else buff.potion=equip(potion,'s'); end;
if food==0 buff.food=equip(1,'s'); else buff.food=equip(food,'s'); end;
end