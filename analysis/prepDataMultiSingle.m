function prepDataMultiSingle(dir)
% Wrapper to run through a folder containing multiple single files for
% prepData

 dir = 'D:\Data\2P_Data\Raw\Mouse\OGB\OGB_M3\';

subFolders = returnSubFolderList(dir);

for i =4:length(subFolders)
    
    subSubFolders = returnSubFolderList([dir subFolders(i).name]);
    for x = 1:length(subSubFolders)
        stdVol =  prepData([dir subFolders(i).name '\' subSubFolders(x).name],1 ,1,0, 'orientation', []);
    end
    
end

end