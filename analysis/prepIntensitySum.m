function intensitySum = prepIntensitySum(dataDir)
% loads in data and makes sum of t-series intensity


experimentStructure =[];
[experimentStructure, vol]= prepImagingDataFast(experimentStructure, dataDir, 0); % faster version


intensitySum = sum(vol(:));

end