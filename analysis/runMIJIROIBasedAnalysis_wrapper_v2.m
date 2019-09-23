function runMIJIROIBasedAnalysis_wrapper_v2(experimentDayFile, chooseROIs, channel2Use)

% experimentDayFile = 'D:\Data\2P_Data\Raw\Mouse\gCamp6s\M7\';
subFolders = returnSubFolderList(experimentDayFile);
startFolderNo = 1;
overwriteROIFile =0;

if nargin <3
    channel2Use = 2; % sets deafult channel to use if in mult
end


%choose all ROIs
if chooseROIs == 1
    for i = startFolderNo:length(subFolders)
        subSubFolder =  returnSubFolderList([subFolders(i).folder '\' subFolders(i).name '\TSeries*' ]);
        
        chooseROIsForFIJI([subSubFolder(end).folder '\' subSubFolder(end).name], overwriteROIFile, [], channel2Use);
        
    end
else
    intializeMIJ;
end

% Do actual analysis
for x = startFolderNo:length(subFolders)
    subSubFolder =  returnSubFolderList([subFolders(x).folder '\' subFolders(x).name '\TSeries*' ]);
    
%     runMijiROIBasedAnalysisBatch([subSubFolder(end).folder '\' subSubFolder(end).name '\'], 'Single', [], 'adaptive', 1, [], 2);
    runMijiROIBasedAnalysisBatchV2([subSubFolder(end).folder '\' subSubFolder(end).name '\'], 'Single',[], [], 1, channel2Use)
    
end

end