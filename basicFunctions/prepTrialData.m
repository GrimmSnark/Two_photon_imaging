function experimentStructure = prepTrialData(experimentStructure, dataFilepathPrairie, checkFile, dataFilepathPTB, experimentType)
% loads and preprocesses the prairie event data into the experiment
% structure, will all check consistency between the prairie file and the
% PTB event file
% Filepaths are self explanatory, only include PTB path if the checkFile
% flag is set to 1
% isRFmap flag should only be set to 1 if the experiment to be loaded is a
% RFmapping (processes conditions differently
% code outputs experiment structure with all the data in it

%% initalise stuff

check =[];
codes = prairieCodes();
sizeIndMax =0;

essentialEvents ={'TRIAL_START', 'PARAM_START', 'PARAM_END', 'TRIAL_END'};
essentialEventsNum = stringEvent2Num(essentialEvents, codes);


eventArray = readEventFilePrairie(dataFilepathPrairie, []); % read in events file

%% if flag is set check consistency between set and recorded events
if checkFile ==1
    check = checkConsistency(eventArray, dataFilepathPTB);
end

%% Proceed with trial event segementation
if isempty(check) % if no disputes
    eventStream = eventArray;
    %eventStream(:,1) = eventStream(:,1)-eventStream(1,1); % zero all timestamps
    
    % use trial end events to chunk up into individual trials
    endIndx = findEvents('TRIAL_END', eventStream, codes); % get trial start event times
    endArray = eventStream(endIndx,:);
    endIndxNum = find(endIndx);
    rawTrials  = cell([length(endIndxNum),1]);
    
    for i =1:length(endIndxNum)
        if i==1
            rawTrials{i,1} =   eventStream(1:endIndxNum(i),:);
        else
            rawTrials{i,1} =   eventStream(endIndxNum(i-1)+1:endIndxNum(i),:);
        end
    end
    
    %check trial has all the codes for a valid trial
    
    numOfEvents = zeros(length(rawTrials),1);
    for k = 1:numel(rawTrials)
        numOfEvents(k) = recursiveSum((rawTrials{k}(:,2) == essentialEventsNum));
    end
    
    %if there are any duplicates in the essential events conditions
    if any(numOfEvents > length(essentialEventsNum))
        trialsToFix = find(numOfEvents > length(essentialEventsNum));
        
        for v = 1:length(trialsToFix) % for each trial to fix find the number of occurances of each event (Should only be 1)
            for u = 1:length(essentialEventsNum)
                numOccurance(u) = sum(rawTrials{trialsToFix(v),1}(:,2)==essentialEventsNum(u));
            end
            
            % if there are duplicates of single occurnace events, deletes the
            % latest
            eventsDuplicated = essentialEventsNum(numOccurance>1);
            
            for o =1:length(eventsDuplicated)
                ind2Delete =  find(rawTrials{trialsToFix(v),1}(:,2) == eventsDuplicated(o),1,'last');
                rawTrials{trialsToFix(v),1}(ind2Delete,:) = [];
            end
        end
        
        % recheck the number of essential events in each trial
        for k = 1:numel(rawTrials)
            numOfEvents(k) = recursiveSum((rawTrials{k}(:,2) == essentialEventsNum));
        end
    end
    
    
    validTrial = numOfEvents==length(essentialEventsNum); % indx of valid trial by event inclusion
    disp([num2str(sum(validTrial)) ' / '  num2str(length(validTrial)) ' trials have valid condition codes!!!']);
    
    % extract stimulus conditions for each valid trial
    
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
        catch % if there has been some weirdness, not all the same number of events in each trial
            
            % finds the trials that have non matching number of events
            for q = 1:size(indexOfBoth,3) % for each trial
                trialSumEvents(q) = sum(indexOfBoth(:,1,q));
            end
            
            trialEventAverage = floor(mean(trialSumEvents));
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
            end
            nonEssentialEvent{2,i}= reshape(nonEssentialCodes(indexOfBoth),[],2,size(nonEssentialCodes,3)); % if all goes well reshapes array
        end
    end
    
else % if any disputes
    exit;
end

%% build trial condition structure
% experimentStructure.prairiePath = dataFilepathPrairie(1:find(dataFilepathPrairie=='\',1,'last'));
% experimentStructure.prairieEventPath = dataFilepathPrairie;
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