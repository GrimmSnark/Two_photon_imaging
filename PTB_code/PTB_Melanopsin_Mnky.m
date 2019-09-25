function PTB_Melanopsin_Mnky(numCnd, preStimTime, stimTime, postStimTime, numReps, varargin)


%% set up parameters of stimuli
doNotSendEvents = 0;

if ~isempty(varargin)
    doNotSendEvents = 1;
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataDir = 'C:\PostDoc Docs\Ca Imaging Project\PTB_Timing_Files\'; % save dir for timing files
timeSave = datestr(now,'yyyymmddHHMMSS');
indentString = 'MelanopsinMnky_';

stimCmpEvents = [1 1] ;

levels = linspace(65535,0,numCnd+1);
levelStim = levels(2:end);


% Add stim parameters to structure for saving
stimParams.preStimTime = preStimTime;
stimParams.stimTime = stimTime;
stimParams.postStimTime = postStimTime;
stimParams.numReps = numReps;
stimParams.numCnd = numCnd;
stimParams.levelStim = levelStim;


if doNotSendEvents ==0
    save([dataDir 'stimParams_' timeSave '.mat'], 'stimParams');
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display total experiment predicted time and query continue.....

lengthofTrial = preStimTime + stimTime + postStimTime;
totalTrialNo = (numCnd*2) * numReps;
totalTime = lengthofTrial * totalTrialNo;

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp('');
disp(['This experiment will take approx. ' num2str(totalTime) 's (' num2str(totalTime/60) ' minutes)']);
disp('If you want to procceed press SPACEBAR, if you want to CANCEL, pres ESC');
disp('');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

[secs, keyCode, deltaSecs] = KbWait([],2, inf);

keypressNo = find(keyCode);

if keypressNo == 27 % ESC code = 27
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initial set up of experiment
ardBoard = serial('COM3', 'BaudRate', 9600,'Terminator','CR/LF');
fopen(ardBoard);

if doNotSendEvents ==0
    daq =[];
    % set up DAQ
    if isempty(daq)
        clear PsychHID;
        daq = DaqDeviceIndex([],0);
    end
end


%% start experiment

experimentStartTime = tic;
for currentBlkNum = 1:numReps
    counter = 0;
    for trialCnd = 1:length(levelStim)
        for channel = 9:10
            counter = counter +1;
            % get current time till estimated finish
            currentTimeUsed = toc(experimentStartTime);
            timeLeft = (totalTime - currentTimeUsed)/60;
            
            if channel == 9
                channelText = 'Blue';
            elseif channel == 10
                channelText = 'Red';
            end
            
            if doNotSendEvents ==0
                AnalogueOutEvent(daq, 'TRIAL_START');
                stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_START');
            end
            
            
            %display trial conditions
            
            fprintf(['Block No: %i of %i \n'...
                'Condition No: %i of %i \n' ...
                'LED Color: %s \n' ...
                'Intensity: %d \n'...
                'Estimated Time to Finish = %.1f minutes \n' ...
                '############################################## \n'] ...
                ,currentBlkNum, numReps, counter, length(levelStim)*2, channelText, levelStim(trialCnd),  timeLeft);
            
            
            
            if doNotSendEvents ==0
                % send out cnds to imaging comp
                AnalogueOutEvent(daq, 'PARAM_START');
                stimCmpEvents(end+1,:)= addCmpEvents('PARAM_START');
                AnalogueOutCode(daq, currentBlkNum); % block num
                stimCmpEvents(end+1,:)= addCmpEvents(currentBlkNum);
                WaitSecs(0.001);
                AnalogueOutCode(daq, trialCnd); % condition num
                stimCmpEvents(end+1,:)= addCmpEvents(trialCnd);
                WaitSecs(0.001);
                AnalogueOutEvent(daq, 'PARAM_END');
                stimCmpEvents(end+1,:)= addCmpEvents('PARAM_END');
            end
            
            if doNotSendEvents ==0
                AnalogueOutEvent(daq, 'PRESTIM_ON');
                stimCmpEvents(end+1,:)= addCmpEvents('PRESTIM_ON');
            end
            
            WaitSecs(preStimTime);
            
            if doNotSendEvents ==0
                AnalogueOutEvent(daq, 'PRESTIM_OFF');
                stimCmpEvents(end+1,:)= addCmpEvents('PRESTIM_OFF');
            end
            
            if doNotSendEvents ==0
                AnalogueOutEvent(daq, 'STIM_ON');
                stimCmpEvents(end+1,:)= addCmpEvents('STIM_ON');
            end
            
            melanopsinStimON(ardBoard, channel ,levelStim(trialCnd),stimTime*1000);
            
            if doNotSendEvents ==0
                AnalogueOutEvent(daq, 'STIM_OFF');
                stimCmpEvents(end+1,:)= addCmpEvents('STIM_OFF');
            end
            
            WaitSecs(postStimTime);
            
            if doNotSendEvents ==0
                AnalogueOutEvent(daq, 'TRIAL_END');
                stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_END');
            end
        end
    end
end

toc(experimentStartTime);

fclose(ardBoard);
clear ardBoard

%% save things before close
if doNotSendEvents ==0
    saveCmpEventFile(stimCmpEvents, dataDir, indentString, timeSave);
end

end