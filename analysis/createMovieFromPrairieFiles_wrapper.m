directory = 'D:\Data\2P_Data\Processed\Mouse\gCamp6s\M1\';

subFolders = returnSubFolderList(directory);

for i = 1:length(subFolders)
     subSubFolder =  returnSubFolderList([subFolders(i).folder '\' subFolders(i).name '\TSeries*' ]);
     resultsFolder = returnSubFolderList([subSubFolder.folder '\' subSubFolder.name ]);
     recordingDir = [resultsFolder.folder '\' resultsFolder.name '\'];
     createMovieFromPrairieFiles(recordingDir, 0 )
     
    
end