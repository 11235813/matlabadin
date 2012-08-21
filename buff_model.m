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
if isempty(food)==1 food=87594; end;


%% Player Buffs

%multiplicative STA : Power Word Fortitude / Commanding Shout / Blood Pact / Quiraji Fortitude
buff.STA=((mode==0&&(isempty(item)||isempty(regexpi(item,'STA'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'STA'))))));
%multiplicative AP : Battle Shout / Trueshot Aura / Horn of Winter
buff.AP=((mode==0&&(isempty(item)||isempty(regexpi(item,'AP'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'AP'))))));
%multiplicative SP : Burning Wrath / Dark Intent / Arcane Brilliance / Still Water
buff.SP=((mode==0&&(isempty(item)||isempty(regexpi(item,'SP'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'SP'))))));
%physical attack speed : Unleashed Rage / Swiftblade's Cunning / Unholy Aura
buff.mhaste=((mode==0&&(isempty(item)||isempty(regexpi(item,'mhaste'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'mhaste'))))));
%spell haste : Shadowform / Moonkin Form / Elemental Oath
buff.shaste=((mode==0&&(isempty(item)||isempty(regexpi(item,'shaste'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'shaste'))))));
%global crit : Leader of the Pack / Arcane Brilliance
buff.crit=((mode==0&&(isempty(item)||isempty(regexpi(item,'crit'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'crit'))))));
%mastery :  Blessing of  Might / Grace of Air
buff.mast=((mode==0&&(isempty(item)||isempty(regexpi(item,'mast'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'mast'))))));
%stats : Blessing of Kings / Mark of the Wild / Embrace of the Shale Spider / Legacy of the Emperor
buff.stats=((mode==0&&(isempty(item)||isempty(regexpi(item,'stats'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'stats'))))));


%Other  effects
%active haste : Bloodlust / Heroism / Time Warp
buff.BLust=((mode==0&&(isempty(item)||isempty(regexpi(item,'BLust'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'BLust'))))));
%Thorns
buff.Thorns=((mode==0&&(isempty(item)||isempty(regexpi(item,'Thorns'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'Thorns'))))));
%Righteous Fury
buff.RFury=((mode==0&&(isempty(item)||isempty(regexpi(item,'RFury')))) ...
    ||mode==2||mode==3||mode==4);

%% Temporary effects
%handled as permanent buffs 
%TODO: add Bloodlust here
%Avenging Wrath
buff.AW=(~isempty(item) && ~isempty(regexpi(item,'AW')));
%Holy Avenger
buff.HA=(~isempty(item) && ~isempty(regexpi(item,'HA')));

%% Player debuffs
%Chill_up=0; %PLACEHOLDER

%% Boss Debuffs
%physical vulnerability : Brittle Bones / Ebon Plaguebringer / Colossus Smash / Judgements of the Bold
buff.PhysVuln=((mode==0&&(isempty(item)||isempty(regexpi(item,'PhysVuln'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'PhysVuln'))))));
%spell damage taken : Curse of the Elements / Master Poisoner
buff.spdmg=((mode==0&&(isempty(item)||isempty(regexpi(item,'spdmg'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'spdmg'))))));
%weakened armor : Sunder Armor / Expose Armor / Faerie Fire / Scorpid Venom
buff.WeakArmor=((mode==0&&(isempty(item)||isempty(regexpi(item,'WeakArmor'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'WeakArmor'))))));
%weakened blows : Keg Smash / Scarlet Fever / Thrash / Hammer of the Righteous / Thunderclap
buff.WeakBlow=((mode==0&&(isempty(item)||isempty(regexpi(item,'WeakBlow'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'WeakBlow'))))));
%multiplicative armor : Shattering Throw
buff.SThrow=((mode==0&&(isempty(item)||isempty(regexpi(item,'SThrow'))))||mode==3 ...
    ||(mode==4&&((~isempty(item))&&(~isempty(regexpi(item,'SThrow'))))));

%% Consumables
if (mode==1||flask==0) buff.flask=equip(1,'s'); else buff.flask=equip(flask,'s'); end;
if (mode==1||ischar(flask)||flask~=0||belixir==0) buff.belixir=equip(1,'s'); else buff.belixir=equip(belixir,'s'); end;
if (mode==1||ischar(flask)||flask~=0||gelixir==0) buff.gelixir=equip(1,'s'); else buff.gelixir=equip(gelixir,'s'); end;
if (mode==1||potion==0) buff.potion=equip(1,'s'); else buff.potion=equip(potion,'s'); end;
if (mode==1||food==0) buff.food=equip(1,'s'); else buff.food=equip(food,'s'); end;
end