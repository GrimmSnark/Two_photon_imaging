function processPixelOrientationSelectivity_wrapper(experimentDir)


subFolders = returnSubFolderList('D:\Data\2P_Data\Processed\Mouse\gCamp6s\M6\');

for i =7 %8:length(subFolders)
    subSubFolder =  returnSubFolderList([subFolders(i).folder '\' subFolders(i).name '\TSeries*' ]);
    
    for x = 1:length(subSubFolder)
        recordingDir = returnSubFolderList([subSubFolder.folder '\' subSubFolder.name]);
        
        processPixelOrientationSelectivity([recordingDir.folder '\' recordingDir.name '\'], 1)
    end
    
end

end