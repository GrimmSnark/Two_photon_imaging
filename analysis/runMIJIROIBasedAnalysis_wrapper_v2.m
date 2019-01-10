function runMIJIROIBasedAnalysis_wrapper_v2(experimentDayFile)

experimentDayFile = 'D:\Data\2P_Data\Raw\Mouse\gCamp6s\M7\';
subFolders = returnSubFolderList(experimentDayFile);
startFolderNo = 1;
overwriteROIFile =1;

%choose all ROIs
for i = startFolderNo:length(subFolders)
    subSubFolder =  returnSubFolderList([subFolders(i).folder '\' subFolders(i).name '\TSeries*' ]);
    
    chooseROIsForFIJI([subSubFolder.folder '\' subSubFolder.name], overwriteROIFile, []);
    
end

% Do actual analysis
for x = [startFolderNo:4 6:length(subFolders)-1]
    subSubFolder =  returnSubFolderList([subFolders(x).folder '\' subFolders(x).name '\TSeries*' ]);
    
    runMijiROIBasedAnalysisBatch([subSubFolder.folder '\' subSubFolder.name '\'], 'Single', [], 'adaptive', 1, [])
    
end

end