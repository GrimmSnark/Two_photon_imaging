function processZstacksWrapper
dataDir = 'D:\Data\2P_Data\Raw\Monkey\Jack\';

intializeMIJ;
subFolders = dir(dataDir);
subFolders = subFolders(3:end);

for i = 11:length(subFolders)
    currentFolder = [ fullfile(subFolders(i).folder, subFolders(i).name) '\'];
    processZstacks(currentFolder, 1);
end

MIJ.exit

end