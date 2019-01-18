function createStimSTDAverageREDO_wrapper(experimentDayFile)

experimentDayFile = 'D:\Data\2P_Data\Processed\Mouse\gCamp6s\M5\';
subFolders = returnSubFolderList(experimentDayFile);

for i = 1:length(subFolders)
    subSubFolder =  returnSubFolderList([subFolders(i).folder '\' subFolders(i).name '\TSeries*' ]);
    
    resultsFolder = returnSubFolderList([subSubFolder(end).folder '\' subSubFolder(end).name '\']);
    folderPath = [resultsFolder.folder '\' resultsFolder.name '\'];
    
    createStimSTDAverageREDO(folderPath)
    
end

end