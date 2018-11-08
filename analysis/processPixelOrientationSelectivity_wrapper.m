function processPixelOrientationSelectivity_wrapper(experimentDir)


subFolders = returnSubFolderList('D:\Data\2P_Data\Processed\Mouse\gCamp6s\M7\');
color = [ones(1,7) 0];

for i =1:length(subFolders)
    subSubFolder =  returnSubFolderList([subFolders(i).folder '\' subFolders(i).name '\TSeries*' ]);
    
    for x = 1:length(subSubFolder)
        recordingDir = returnSubFolderList([subSubFolder.folder '\' subSubFolder.name]);
        
        processPixelOrientationSelectivity([recordingDir.folder '\' recordingDir.name '\'], color(i))
    end
    
end

end