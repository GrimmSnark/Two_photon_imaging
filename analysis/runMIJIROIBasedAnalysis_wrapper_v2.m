function runMIJIROIBasedAnalysis_wrapper_v2(experimentDayFile, chooseROIs)

% experimentDayFile = 'D:\Data\2P_Data\Raw\Mouse\gCamp6s\M7\';
subFolders = returnSubFolderList(experimentDayFile);
startFolderNo = 1;
overwriteROIFile =0;

%choose all ROIs
if chooseROIs == 1
    for i = startFolderNo:length(subFolders)
        subSubFolder =  returnSubFolderList([subFolders(i).folder '\' subFolders(i).name '\TSeries*' ]);
        
        chooseROIsForFIJI([subSubFolder.folder '\' subSubFolder.name], overwriteROIFile, []);
        
    end
end

% Do actual analysis
for x = startFolderNo:length(subFolders)
    subSubFolder =  returnSubFolderList([subFolders(x).folder '\' subFolders(x).name '\TSeries*' ]);
    
    runMijiROIBasedAnalysisBatch([subSubFolder.folder '\' subSubFolder.name '\'], 'Single', [], 'adaptive', 0, [])
    
end

end