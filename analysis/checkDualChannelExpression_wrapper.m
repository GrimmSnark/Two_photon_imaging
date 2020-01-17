function  checkDualChannelExpression_wrapper(experimentDayFile, channel2Check)

subFolders = dir([experimentDayFile '**\experimentStructure.mat']);
startFolderNo = 1;

intializeMIJ;

if nargin <2
    channel2Use = 1; % sets deafult channel to use if in mult
end

try
   MIJ.closeAllWindows; 
catch
    
end

for i = startFolderNo:length(subFolders)
    checkDualChannelExpression([subFolders(i).folder '\'], channel2Check);
end
end
