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

%get the default glyph file time
temp=dir(fullpath.default.glyphs);
time.glyphs=temp.datenum;

%get the default player file time
temp=dir(fullpath.default.player);
time.player=temp.datenum;

%get the default rotation file time
temp=dir(fullpath.default.rotation);
time.rotation=temp.datenum;

%get the default precombat file time
temp=dir(fullpath.default.precombat);
time.precombat=temp.datenum;

%get the default talents file time
temp=dir(fullpath.default.talents);
time.talents=temp.datenum;

for i=fieldnames(time)'
    
    if (time.(i{1})-out_time)>0
        regenerate=true;
        warning([i{1} ' is newer than txt output, regenerating data']); %#ok<WNTAG>
    end
end


end