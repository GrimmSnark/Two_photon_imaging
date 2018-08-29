function prepDataMultiSingle(directory)
% Wrapper to run through a folder containing multiple single files for
% prepData

 directory = 'D:\Data\2P_Data\Raw\Mouse\OGB\OGB_M4\';

subFolders = returnSubFolderList(directory);

for i =1 :length(subFolders)-1
    
%     subSubFolders = returnSubFolderList([directory subFolders(i).name]);
    subSubFolders = dir([directory subFolders(i).name '\TSeries*']);
    for x = 1:length(subSubFolders)
        stdVol =  prepData([directory subFolders(i).name '\' subSubFolders(x).name],1 ,1,0, 'orientation', []);
    end
    
end

end