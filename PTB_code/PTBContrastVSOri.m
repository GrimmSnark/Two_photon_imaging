function PTBContrastVSOri(width, stimCenter)
% Experiment which displays moving gratings at 2Hz of different contrast
% and orientation at a defined location


%% set up parameters of stimuli
clc
sca;

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

daq =[];

% set up DAQ
if isempty(daq)
    clear PsychHID;
    daq = DaqDeviceIndex([],0);
end

screenNumber = max(Screen('Screens')); % makes display screen the secondary one
% resolution = Screen('Resolution',screenNumber); %% may give weird result, so hard coding for now
% screenCentre(1) = resolution.width/2;
% screenCentre(2) = resolution.height/2;
screenCentre = [910 785]; % screen centre of Shel 1170 WEIRD, calcualted by physical measurement..


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

% trigger image scan start
DaqDConfigPort(daq,0,0);
err = DigiOut(daq, 0, 255, 0.1);

while ~KbCheck
    counter = counter+1;
    
    % randomizes the order of the conditions for this block
    cndOrder = datasample(1:numCnd,numCnd,'Replace', false);
    blockNum = blockNum+1;
    
    for trialCnd = 1:length(cndOrder)
        
        
        AnalogueOutEvent(daq, 'TRIAL_START');
        stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_START');
        
        
        % Get trial cnds
        trialParams = possibleComb(:,cndOrder(trialCnd))';
        constrastNo = find(contrast==trialParams(2));
        angleNo = find(Angle==trialParams(1));
        
        dstRect = OffsetRect(gratingrect(constrastNo,:), screenStimCentre(1), screenStimCentre(2));
        
        %display trial conditions
        
        fprintf(['Block No: %i \n'...
            'Condition No: %i \n'...
            'Contrast: %.2f Orientation: %i degrees \n'...
            '############################################## \n'] ...
            ,blockNum,cndOrder(trialCnd),trialParams(2), trialParams(1));
        
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
        
        
        stimOnFlag =1;
        for frameNo =1:totalNumFrames
            % Increment phase by cycles/s:
            phase = phase + phaseincrement;
            %create auxParameters matrix
            propertiesMat = [phase, freqPix, contrast(constrastNo), 0];
            
            % draw grating on screen
            %Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
            
            if stimOnFlag ==1 % only sends stim on at the first draw of moving grating
                AnalogueOutEvent(daq, 'STIM_ON');
                stimCmpEvents(end+1,:)= addCmpEvents('STIM_ON');
                stimOnFlag = 0;
            end
            
            Screen('DrawTexture', windowPtr, gratingid(constrastNo), [], dstRect , Angle(angleNo), [], [], [], [], [], propertiesMat' );
            
            % Flip to the screen
            AnalogueOutEvent(daq, 'SCREEN_REFRESH');
            stimCmpEvents(end+1,:)= addCmpEvents('SCREEN_REFRESH');
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
        
        AnalogueOutEvent(daq, 'STIM_OFF');
        stimCmpEvents(end+1,:)= addCmpEvents('STIM_OFF');
        Screen('Flip', windowPtr);
        WaitSecs(ITItime);
        
        AnalogueOutEvent(daq, 'TRIAL_END');
        stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_END');
    end
end

%% save things before close
saveCmpEventFile(stimCmpEvents, dataDir, indentString, timeSave);

% Clear screen
sca;
end

