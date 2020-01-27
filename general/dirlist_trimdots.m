function dirList = dirlist_trimdots(dirIn)

i = 0;
for x = 3:length(dirIn)
    i = i+1;
    dirList{i} = dirIn(x).name;
end

end