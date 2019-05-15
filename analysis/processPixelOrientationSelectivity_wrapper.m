function processPixelOrientationSelectivity_wrapper(experimentDir)
% Wrapper for processPixelOrientationSelectivityV2
% This function creates a pixel wise orientation preference and selectivity
% map for orientation experiments

% experimentDir = 'D:\Data\2P_Data\Processed\Mouse\gCamp6s\Old Mice\M1\';
subFolders = returnSubFolderList(experimentDir);
% color = [ones(1,7) 0];
noOrientations = 8;
noColors =1;
maxAngle = 360;

for i =1:length(subFolders)
    subSubFolder =  returnSubFolderList([subFolders(i).folder '\' subFolders(i).name '\TSeries*' ]);
    
    for x = 1:length(subSubFolder)
        recordingDir = returnSubFolderList([subSubFolder.folder '\' subSubFolder.name]);
        
        processPixelOrientationSelectivityV2([recordingDir(end).folder '\' recordingDir(end).name '\'], noOrientations,noColors,maxAngle,0, 1)
    end
    
end

end