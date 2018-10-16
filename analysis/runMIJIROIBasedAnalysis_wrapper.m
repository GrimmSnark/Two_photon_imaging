%script for running full analysis per video stack, needs more hands on time
%as it runs analysis per stack and asks for next video ROI choice.. see v2
%for improved version
subFolders = returnSubFolderList('D:\Data\2P_Data\Processed\Mouse\gCamp6s\Old Mice\M1\');

for i = 1:length(subFolders) 
   subSubFolder =  returnSubFolderList([subFolders(i).folder '\' subFolders(i).name '\TSeries*' ]);

runMijiROIBasedAnalysis([subSubFolder.folder '\' subSubFolder.name], 'Single', 1, [], 'adaptive', 1, [])

end



%  runMijiROIBasedAnalysis('D:\Data\2P_Data\Raw\Mouse\gCamp6s\M1\5on_5off_4\TSeries-09042018-0830-011\', 'Single', 0, [], 'fixed', [])
