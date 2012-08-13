function [ c ] = dynamic_model( c )
%DYNAMIC_MODEL calculates effects that depend on the output of
%rotation_model.  It's automatically run every time RM is run.
%
%dynamic_model takes one input argument "c", which is the configuration
%structure for the simulation.  "c" contains the standard fields reurned by
%rotation_model.  
%
%dynamic_model returns an updated "c", containing the new field "dyn"

%% Glyphs

%Glyph of Alabaster Shield
if isempty(find(c.rot.cps(strcmp('SotR',c.abil.val.label),:)>0,1)) %if we don't cast SotR, cps=0
    c.mdf.glyphAS=0;
else
    %TODO: convert from time-averaged to binomial calculation
    c.mdf.glyphAS=0.2.*c.glyph.AlabasterShield.*...
    min( ...
        [c.player.blockpct.*(1-c.player.avoidpct)./c.npc.swing.*c.abil.val.ones;...
        3.*c.rot.cps(strcmp('SotR',c.abil.val.label),:).*c.abil.val.ones]...
    )./c.rot.cps(strcmp('SotR',c.abil.val.label),:);
end

%Glyph of Word of Glory
% c.dyn.glyphWoGUptime=min([6.*c.rot.cps(strcmp('WoG',c.abil.val.label),:);c.abil.val.ones]);
%TODO: move this to FSM, fix

%% Enchants



%% Clean-up
%re-run AM for dps boost to alabaster shield
c=ability_model(c);

%define multiplicative and flat dps modifiers
% c.dyn.multdps=repmat(1+c.mdf.glyphWoG.*c.dyn.glyphWoGUptime,size(c.rot.cps,1),1);
c.dyn.multdps=1;
c.dyn.flatdps=0; %enchants would be added here
end

