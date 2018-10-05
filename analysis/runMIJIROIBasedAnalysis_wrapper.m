
subFolders = returnSubFolderList('D:\Data\2P_Data\Raw\Mouse\gCamp6s\M3\');

for i = 1:length(subFolders) -1
   subSubFolder =  returnSubFolderList([subFolders(i).folder '\' subFolders(i).name '\TSeries*' ]);

runMijiROIBasedAnalysis([subSubFolder.folder '\' subSubFolder.name], 'Single', 0, [], 'adaptive', 1, [])

end



%  runMijiROIBasedAnalysis('D:\Data\2P_Data\Raw\Mouse\gCamp6s\M1\5on_5off_4\TSeries-09042018-0830-011\', 'Single', 0, [], 'fixed', [])
