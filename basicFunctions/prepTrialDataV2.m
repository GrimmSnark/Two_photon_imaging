function experimentStructure = prepTrialDataV2(experimentStructure, dataFilepathPrairie, experimentType)



%% initalise stuff

codes = prairieCodes();
sizeIndMax =0;

essentialEvents ={'TRIAL_START', 'PARAM_START', 'PARAM_END', 'TRIAL_END'}; %list of essential events for valid trial
essentialEventsNum = stringEvent2Num(essentialEvents, codes);


eventArray = readEventFilePrairieV2(dataFilepathPrairie, []); % read in events file

%% if path to PTB file is set check consistency between set and recorded events
PTBPath = dir([experimentStructure.prairiePath '*.mat']);

% find index of stimParams mat
indexCell = strfind({PTBPath.name}, 'stimParams');
indexOfStimParams = find(~cellfun(@isempty,indexCell));

% copy stimParams to experimentStructure
load(fullfile(PTBPath(indexOfStimParams).folder, PTBPath(indexOfStimParams).name));
experimentStructure.stimParams = stimParams;

% clear entry
PTBPath(indexOfStimParams) = [];

if ~isempty(PTBPath)
    experimentStructure.PTB_TimingFilePath = [PTBPath.folder '\' PTBPath.name ];
    [eventArray, PTBeventArray ]= checkConsistency(eventArray, experimentStructure.PTB_TimingFilePath);
end

%% Proceed with trial event segementation
eventStream = eventArray;

% use trial end events to chunk up into individual trials
endIndx = findEvents('TRIAL_END', eventStream, codes); % get trial end event times
endArray = eventStream(endIndx,:);
endIndxNum = find(endIndx);
rawTrials  = cell([length(endIndxNum),1]);

%% splits up raw trial events
for i =1:length(endIndxNum)
    if i==1
        rawTrials{i,1} = eventStream(1:endIndxNum(i),:);
    else
        rawTrials{i,1} = eventStream(endIndxNum(i-1)+1:endIndxNum(i),:);
    end
end

%% check event numbers the same size
numEventsPerTrial = arrayfun(@(I) size(rawTrials{I,1},1), 1:length(rawTrials));
diffRange = range(numEventsPerTrial);

if diffRange ~= 0
    disp('Event numbers do not match across trials.....');
    misfitTrials = find(numEventsPerTrial ~= median(numEventsPerTrial));
    
    disp(['Trial(s) no. ' num2str(misfitTrials) ' not the correct size, attempting to fix...']);
end

%check trial has all the codes for a valid trial
for k = 1:numel(rawTrials)
    numOfEssentialEvents(k) = recursiveSum((rawTrials{k}(:,2) == essentialEventsNum));
end

validTrial = numOfEssentialEvents==length(essentialEventsNum); % indx of valid trial by event inclusion

%% If the number of essential events in a trial is higher than the supposed
% number it may be that the condition code is the same as one of the
% essential events. Try to fix this
trialsToFix = [];
trialsToFix = find(numOfEssentialEvents>length(essentialEventsNum));

if ~isempty(trialsToFix)
    for q = trialsToFix % for each trial to fix
        for currentEvent = essentialEventsNum% for each essential event
            indexOfEvent = find(rawTrials{q}(:,2)==currentEvent); % find index of events in question
            
            if length(indexOfEvent) > 1 % if multiple essential event numbers found, try to see if one of them is a condition code
                [~,paramStIndx] = findEvents('PARAM_START',rawTrials{q,1},codes);
                [~,paramStopIndx] = findEvents('PARAM_END',rawTrials{q,1},codes);
                
                for f = length(indexOfEvent) % for each instance of the event
                    if indexOfEvent(f)> paramStIndx(1) && indexOfEvent(f)< paramStopIndx(end) % check if it is a block or condition number
                        validTrial(q) = 1; % declares trial valid again
                    end
                end
            end
        end
    end
end

disp([num2str(sum(validTrial)) ' / '  num2str(length(validTrial)) ' trials have valid condition codes!!!']);

%% try to fix invalid trials
if any(validTrial==0)
    for x =1: length(essentialEventsNum) % get essential event identities from PTB events
        essentialEventLocPTB(x,:) = find(PTBeventArray == essentialEventsNum(x));
    end
    
    paramStartCode = stringEvent2Num('PARAM_START', codes);
    [~,paramStartPosition] = find(essentialEventsNum == paramStartCode);
    invalidTrials = find(validTrial==0); % get invalid trial No
    
    for i = invalidTrials % for each trial
        disp(['Fixing essential event error in Trial No. ' num2str(i) ' ...']);
        trialEssentialEventLocPTB = essentialEventLocPTB(:,invalidTrials(i)); % get PTB locations for current trial essential events
        
        for z = 1:length(essentialEventsNum) % for each event
            if any(rawTrials{invalidTrials,1}(:,2) ~= essentialEventsNum(z)) % if can not find event in current trial
                [~, erroredIndx] = min(abs(rawTrials{invalidTrials,1}(:,2)- essentialEventsNum(z))); % find mismatched index
                rawTrials{invalidTrials,1}(erroredIndx,2) = essentialEventsNum(z); % set the mismatched event to the appropriate one
            end
        end
        
        % fix block/cnd codes
        paramStartIndx = find(rawTrials{invalidTrials,1}(:,2) == paramStartCode); % get the indx for param start in eventArray
        rawTrials{invalidTrials,1}(paramStartIndx+1,2) = PTBeventArray(trialEssentialEventLocPTB(paramStartPosition)+1); % set the block (param start +1) to PTB block code
        rawTrials{invalidTrials,1}(paramStartIndx+2,2) = PTBeventArray(trialEssentialEventLocPTB(paramStartPosition)+2); % set the condition (param start +2) to PTB condition code
        
        % reset valid flag for this trial to true
        validTrial(i) = 1;
    end
end

%% extract stimulus conditions for each valid trial

block = zeros(length(validTrial),2);
cnd = block;

nonEssentialCodes = zeros(max(cellfun('size', rawTrials, 1)),2,length(validTrial));
for i =1:length(validTrial)
    if validTrial(i) ==1 % only for valid trials
        
        if strcmp(experimentType, 'RFmap') % for RF_map experiment, we have different structure of conditions
            RF_stream(:,:,i) =  rawTrials{i,1}(find(findEvents('PARAM_START',rawTrials{i,1},codes))+1:find(findEvents('PARAM_END',rawTrials{i,1},codes))-1,:);
        else % for any experiment that is not RF mapping
            block(i,:) = rawTrials{i,1}(find(findEvents('PARAM_START',rawTrials{i,1},codes))+1,:); % finds block num and timestamp for all valid trials
            cnd(i,:) = rawTrials{i,1}(find(findEvents('PARAM_START',rawTrials{i,1},codes))+2,:); % finds condition num and timestamp for all valid trials
        end
        
        nonEssentialIndStart = find(findEvents('PARAM_END',rawTrials{i,1},codes))+1; % gets the index for the event just after PARAM_END
        nonEssentialIndEnd = find(findEvents('TRIAL_END',rawTrials{i,1},codes)); % gets the index for TRIAL_END
        
        sizeInd = nonEssentialIndEnd-nonEssentialIndStart+1; % gets length of vector to come
        
        if sizeInd>sizeIndMax % max vector length across trials
            sizeIndMax = sizeInd;
        end
        nonEssentialCodes(1:sizeInd,:,i) = rawTrials{i,1}(nonEssentialIndStart:nonEssentialIndEnd,:); % gets all the non essential trial events into an array
    end
end

% get total number of each condition presented
cndTotal = zeros(max(cnd(:,2)),1);
for i=1:max(cnd(:,2))
    cndTotal(i) = length(cnd(cnd(:,2)==i,2));
end

% get timestamps and lists for all during trial events (ie after
% PARAM_END
nonEssentialCodes= nonEssentialCodes(1:sizeIndMax,:,:);
nonEssentialEventNumbers = unique(nonEssentialCodes(:,2,:));

% remove zeros and any not used events.... this may cause errors if you
% do not keep prairieCodes.m updated  with any changes in event usage
nonEssentialEventNumbers(nonEssentialEventNumbers ==0) = [];

checkEventUsage = false(length(nonEssentialEventNumbers),1);
for x = 1:length(nonEssentialEventNumbers)
    if ~isempty(codes{nonEssentialEventNumbers(x)})
        checkEventUsage(x) = true;
    end
end
nonEssentialEventNumbers = nonEssentialEventNumbers(checkEventUsage);


for i =1:length(nonEssentialEventNumbers)
    nonEssentialEvent{1,i}= codes{nonEssentialEventNumbers(i)};
    
    indexOfCodes = nonEssentialCodes == (nonEssentialEventNumbers(i));
    indexOfTimes = circshift(indexOfCodes,-1,2);
    indexOfBoth= logical(indexOfCodes+indexOfTimes);
    
    try
        nonEssentialEvent{2,i}= reshape(nonEssentialCodes(indexOfBoth),[],2,size(nonEssentialCodes,3)); % if all goes well reshapes array
    catch
        %% Second step fixes if needed
        % if there has been some weirdness, not all the same number of events in each trial
        disp('Trying to fix irrational event timing issues');
        
        % finds the trials that have non matching number of events
        for q = 1:size(indexOfBoth,3) % for each trial
            trialSumEvents(q) = sum(indexOfBoth(:,1,q));
        end
        
        %         trialEventAverage = floor(mean(trialSumEvents)); % finds the correct number of a particular event in each trial
        trialEventAverage = mode(trialSumEvents); % finds the correct number of a particular event in each trial
        
        
        if trialEventAverage==0 % if calculates zero, corrects to one
            trialEventAverage = ceil(mean(trialSumEvents));
        end
        
        indexOfMismatchedTrials = find(trialSumEvents~=trialEventAverage);
        
        % for each mismatched trial tries to find the out of place
        % event by running through the timings
        for z = 1:length(indexOfMismatchedTrials)
            % gets mismatched trial
            currentTrial= nonEssentialCodes(:,:,indexOfMismatchedTrials(z));
            
            % gets index of events of interest and  corresponding
            % timestamps
            currentIndexOfCodes = currentTrial == (nonEssentialEventNumbers(i));
            currentIndexOfTimes = circshift(currentIndexOfCodes,-1,2);
            
            % gets the timestamps and works out if any are duplicated
            % and irrational timescale
            currentTrialEventTimes = currentTrial(currentIndexOfTimes);
            timeBetweenEvents = currentTrialEventTimes(2:end) - currentTrialEventTimes(1:end-1);
            meanTimeBetweenEvents = mean(timeBetweenEvents);
            stdTimeBetweenEvents = std2(timeBetweenEvents);
            indexOfOddTimesOut = find(timeBetweenEvents < (meanTimeBetweenEvents - 10*stdTimeBetweenEvents));
            indexOfOddTimesOut = indexOfOddTimesOut+1;
            
            % deletes these irrational events from the array
            for b =1:length(indexOfOddTimesOut)
                indexOfBoth(indexOfOddTimesOut(b),:,indexOfMismatchedTrials(z)) = [0 0];
            end
            
            % check number of events has been fixed
            counter = 0;
            while sum(indexOfBoth(:,2,indexOfMismatchedTrials(z))) ~= trialEventAverage
                disp('Trying to fix miscoded event entries');
                
                if counter == 5 % if we get too far from intended signal leave loop
                    break
                end
                
                % assume event number got detected as one less that
                % used, ie 140 sent, 139 detected
                counter = counter +1;
                currentEventTry = nonEssentialEventNumbers(i)-counter;
                
                % get index of miscoded values
                currentIndexOfCodesFIX = currentTrial == currentEventTry;
                currentIndexOfTimesFIX = circshift(currentIndexOfCodesFIX,-1,2);
                indexOfBothFIX= logical(currentIndexOfCodesFIX+currentIndexOfTimesFIX);
                
                % change miscoded values
                index2Use = find(currentIndexOfCodesFIX);
                [rows2Fix, cols2Fix] = ind2sub(size(currentIndexOfCodesFIX), index2Use);
                nonEssentialCodes(rows2Fix,cols2Fix,indexOfMismatchedTrials(z))= nonEssentialEventNumbers(i);
                indexOfBoth(rows2Fix,:,indexOfMismatchedTrials(z)) = 1;
                
                
                
                % if we still are not finding the correct number of
                % events FIX v2
                if sum(indexOfBoth(:,2,indexOfMismatchedTrials(z))) ~= trialEventAverage
                    % assume event number got detected as one less that
                    % used, ie 140 sent, 141 detected
                    currentEventTry = nonEssentialEventNumbers(i)+counter;
                    
                    % get index of miscoded values
                    currentIndexOfCodesFIX = currentTrial == currentEventTry;
                    currentIndexOfTimesFIX = circshift(currentIndexOfCodesFIX,-1,2);
                    indexOfBothFIX= logical(currentIndexOfCodesFIX+currentIndexOfTimesFIX);
                    
                    % change miscoded values
                    index2Use = find(currentIndexOfCodesFIX);
                    [rows2Fix, cols2Fix] = ind2sub(size(currentIndexOfCodesFIX), index2Use);
                    nonEssentialCodes(rows2Fix,cols2Fix,indexOfMismatchedTrials(z))= nonEssentialEventNumbers(i);
                    indexOfBoth(rows2Fix,:,indexOfMismatchedTrials(z)) = 1;
                    
                end
            end
        end
        nonEssentialEvent{2,i}= reshape(nonEssentialCodes(indexOfBoth),[],2,size(nonEssentialCodes,3)); % if all goes well reshapes array
    end
end

%% build trial condition structure
experimentStructure.rawTrials = rawTrials;
experimentStructure.validTrial = validTrial;
experimentStructure.cndTotal = cndTotal;

if any(cnd)
    experimentStructure.block = block;
    experimentStructure.cnd = cnd;
    
    cnd = cnd(:,2);
    for i=1:length(cndTotal)
        cndTrials{i} = find(cnd == i)';
    end
    experimentStructure.cndTrials = cndTrials;
end

if exist('RF_stream')
    experimentStructure.RF_stream = RF_stream;
end

experimentStructure.nonEssentialEvent= nonEssentialEvent;

%% align events to frame times and numbers

for i =1:length(experimentStructure.nonEssentialEvent)
    experimentStructure = alignEvents2Frames(experimentStructure.nonEssentialEvent{1,i}, experimentStructure);
end

end