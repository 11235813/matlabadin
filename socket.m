function [item] = socket(item,varargin)
% The function socket() takes an item and adds gems to it.  The syntax is
% socket(item, gem1[, gem2, gem3]).
% Inputs :
% item - the equipped item or its corresponding slot
% gemN - the IID of the N-th gem
% 
% Note : the equipped item is defined by its corresponding egs.

%check the arguments
if nargin<1||nargin>4
    error('Socket() requires 1-4 arguments (item, plus 1-3 gems).');
end

%check for numeric inputs
if isnumeric(item)
    slot=item;
    clear item;
    if ~(exist('egs','var'))
        item=evalin('base',['tempegs(' int2str(slot) ');']);
    else
        item=evalin('base',['egs(' int2str(slot) ');']);
    end
end

%get number of sockets
nsock=length(item.socket);
%get gem inputs
gemid=cell2mat(varargin);
%track available sockets
strack=isstrprop(item.socket,'lower');

%sanity checks
if max(strack)>0
    getins=input('The item''s sockets are already filled.\nYou can reload the item by entering its IID : ');
    if ~isempty(getins)
        item=equip(getins);
    else
        return
    end
end
if isempty(gemid)
    warning('No gem inputs are specified.');
elseif length(gemid)>nsock
    warning('The number of gem inputs exceeds the number of available sockets.\nThe gems will be equipped in the order they are parsed, until the item''s sockets are filled.','\n');
elseif length(gemid)<nsock
    warning('Insufficient gem inputs.');
end;

%start filling the sockets
if min([nsock nargin-1])>0
    flag=zeros(min([nsock nargin-1]),min([nsock nargin-1]));jtrack=[];
    for i=1:min([nsock nargin-1])
        %exhaustive search for a color match
        for j=1:min([nsock nargin-1])
            if isempty(jtrack) jtmp=[];else jtmp=max([(j==jtrack(:))]);end;
            if isempty(jtmp)||((~isempty(jtmp))&&jtmp==0)
                jgem(j)=equip(gemid(j));
                if jgem(j).socket=='P'
                flag(i,:)=1;
                jtrack=[jtrack j];
                break
                elseif (~isempty(strfind(item.socket(i),'R')))&&(~isempty(strfind(jgem(j).socket,'R')))
                flag(i,:)=1;
                jtrack=[jtrack j];
                break
                elseif (~isempty(strfind(item.socket(i),'Y')))&&(~isempty(strfind(jgem(j).socket,'Y')))
                flag(i,:)=1;
                jtrack=[jtrack j];
                break
                elseif (~isempty(strfind(item.socket(i),'B')))&&(~isempty(strfind(jgem(j).socket,'B')))
                flag(i,:)=1;
                jtrack=[jtrack j];
                break
                elseif (~isempty(strfind(item.socket(i),'M')))&&(~isempty(strfind(jgem(j).socket,'M')))
                flag(i,:)=1;
                jtrack=[jtrack j];
                break
                elseif (~isempty(strfind(item.socket(i),'P')))&&(~(exist('isprism','var')))
                flag(i,:)=1;
                jtrack=[jtrack j];
                isprism=1; %render the P slot inactive for any other gem
                break
                else
                flag(i,:)=0;
                end
            end
        end
        %store the item's socket colors
        tmpsk=item.socket;
        %add the gem's stats
        item=enhance(item,equip(varargin{i}));
        %tag the socket as being filled
        tmpsk(i)=lower(tmpsk(i));
        item.socket=tmpsk;
    end
else
    flag=[0];
end

%check if the socket bonus is activated
if (exist('isprism','var'))&&isempty(item.sbval)
    %do nothing (workaround for belt buckle)
elseif min([min(flag)]) && length(flag)==nsock
    eval(['item.' item.sbstat '=item.' item.sbstat '+item.sbval;']);
else
    warning('The socket bonus is not activated.');
end

%if we were passed a slot, we want to go back and store the item in egs in
%the base workspace.  Otherwise the function will just return item.
if exist('slot','var')
    assignin('base','tempitem',item);
    if ~(exist('egs','var'))
        evalin('base',['tempegs(' int2str(slot) ')=tempitem;']);
    else
        evalin('base',['egs(' int2str(slot) ')=tempitem;']);
    end
    evalin('base','clear tempitem');
end
end