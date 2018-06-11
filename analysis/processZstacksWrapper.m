function processZstacksWrapper(dataDir)
dataDir = 'D:\Data\2P_Data\Raw\Mouse\Structural\cfos_gfp2\';

intializeMIJ;
subFolders = dir(dataDir);
subFolders = subFolders(3:end);

for i = 3:length(subFolders)
    currentFolder = [ fullfile(subFolders(i).folder, subFolders(i).name) '\'];
    processZstacks(currentFolder, 1);
end

MIJ.exit

end