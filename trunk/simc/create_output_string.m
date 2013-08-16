function [ output_str ] = create_output_string( sim )
%create_output_string takes the output file specifications provided in the
%"sim" argument and constructs the string passed to simc.exe on the
%command line

output_str = '';

if isfield(sim,'html') && ~isempty(sim.html)
    output_str = strcat(output_str,' html=',sim.html);
end
if isfield(sim,'txt') && ~isempty(sim.txt)
    output_str = strcat(output_str,' output=',sim.txt);
end
if isfield(sim,'xml') && ~isempty(sim.xml)
    output_str = strcat(output_str,' xml=',sim.xml);
end
if isfield(sim,'csv') && ~isempty(sim.csv)
    output_str = strcat(output_str,' csv=',sim.csv);
end

if ~isempty(output_str)
    output_str=strcat(output_str,' ');
end

end

