function PTBContrastVSOri(width, stimCenter, varargin)
% Experiment which displays moving gratings at 2Hz of different contrast
% and orientation at a defined location


%% set up parameters of stimuli
clc
sca;


doNotSendEvents = 0;
if ~isempty(varargin)
    doNotSendEvents = 1;
end


% Should not change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataDir = 'C:\PostDoc Docs\Ca Imaging Project\PTB_Timing_Files\'; % save dir for timing files
timeSave = datestr(now,'yyyymmddHHMMSS');
indentString = 'ContrstOrient_';

stimTime = 1; %in s
ITItime = 1;
firstTime =1;
blockNum = 0;
stimCmpEvents = [1 1] ;

phase = 0;
backgroundColorOffset = [0.5 0.5 0.5 0]; %RGBA offset color

%Stimulus
%width = 10; % in degrees visual angle
widthInPix = degreeVisualAngle2Pixels(1,width);
heightInPix =widthInPix;
radius=widthInPix/2; % circlar apature in pixels

freq = 0.5 ; % in cycles per degree
freq = 1/freq; % hack hack hack
freqPix = degreeVisualAngle2Pixels(1,freq);
freqPix =1/freqPix; % use the inverse as the function below takes bloody cycles/pixel...

cyclespersecond =2; % temporal frequency to stimulate all cells
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

contrast = [0.2 0.4 0.6 0.8 1] ; % should already be set by the sine grating creation??
Angle =[0 45 90 125]; % angle in degrees

possibleComb = combvec(Angle,contrast);
numCnd = length(possibleComb);

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
% Get the size of the on screen window
% [screenXpixels, screenYpixels] = Screen('WindowSize', windowPtr); % uncomment for your setup

screenXpixels = 1915; % hard coded cause reasons.. weird screens % comment out for your setup
screenYpixels = 1535;

screenCentre = [0.5 * screenXpixels , 0.5 * screenYpixels]; % screen centre of Shel 1170 WEIRD, calcualted by physical measurement...
% Set up relative stim centre based on degree visual angle

screenStimCentreOffset(1) = degreeVisualAngle2Pixels(1,stimCenter(1));
screenStimCentreOffset(2) = degreeVisualAngle2Pixels(1,stimCenter(2));

screenStimCentre = screenCentre + screenStimCentreOffset;

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;

PsychImaging('PrepareConfiguration');

% look into PsychImaging('AddTask', 'General', 'UseGPGPUCompute', apitype [, flags]);???

PsychImaging('AddTask','General', 'FloatingPoint32Bit'); % sets accuracy of frame buffer to 32bit floating point

[windowPtr, ~] = PsychImaging('OpenWindow', screenNumber, grey); %opens screen and sets background to grey

%create all gratings on GPU.....should be very fast
for i = 1:length(contrast) % for each contrast
    [gratingid(i), gratingrect(i,:)] = CreateProceduralSineGrating(windowPtr, widthInPix, heightInPix, backgroundColorOffset, radius, contrast(i));
end

% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', windowPtr);

% Get frame rate fro moving patch
frameRate=Screen('FrameRate',screenNumber);

% Get the number of frames stim needs to be on for
totalNumFrames = frameRate * stimTime;

% Compute increment of phase shift per redraw:
phaseincrement = (cyclespersecond * 360) * ifi;

%% START STIM PRESENTATION
counter =0;

if doNotSendEvents ==0
    % trigger image scan start
    DaqDConfigPort(daq,0,0);
    err = DigiOut(daq, 0, 255, 0.1);
end

while ~KbCheck
    counter = counter+1;
    
    % randomizes the order of the conditions for this block
    cndOrder = datasample(1:numCnd,numCnd,'Replace', false);
    blockNum = blockNum+1;
    
    for trialCnd = 1:length(cndOrder)
        
        if doNotSendEvents ==0
            AnalogueOutEvent(daq, 'TRIAL_START');
            stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_START');
        end
        
        % Get trial cnds
        trialParams = possibleComb(:,cndOrder(trialCnd))';
        constrastNo = find(contrast==trialParams(2));
        angleNo = find(Angle==trialParams(1));
        
        dstRect = OffsetRect(gratingrect(constrastNo,:), screenStimCentre(1)-radius, screenStimCentre(2)-radius);
        
        %display trial conditions
        
        fprintf(['Block No: %i \n'...
            'Condition No: %i \n'...
            'Contrast: %.2f Orientation: %i degrees \n'...
            '############################################## \n'] ...
            ,blockNum,cndOrder(trialCnd),trialParams(2), trialParams(1));
        
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
        for frameNo =1:totalNumFrames
            % Increment phase by cycles/s:
            phase = phase + phaseincrement;
            %create auxParameters matrix
            propertiesMat = [phase, freqPix, contrast(constrastNo), 0];
            
            % draw grating on screen
            %Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
            
            Screen('DrawTexture', windowPtr, gratingid(constrastNo), [], dstRect , Angle(angleNo), [], [], [], [], [], propertiesMat' );
            
            if doNotSendEvents ==0
                if stimOnFlag ==1 % only sends stim on at the first draw of moving grating
                    AnalogueOutEvent(daq, 'STIM_ON');
                    stimCmpEvents(end+1,:)= addCmpEvents('STIM_ON');
                    stimOnFlag = 0;
                end
            end
            
%             Screen('DrawDots', windowPtr, screenCentre, [5], [1 0 0], [] , [], []); % Fixation/ screen centre spot
            
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
        Screen('Flip', windowPtr);
        WaitSecs(ITItime);
        
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

