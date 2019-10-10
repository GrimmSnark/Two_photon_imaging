function calculateOSIPopulation_wrapper(filepath)

filepathList = dir([filepath '\**\*experimentStructure.mat']);

for i = 1:length(filepathList)
    load([filepathList(i).folder '\experimentStructure.mat']);
    
    calculateOSIPopulation_v2(experimentStructure, 8, 1, 360, 1);
end

end