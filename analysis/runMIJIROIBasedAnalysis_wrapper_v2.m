function runMIJIROIBasedAnalysis_wrapper_v2(experimentDayFile, chooseROIs, startFolderNo, channel2Use)

% experimentDayFile = 'D:\Data\2P_Data\Raw\Mouse\gCamp6s\M7\';
subFolders = returnSubFolderList(experimentDayFile);
overwriteROIFile =1;

if nargin <3 || isempty(startFolderNo)
    startFolderNo = 1; % sets deafult channel to use if in mult
end


if nargin <4
    channel2Use = 2; % sets deafult channel to use if in mult
end

try
   MIJ.closeAllWindows; 
catch
    
end

%choose all ROIs
if chooseROIs == 1
    for i = startFolderNo:length(subFolders)
        subSubFolder =  returnSubFolderList([subFolders(i).folder '\' subFolders(i).name '\TSeries*' ]);
        
        chooseROIsForFIJI([subSubFolder(end).folder '\' subSubFolder(end).name], overwriteROIFile, [], 1);
        
    end
else
    intializeMIJ;
end

% Do actual analysis
for x = startFolderNo:length(subFolders)
    subSubFolder =  returnSubFolderList([subFolders(x).folder '\' subFolders(x).name '\TSeries*' ]);
    
     runMijiROIBasedAnalysisBatch([subSubFolder(end).folder '\' subSubFolder(end).name '\'], 'Single', [], [], channel2Use);
%     runMijiROIBasedAnalysisBatchV2([subSubFolder(end).folder '\' subSubFolder(end).name '\'], 'Single',[], [], channel2Use)
    
end

end