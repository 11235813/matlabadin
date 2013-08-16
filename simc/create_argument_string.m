function [ arg_str ] = create_argument_string( sim )
%create_output_string takes the output file specifications provided in the
%"sim" argument and constructs the string passed to simc.exe on the
%command line


arg_str = '';

if isfield(sim,'iterations') && ~isempty(sim.iterations)
    arg_str=strcat(arg_str,' iterations=',int2str(sim.iterations));
end

if isfield(sim,'player') && ~isempty(sim.player)
    arg_str=strcat(arg_str,' ',sim.player);
end

if ~isempty(arg_str)
    arg_str=strcat(arg_str,' ');
end

end