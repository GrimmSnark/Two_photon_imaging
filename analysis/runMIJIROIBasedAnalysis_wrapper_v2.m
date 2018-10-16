function runMIJIROIBasedAnalysis_wrapper_v2(experimentDayFile)

experimentDayFile = 'D:\Data\2P_Data\Raw\Mouse\gCamp6s\M4\';
subFolders = returnSubFolderList(experimentDayFile);

%choose all ROIs
for i = 1:length(subFolders)
    subSubFolder =  returnSubFolderList([subFolders(i).folder '\' subFolders(i).name '\TSeries*' ]);
    
    chooseROIsForFIJI([subSubFolder.folder '\' subSubFolder.name], 0, []);
    
end

% Do actual analysis
for x = 1:length(subFolders)
    subSubFolder =  returnSubFolderList([subFolders(x).folder '\' subFolders(x).name '\TSeries*' ]);
    
    runMijiROIBasedAnalysisBatch([subSubFolder.folder '\' subSubFolder.name '\'], 'Single', [], 'adaptive', 1, [])
    
end

end