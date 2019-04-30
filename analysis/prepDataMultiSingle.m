function prepDataMultiSingle(directory)
% Wrapper to run through a folder containing multiple single files for
% prepData

%  directory = 'D:\Data\2P_Data\Raw\Mouse\gCamp6s\Old Mice\M1\';

subFolders = returnSubFolderList(directory);

templateImg = read_Tiffs('D:\Data\2P_Data\Processed\Monkey\M10_Sully_BF797C\run_11\TSeries-04042019-0932-012\20190426154506\STD_Average_230-700.tif');
for i = 5% 1:length(subFolders)
    
%     subSubFolders = returnSubFolderList([directory subFolders(i).name]);
    subSubFolders = dir([directory subFolders(i).name '\TSeries*']);
    for x = 1:length(subSubFolders)
        prepData([directory subFolders(i).name '\' subSubFolders(x).name],1 ,1,1, 'orientation', [],'nonRigid', templateImg,1);
    end
    
end

end