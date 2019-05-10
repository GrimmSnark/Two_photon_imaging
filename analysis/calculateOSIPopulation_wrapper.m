function calculateOSIPopulation_wrapper(filepath)

cd(filepath);

filepathList = dir(['**\*experimentStructure.mat']);

for i = 1:length(filepathList)
    load([filepathList(i).folder '\experimentStructure.mat']);
    calculateOSIPopulation(experimentStructure, 8, 1);
end

end