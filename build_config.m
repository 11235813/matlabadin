function [ c ] = build_config(varargin)

global ddb

%% Input handling
%populate all entries with empty arrays
p.race=[];p.prof=0;p.lvl=[]; %player_model
n.lvl=[];n.type=[];n.swing=[];n.cast=[];n.phflag=[];n.blockflag=[];n.out.phys=[];n.out.spell=[]; %npc_model
e.npccount=[];e.timein=[];e.timeout=[];e.behind=[];e.seal=0;e.veng=[];e.overh=[];e.queue=[]; %exec_model
b.mode=[];b.item=[];b.flask=[];b.belixir=[];b.gelixir=[];b.potion=[];b.food=[]; %buff_model
s.spec=[]; %spec_model
t.shortform=[]; %talent_model
g.shortform=[]; %glyph_model
gr.gset=[];gr.hit=[];gr.exp=[]; %gear set
%start filling entries with inputs
if nargin>1
    for i=1:2:length(varargin)
        name=varargin{i};         
        value=varargin{i+1};
        switch name
            case {'level','lvl'}
                error('Ambiguous input "lvl" or "level"; use clvl or blvl instead')
            %player_model
            case 'race'
                p.race=value;
            case 'prof'
                p.prof=value;
            case {'clevel','clvl'}
                p.lvl=value;
            %npc_model
            case {'blevel','blvl'}
                n.lvl=value;
            case 'type'
                n.type=value;
            case 'swing'
                n.swing=value;
            case 'cast'
                n.cast=value;
            case 'phflag'
                n.phflag=value;
            case 'blockflag'
                n.blockflag=value;
            case 'outphys'
                n.out.phys=value;
            case 'outspell'
                n.out.spell=value;
            %exec_model
            case 'npccount'
               e.npccount=value;
            case 'timein'
               e.timein=value;
            case 'timeout'
               e.timeout=value;
            case 'behind'
               e.behind=value;
            case 'seal'
               e.seal=value;
            case 'veng'
               e.veng=value;
            case 'overh'
               e.overh=value;
            case {'rot','pseq','queue'}
                e.queue=value;
            %buff_model
            case 'mode'
                b.mode=value;
            case 'item'
                b.item=value;
            case 'flask'
                b.flask=value;
            case 'belixir'
                b.belixir=value;
            case 'gelixir'
                b.gelixir=value;
            case 'potion'
                b.potion=value;
            case 'food'
                b.food=value;
            case 'spec'
                s.spec=value;
            case {'talents','talent'}
                t.shortform=value;
            case {'glyphs','glyph'}
                g.shortform=value;
            case {'gear','gearset','gset'}
                gr.gset=value;
            case 'hit'
                gr.hit=value;
            case 'exp'
                gr.exp=value;
        end
    end
end


%% Build simulation configuration
%"c" is the default config structure name.  For sims which require multiple
%configurations, we'll use c(1), c(2), etc.

%invoke player model
c.base=player_model('race',p.race,'prof',p.prof,'lvl',p.lvl);  %possibly rename "char_model"

%invoke npc model
c.npc=npc_model(c.base,'lvl',n.lvl,'type',n.type,'swing',n.swing,'cast',n.cast,'phflag',n.phflag,'blockflag',n.blockflag,'outphys',n.out.phys,'outspell',n.out.spell);

%invoke execution_model
c.exec=execution_model('npccount',e.npccount,'timein',e.timein,'timeout',e.timeout,'behind',e.behind,'seal',e.seal,'veng',e.veng,'overh',e.overh,'queue',e.queue);

%activate buffs and consumables
c.buff=buff_model('mode',b.mode,'item',b.item,'flask',b.flask,'belixir',b.belixir,'gelixir',b.gelixir,'potion',b.potion,'food',b.food);

%invoke spec, talents & glyphs
c.spec=spec_model(s.spec,p.lvl);
c.talent=talent_model(t.shortform);
c.glyph=glyph_model(g.shortform);

%load gear set - if none is specified, default to pre-raid
if isempty(gr.gset)==1 
    gr.gset=4;  %1=450, 2=463, 3=483, 4=496 (T14N), 5=509
end 
c.egs=ddb.gearset{gr.gset}; 

%calculate relevant stats
%TODO: this could be built into stat_model
c.gear=gear_stats(c.egs);

%set hit/exp appropriately
if isempty(gr.hit)==1; gr.hit=-1; end %set these to -1 if not specified
if isempty(gr.exp)==1; gr.exp=-1; end %set these to -1 if not specified
c=gear_sethitexp(c,gr.hit,gr.exp); %ignores -1 inputs

%generate the remaining fields
c=stat_model(c);
c=ability_model(c);
c=rotation_model(c);

%order fields alphabetically
c=orderfields(c);
end

