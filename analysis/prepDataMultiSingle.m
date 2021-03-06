function prepDataMultiSingle(directory, startDirNo)
% Wrapper to run through a folder containing multiple single files for
% prepData

%  directory = 'D:\Data\2P_Data\Raw\Mouse\gCamp6s\Old Mice\M1\';
if nargin < 2 || isempty(startDirNo)
   startDirNo = 1; 
end

subFolders = returnSubFolderList(directory);
saveMovie =0;

% templateImg = read_Tiffs('D:\Data\2P_Data\Processed\Monkey\M10_Sully_BF797C\run_11\TSeries-04042019-0932-012\20190426154506\STD_Average_230-700.tif');
templateImg =[];
for i = startDirNo:length(subFolders)
    
%     subSubFolders = returnSubFolderList([directory subFolders(i).name]);
    subSubFolders = dir([directory subFolders(i).name '\TSeries*']);
    for x = 1:length(subSubFolders)
        prepData([directory subFolders(i).name '\' subSubFolders(x).name],1 ,1,saveMovie, 'orientation', 2,'subMicronMethod', templateImg,1 );
    end
    
end

end