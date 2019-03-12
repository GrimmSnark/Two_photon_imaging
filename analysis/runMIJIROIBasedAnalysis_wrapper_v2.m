function runMIJIROIBasedAnalysis_wrapper_v2(experimentDayFile, chooseROIs)

% experimentDayFile = 'D:\Data\2P_Data\Raw\Mouse\gCamp6s\M7\';
subFolders = returnSubFolderList(experimentDayFile);
startFolderNo = 4;
overwriteROIFile =0;

%choose all ROIs
if chooseROIs == 1
    for i = startFolderNo%:length(subFolders)
        subSubFolder =  returnSubFolderList([subFolders(i).folder '\' subFolders(i).name '\TSeries*' ]);
        
        chooseROIsForFIJI([subSubFolder(end).folder '\' subSubFolder(end).name], overwriteROIFile, []);
        
    end
else
    intializeMIJ;
end

% Do actual analysis
for x = startFolderNo%:length(subFolders)
    subSubFolder =  returnSubFolderList([subFolders(x).folder '\' subFolders(x).name '\TSeries*' ]);
    
    runMijiROIBasedAnalysisBatch([subSubFolder(end).folder '\' subSubFolder(end).name '\'], 'Single', [], 'adaptive', 1, [], 2)
    
end

end