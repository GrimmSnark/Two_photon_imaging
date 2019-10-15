function [meanCorr , corrMatrixUnique]= meanPairwiseSpontaneousCorrelation(experimentStructure, FBSorFISSA)

% get data
if FBSorFISSA == 1
   dataCells =   cellfun(@cell2mat,experimentStructure.dFpreStimWindowAverageFBS, 'Un', 0);
   
elseif FBSorFISSA ==2
    dataCells =   cellfun(@cell2mat,experimentStructure.dFpreStimWindowAverage, 'Un', 0);
end

% reshape into timepoint x cell array
for i = 1:experimentStructure.cellCount
   data(:,i) = reshape(dataCells{i},[],1); 
end

% get unique pairs
includeMatEye = eye(experimentStructure.cellCount); % get identity matrix the size of corr matrix
[r, c] = find(circshift(includeMatEye, -1)); % get rows and columns for top half of matrix
includeMat = zeros(length(includeMatEye)); % create blank matrix

% create inclusion matrix
for s = 1:size(includeMat,1)-1
    includeMat(s,c(s+1):end) =1;
end
includeMat = logical(includeMat);

% get correlations
corrMatrix = corr(data);
corrMatrixUnique = corrMatrix(includeMat); % restrict to unique pairs

meanCorr = mean(corrMatrixUnique); % get mean correlations
end