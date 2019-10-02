function experimentStructure = calculateZScore(experimentStructure, FBSorFISSA)
% Calculates ZScore responsivity for cells for either FBS or FISSA stimulus

if FBSorFISSA == 1
    
    maxStimData = cellfun(@max,cellfun(@mean,cellfun(@cell2mat,experimentStructure.dFstimWindowAverageFBS, 'Un', 0), 'Un', 0));
    
    prestimMean = cellfun(@mean,cellfun(@mean,cellfun(@cell2mat,experimentStructure.dFpreStimWindowAverageFBS, 'Un', 0), 'Un', 0));
    prestimSD =cellfun(@std,cellfun(@mean,cellfun(@cell2mat,experimentStructure.dFpreStimWindowAverageFBS, 'Un', 0), 'Un', 0));
    
    experimentStructure.ZScore_FBS = (maxStimData - prestimMean) ./prestimSD;
    
elseif FBSorFISSA ==2    
    maxStimData = cellfun(@max,cellfun(@mean,cellfun(@cell2mat,experimentStructure.dFstimWindowAverage, 'Un', 0), 'Un', 0));
    
    prestimMean = cellfun(@mean,cellfun(@mean,cellfun(@cell2mat,experimentStructure.dFpreStimWindowAverage, 'Un', 0), 'Un', 0));
    prestimSD =cellfun(@std,cellfun(@mean,cellfun(@cell2mat,experimentStructure.dFpreStimWindowAverage, 'Un', 0), 'Un', 0));
    
    experimentStructure.ZScore_FISSA = (maxStimData - prestimMean) ./prestimSD;
    
end

end