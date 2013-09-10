function [ player_str ] = create_argument_string( sim )
%create_player_string takes the player specifications provided in the
%"sim" argument and constructs the string passed to simc.exe on the
%command line

%% these are all required inputs, so error if any of them are missing
if ~isfield(sim,'player')  || isempty(sim.player) ||...
   ~isfield(sim,'glyphs')  || isempty(sim.glyphs) || ...
   ~isfield(sim,'talents') || isempty(sim.talents) || ...
   ~isfield(sim,'gear')    || isempty(sim.gear) || ...
   ~isfield(sim,'rotation')|| isempty(sim.rotation) 
    error('Critical player parameters omitted, can''t sim');
end

%% initialize string
player_str = '';


%% add all of the relevant parts. These can be simc files or text
player_str=strcat(player_str,[' ' sim.playerpath '\player\' sim.player]);
player_str=strcat(player_str,[' ' sim.playerpath '\glyphs\' sim.glyphs]);
player_str=strcat(player_str,[' ' sim.playerpath '\talents\' sim.talents]);
player_str=strcat(player_str,[' ' sim.playerpath '\gear\' sim.gear]);
player_str=strcat(player_str,[' ' sim.playerpath '\rotation\' sim.rotation]);

player_str=strcat(player_str,' ');

end