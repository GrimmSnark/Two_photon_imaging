function processPixelOrientationSelectivity_wrapper(experimentDir)


subFolders = returnSubFolderList('D:\Data\2P_Data\Processed\Mouse\gCamp6s\Old Mice\M1\');
% color = [ones(1,7) 0];

for i =1:3 %:length(subFolders)
    subSubFolder =  returnSubFolderList([subFolders(i).folder '\' subFolders(i).name '\TSeries*' ]);
    
    for x = 1:length(subSubFolder)
        recordingDir = returnSubFolderList([subSubFolder.folder '\' subSubFolder.name]);
        
        processPixelOrientationSelectivityV2([recordingDir.folder '\' recordingDir.name '\'], 0)
    end
    
end

end