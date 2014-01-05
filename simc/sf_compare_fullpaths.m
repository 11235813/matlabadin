function regenerate = sf_compare_fullpaths( fullpath )
%COMPARE_FULLPATHS checks the date on all relevant input files
%and returns true if the output text file is older than any of them


regenerate=false;

%get the txt output file time
temp=dir(fullpath.output);
if ~isempty(temp)
    out_time=temp.datenum;
else
    out_time=0;
end

%get the simc file time
temp=dir(fullpath.simc);
if ~isempty(temp)
    time.simc=temp.datenum;
else
    time.simc=0;
end

%get the exe file time
temp=dir(fullpath.exe);
time.exe=temp.datenum;

%get the glyph file time
if isfield(fullpath,'glyphs')
    temp=dir(fullpath.glyphs);
    time.glyphs=temp.datenum;
end

%get the player file time
if isfield(fullpath,'player')
    temp=dir(fullpath.player);
    time.player=temp.datenum;
end

%get the rotation file time
if isfield(fullpath,'rotation')
    temp=dir(fullpath.rotation);
    time.rotation=temp.datenum;
end

%get the precombat file time
if isfield(fullpath,'precombat')
    temp=dir(fullpath.precombat);
    time.precombat=temp.datenum;
end

%get the talents file time
if isfield(fullpath,'talents')
    temp=dir(fullpath.talents);
    time.talents=temp.datenum;
end

for i=fieldnames(time)'
    
    if (time.(i{1})-out_time)>0
        regenerate=true;
        warning([i{1} ' file is newer than txt output, regenerating data']); %#ok<WNTAG>
    end
end


end