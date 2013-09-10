function [ arg_str ] = create_argument_string( sim )
%create_argument_string takes the output file specifications provided in the
%"sim" argument and constructs the string passed to simc.exe on the
%command line


arg_str = '';

%iterations
if isfield(sim,'iterations') && ~isempty(sim.iterations)
    arg_str=strcat(arg_str,' iterations=',int2str(sim.iterations));
end

%ptr flag
if isfield(sim,'ptr') && ~isempty(sim.ptr) && sim.ptr>0
    arg_str=strcat(arg_str,' ptr=',int2str(sim.ptr));
end

%add trailing space
if ~isempty(arg_str)
    arg_str=strcat(arg_str,' ');
end

end