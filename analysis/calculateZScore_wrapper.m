function calculateZScore_wrapper(filepath, FBSorFISSA)


filepathList = dir([filepath '\**\*experimentStructure.mat']);

for i = 8 %:length(filepathList)
    load([filepathList(i).folder '\experimentStructure.mat']);
    
    experimentStructure = calculateZScore(experimentStructure, FBSorFISSA);
    save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure');
end

end