function experimentStructure = sumStimPerColor(experimentStructure, data2Use, noColors)

noColors = 4;

if data2Use == 1
    data = experimentStructure.dFperCnd;
    dataTag = '';
elseif data2Use == 2
    data = experimentStructure.dFperCndFBS;
    dataTag = 'FBS';
end

% get the sum per cnd
for p = 1:experimentStructure.cellCount % for each cell
    for  x =1:length(experimentStructure.cndTotal) % for each condition
        
        %full trial prestimON-trialEND cell cnd trial
        trialSum = sum(data{p}{x}(experimentStructure.stimOnFrames(1):experimentStructure.stimOnFrames(2),:),1); %chunks data and sorts into structure
        cndSumStd{p}(x) = std(trialSum);
        cndSumMean{p}(x) = mean(trialSum);
        cndSumSum{p}(x) = sum(trialSum);
    end
    
    %reshape into L M S x Orientations
    cndSumStd{p} = reshape(cndSumStd{p},[], noColors)';
    cndSumMean{p} = reshape(cndSumMean{p},[], noColors)';
    cndSumSum{p} = reshape(cndSumSum{p},[], noColors)';
end


eval(['experimentStructure.cndSumStd' dataTag ' = cndSumStd;']);
eval(['experimentStructure.cndSumMean' dataTag ' = cndSumMean;']);
eval(['experimentStructure.cndSumSum' dataTag ' = cndSumSum;']);


%% Save the updated experimentStructure
save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure');

end