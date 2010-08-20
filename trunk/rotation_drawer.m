function [ output_args ] = rotation_drawer( rs , figno)
%ROTATION_DRAWER Creates a graphical representation of a cast sequence
%   The input to this function is a structure "rs" with the following
%   fields:
%rs.seq     is an integer array representing the sequence of ability usage.
%           example: rs.seq=[1 0 2 3 1 2 4 1 2 3 1 2 3].  0 indicates an
%           empty GCD
%rs.names   is a cell array of strings representing the names of the
%           abilities in the sequence.  ex: {'CS','Jud','Exo',...}
%rs.cds     is an integer array containing the cooldowns of the abilities.
%           ex: rs.cds=[4.5 8 15 15]
%rs.order   is an optional integer array representing the display order of
%           the abilities - the earlier abilities are drawn first.  ex:
%           rs.order=[2 1 3 4 5] would reverse the draw order of the first
%           two abilities
%rs.times   is an optional double array containing the times at which each
%           spell is cast.  If left empty, it will simply assume 1.5s GCDs
%
%An optional second input "figno" can be added to specify the figure number
%of the output.



if isfield(rs,'order')==0 || max(rs.order)~=max(rs.seq)
    warning('Order not defined or too short, defaulting to text order')
    rs.order=[1:max(rs.seq)];
end

if length(rs.cds)<max(rs.seq)
    warning('One or more cooldowns unspecified, defaulting to 0')
    rs.cds(length(rs.cds)+1:max(rs.seq))=0;
end

if isfield(rs,'times')==0 || length(rs.times)~=length(rs.seq)
    time=1.5.*[0:length(rs.seq)-1];
else
    time=rs.times;
end
rs.labels=rs.names(rs.order);
rs.labels={'Empty' rs.labels{:}};
rs.labels=fliplr(rs.labels);
if exist('figno')
    figure(figno)
else
    figure
end
% plot(time,-rs.seq,'s', ...
%     'MarkerSize',40, ...
%     'MarkerFaceColor',[1 0 0],...
%     'MarkerEdgeColor','k',...
%     'LineWidth',2)
plot(time,zeros(size(rs.seq)),'k-')
ylim([-max(rs.seq) 1])
set(gca,'XTick',time, ...
        'XGrid','on', ...
        'YTick',[-max(rs.seq):1:0]+0.5, ...
        'YTickLabels',rs.labels);

for m=1:length(rs.seq)
    %create cooldown rectangle
    if rs.seq(m)>0 && rs.cds(rs.seq(m))>0
    rectangle('Position',[time(m) -rs.order(rs.seq(m)) rs.cds(rs.seq(m)) 0.6],...
              'LineWidth',1,...
              'FaceColor',[0 1 0])
    end
    %create ability use rectangle for non-empties
    if rs.seq(m)>0
    rectangle('Position',[time(m) -rs.order(rs.seq(m)) 1.5 0.8], ...
              'LineWidth',2, ...
              'FaceColor',[1 0 0])
    %now for empties
    else
    rectangle('Position',[time(m) 0 time(min([m+1 length(time)]))-time(m) 0.8], ...
              'LineWidth',2, ...
              'FaceColor',[1 0 0])
    end    
end

xlim([min(time) max(time)+1.5])
end
