function PTBFullScreenContrast(stimTime, ITItime, varargin)

%% set up parameters of stimuli
clc
sca;
% 
% stimTime = 1; %in s
% ITItime = 1;

doNotSendEvents = 0;
if ~isempty(varargin)
    doNotSendEvents = 1;
end


% Should not change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataDir = 'C:\PostDoc Docs\Ca Imaging Project\PTB_Timing_Files\'; % save dir for timing files
timeSave = datestr(now,'yyyymmddHHMMSS');
indentString = 'ContrstFullScreen_';


firstTime =1;
blockNum = 0;
stimCmpEvents = [1 1] ;

greyScales = linspace(0,1,10);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% intial set up of experiment
PsychDefaultSetup(2); % PTB defaults for setup

if doNotSendEvents ==0
    daq =[];
    
    % set up DAQ
    if isempty(daq)
        clear PsychHID;
        daq = DaqDeviceIndex([],0);
    end
end

screenNumber = max(Screen('Screens')); % makes display screen the secondary one

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;

PsychImaging('PrepareConfiguration');

% look into PsychImaging('AddTask', 'General', 'UseGPGPUCompute', apitype [, flags]);???

PsychImaging('AddTask','General', 'FloatingPoint32Bit'); % sets accuracy of frame buffer to 32bit floating point

[windowPtr, ~] = PsychImaging('OpenWindow', screenNumber, grey); %opens screen and sets background to grey


% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', windowPtr);

% Get frame rate fro moving patch
frameRate=Screen('FrameRate',screenNumber);

% Get the number of frames stim needs to be on for
totalNumFramesStim = frameRate * stimTime;
totalNumFramesInterval = frameRate * ITItime;

%% START STIM PRESENTATION
counter =0;
Screen('Preference', 'VisualDebuglevel', 0);

if doNotSendEvents ==0
    % trigger image scan start
    DaqDConfigPort(daq,0,0);
    err = DigiOut(daq, 0, 255, 0.1);
end

while ~KbCheck
    counter = counter+1;
    
    % randomizes the order of the conditions for this block
%     cndOrder = datasample(greyScales(2:end),length(greyScales)-1,'Replace', false); % randomises actual conditions
    cndOrder = datasample(2:length(greyScales),length(greyScales)-1,'Replace', false);
    blockNum = blockNum+1;
    
    for trialCnd = 1:length(cndOrder)
        
        if doNotSendEvents ==0
            AnalogueOutEvent(daq, 'TRIAL_START');
            stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_START');
        end
              
        %display trial conditions
        
        fprintf(['Block No: %i \n'...
            'Condition No: %i \n'...
            '############################################## \n'] ...
            ,blockNum,cndOrder(trialCnd));
        
        if doNotSendEvents ==0
            % send out cnds to imaging comp
            AnalogueOutEvent(daq, 'PARAM_START');
            stimCmpEvents(end+1,:)= addCmpEvents('PARAM_START');
            AnalogueOutCode(daq, blockNum); % block num
            stimCmpEvents(end+1,:)= addCmpEvents(blockNum);
            WaitSecs(0.001);
            AnalogueOutCode(daq, cndOrder(trialCnd)); % condition num
            stimCmpEvents(end+1,:)= addCmpEvents(cndOrder(trialCnd));
            WaitSecs(0.001);
            AnalogueOutEvent(daq, 'PARAM_END');
            stimCmpEvents(end+1,:)= addCmpEvents('PARAM_END');
        end
        
        
        stimOnFlag =1;
        for frameNo =1:totalNumFramesStim
            % draw grating on screen
            %Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
            
            Screen('FillRect', windowPtr,[greyScales(cndOrder(trialCnd)) greyScales(cndOrder(trialCnd)) greyScales(cndOrder(trialCnd))],[]);
            
            if doNotSendEvents ==0
                if stimOnFlag ==1 % only sends stim on at the first draw of moving grating
                    AnalogueOutEvent(daq, 'STIM_ON');
                    stimCmpEvents(end+1,:)= addCmpEvents('STIM_ON');
                    stimOnFlag = 0;
                end
            end
            
            
            % Flip to the screen
            if doNotSendEvents ==0
                AnalogueOutEvent(daq, 'SCREEN_REFRESH');
                stimCmpEvents(end+1,:)= addCmpEvents('SCREEN_REFRESH');
            end
            Screen('Flip', windowPtr);
            
            % Abort requested? Test for keypress:
            if KbCheck
                break;
            end
            
        end
        
        % Abort requested? Test for keypress:
        if KbCheck
            break;
        end
        if doNotSendEvents ==0
            AnalogueOutEvent(daq, 'STIM_OFF');
            stimCmpEvents(end+1,:)= addCmpEvents('STIM_OFF');
        end
        
        % set screen to black for ITI
        for frameNo=1:totalNumFramesInterval
            Screen('FillRect', windowPtr,[0 0 0],[]);
            Screen('Flip', windowPtr);
        end
        
        
        
        if doNotSendEvents ==0
            AnalogueOutEvent(daq, 'TRIAL_END');
            stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_END');
        end
    end
end

%% save things before close
if doNotSendEvents ==0
    saveCmpEventFile(stimCmpEvents, dataDir, indentString, timeSave);
end

% Clear screen
sca;

end