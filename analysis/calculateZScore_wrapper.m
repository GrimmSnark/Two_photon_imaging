function calculateZScore_wrapper(filepath, FBSorFISSA)

cd(filepath);

filepathList = dir(['**\*experimentStructure.mat']);

for i = 1:length(filepathList)
    load([filepathList(i).folder '\experimentStructure.mat']);
    
    experimentStructure = calculateZScore(experimentStructure, FBSorFISSA);
    save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure');
end

end