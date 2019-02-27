function processPixelOrientationSelectivity_wrapper(experimentDir)

% experimentDir = 'D:\Data\2P_Data\Processed\Mouse\gCamp6s\Old Mice\M1\';
subFolders = returnSubFolderList(experimentDir);
% color = [ones(1,7) 0];

for i =1:length(subFolders)
    subSubFolder =  returnSubFolderList([subFolders(i).folder '\' subFolders(i).name '\TSeries*' ]);
    
    for x = 1:length(subSubFolder)
        recordingDir = returnSubFolderList([subSubFolder.folder '\' subSubFolder.name]);
        
        processPixelOrientationSelectivityV2([recordingDir.folder '\' recordingDir.name '\'], 0, 1)
    end
    
end

end