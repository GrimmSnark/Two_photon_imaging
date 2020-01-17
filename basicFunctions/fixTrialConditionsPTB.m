function experimentStructure = fixTrialConditionsPTB(experimentStructure)
% Fix the trial events by loading all event codes from the PTB_event file

load(experimentStructure.PTB_TimingFilePath);
codes = prairieCodes();

PTBevents = cellfun(@str2double,stimCmpEvents(2:end,:));
PTBcodes = PTBevents(:,2);

paramStartCode = stringEvent2Num('PARAM_START', codes);
paramStartPosition = find(PTBcodes == paramStartCode);

for i = 1:length(paramStartPosition) % for each trial
    disp(['Fixing essential event error in Trial No. ' num2str(i) ' ...']);

    % fix block/cnd codes
    paramStartIndx = find(experimentStructure.rawTrials{i,1}(:,2) == paramStartCode); % get the indx for param start in eventArray
    experimentStructure.rawTrials{i,1}(paramStartIndx+1,2) = PTBcodes(paramStartPosition(i)+1); % set the block (param start +1) to PTB block code
    experimentStructure.rawTrials{i,1}(paramStartIndx+2,2) = PTBcodes(paramStartPosition(i)+2); % set the condition (param start +2) to PTB condition code
    
    experimentStructure.block(i,:) = experimentStructure.rawTrials{i,1}(find(findEvents('PARAM_START',experimentStructure.rawTrials{i,1},codes))+1,:); % finds block num and timestamp for all valid trials
    experimentStructure.cnd(i,:) = experimentStructure.rawTrials{i,1}(find(findEvents('PARAM_START',experimentStructure.rawTrials{i,1},codes))+2,:); % finds condition num and timestamp for all valid trials  
end

for x = 1:max(experimentStructure.cnd(:,2))
    experimentStructure.cndTrials{x} = find(experimentStructure.cnd(:,2) == x)';
end

experimentStructure.cndTotal = cellfun(@length, experimentStructure.cndTrials)';

end