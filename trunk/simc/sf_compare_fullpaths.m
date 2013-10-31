function regenerate = sf_compare_fullpaths( fullpath )
%COMPARE_FULLPATHS checks the date on all relevant input files
%and returns true if the output text file is older than any of them


regenerate=false;

%get the txt output file time
temp=dir(fullpath.output);
out_time=datenum(temp.date);

%get the simc file time
temp=dir(fullpath.simc);
time.simc=datenum(temp.date);

%get the exe file time
temp=dir(fullpath.exe);
time.exe=datenum(temp.date);

%get the default glyph file time
temp=dir(fullpath.default.glyphs);
time.glyphs=datenum(temp.date);

%get the default player file time
temp=dir(fullpath.default.player);
time.player=datenum(temp.date);

%get the default rotation file time
temp=dir(fullpath.default.rotation);
time.rotation=datenum(temp.date);

%get the default precombat file time
temp=dir(fullpath.default.precombat);
time.precombat=datenum(temp.date);

%get the default talents file time
temp=dir(fullpath.default.talents);
time.talents=datenum(temp.date);

for i=fieldnames(time)'
    
    if (time.(i{1})-out_time)>0
        regenerate=true;
        warning([i{1} ' is newer than txt output, regenerating data']); %#ok<WNTAG>
    end
end


end