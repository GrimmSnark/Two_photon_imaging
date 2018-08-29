
subFolders = returnSubFolderList('D:\Data\2P_Data\Raw\Mouse\OGB\OGB_M4\');

for i = 1:length(subFolders) -1
   subSubFolder =  returnSubFolderList([subFolders(i).folder '\' subFolders(i).name '\TSeries*' ]);

runMijiROIBasedAnalysis([subSubFolder.folder '\' subSubFolder.name], 'Single', 1, [], 'adaptive', [])

end



% runMijiROIBasedAnalysis('D:\Data\2P_Data\Raw\Mouse\OGB\OGB_M2\5on_5off_2\', 'Multi', 0, [], 'adaptive', [])
