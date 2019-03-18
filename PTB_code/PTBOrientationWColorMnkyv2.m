function PTBOrientationWColorMnkyv2(width, stimCenter, preStimTime, stimTime, rampTime, blendDistance , numReps, varargin)
% Experiment which displays static sinsoidal gratings
%
% options:  width - (degrees) for full screen leave blank
%           stimCenter - [0,0] (degrees visual angle from screen center)
%           preStimTime - pre stimulus spontaneous activity period (in
%                         seconds)
%           stimTime - stim time (seconds)
%           rampTime - ramp time added on and off for stimulus (seconds)
%           blendDistance - guassian blur window (degrees)
%           numReps - (number of blocks of all stim repeats, if blank is infinite)
%           varargin (if filled DOES NOT send events out via DAQ)


%% set up parameters of stimuli
clc
sca;


doNotSendEvents = 0;
fullfieldStim = 0;

if ~isempty(varargin)
    doNotSendEvents = 1;
end

if isempty(numReps)
    numReps = 100;
end

if isempty(width)
    fullfieldStim =1;
    width = 0;
end

if isempty(rampTime)
    rampTime = 0;
end

% Should not change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataDir = 'C:\PostDoc Docs\Ca Imaging Project\PTB_Timing_Files\'; % save dir for timing files
timeSave = datestr(now,'yyyymmddHHMMSS');
indentString = 'OrientationWColorMnky_';

% stimTime = 1; %in s
ITItime = 2; % intertrial interval in seconds
% firstTime =1;
blockNum = 0;
stimCmpEvents = [1 1] ;

phase = 0;

% Color offsets for similar energy (specific for screen)
redMax = 1;
greenMax = 0.7255;
% greenMax = 1;
blueMax = 1;

backgroundRed = redMax/2;
backgroundGreen = greenMax/2;
backgroundBlue = blueMax/2;

backgroundColorOffsetCy = [backgroundRed backgroundGreen backgroundBlue 1]; %RGBA offset color
%Stimulus
%width = 10; % in degrees visual angle
widthInPix = degreeVisualAngle2Pixels(1,width);
heightInPix =widthInPix;
radius=widthInPix/2; % circlar apature in pixels

blendDistancePixels = degreeVisualAngle2Pixels(1,blendDistance);


%spatial frequency
freq = 2 ; % in cycles per degree
freq = 1/freq; % hack hack hack
freqPix = degreeVisualAngle2Pixels(1,freq);
freqPix =1/freqPix; % use the inverse as the function below takes bloody cycles/pixel...

cyclespersecond =4; % temporal frequency to stimulate all cells (in Hz)
contrast =  1; % contrast for grating

% set up color and orientation levels
colorLevels = rand(10 ,3);
orientations = [0 :15:165];
Angle =repmat(orientations,[1 size(colorLevels, 1)]); % angle in degrees x number of colors

numCnd = length(Angle); % conditions = angle x colors

% make balanced numbers of left/right start movement stims
nOfDirectionPerOrien = length(orientations)/2;
directionStartPerOrientation = zeros(1, length(orientations));
directionStartPerOrientation(randperm(numel(directionStartPerOrientation), nOfDirectionPerOrien)) = 1;

%covert to logical
directionStartPerOrientation = logical(directionStartPerOrientation);

% get inverse for next colour
directionStartPerOrientation2 = ~directionStartPerOrientation;

directionStartPerOrientation = [directionStartPerOrientation; directionStartPerOrientation2];

blockMovementsBalanced = repmat(directionStartPerOrientation,length(colorLevels)/2,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% intial set up of experiment
Screen('Preference', 'VisualDebugLevel', 1); % removes welcome screen
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
[screenXpixels, screenYpixels] = Screen('WindowSize', screenNumber); % uncomment for your setup

screenCentre = [0.5 * screenXpixels , 0.5 * screenYpixels];
% Set up relative stim centre based on degree visual angle

screenStimCentreOffset(1) = degreeVisualAngle2Pixels(1,stimCenter(1));
screenStimCentreOffset(2) = degreeVisualAngle2Pixels(1,stimCenter(2));

screenStimCentre = screenCentre + screenStimCentreOffset;

PsychImaging('PrepareConfiguration');
PsychImaging('AddTask','General', 'FloatingPoint32Bit'); % sets accuracy of frame buffer to 32bit floating point

% look into PsychImaging('AddTask', 'General', 'UseGPGPUCompute', apitype [, flags]);???


[windowPtr, ~] = PsychImaging('OpenWindow', screenNumber, [ backgroundColorOffsetCy(1:3) ] ); %opens screen and sets background to grey


%create all gratings on GPU.....should be very fast
if fullfieldStim ==0
    [gratingid, gratingrect] = CreateProceduralSquareWaveGrating(windowPtr, widthInPix, heightInPix, backgroundColorOffsetCy, [], contrast);
else
    [gratingid, gratingrect] = CreateProceduralSquareWaveGrating(windowPtr, screenXpixels*1.5, screenXpixels*1.5, backgroundColorOffsetCy, [], contrast);
end


% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', windowPtr);


% Compute increment of phase shift per redraw:
phaseincrement = (cyclespersecond * 360) * ifi;


% Get frame rate fro moving patch
frameRate=Screen('FrameRate',screenNumber);

% Get the number of frames stim needs to be on for
totalNumFrames = frameRate * stimTime;

% Get number of frames for prestimulus time
preStimFrames = frameRate * preStimTime;

% Get frame number to interate over contrast ramp
contrast_rampFrames = frameRate *  rampTime;
contrastLevels = linspace(0, contrast, contrast_rampFrames);


% set up gaussian window
% create alpha blend window
% blendDistance = 200;

% set up color channels for background
mask = ones(screenYpixels, screenXpixels+10, 3);

% background values
mask(:,:,1) = mask(:,:,1) * backgroundColorOffsetCy(1); % red value
mask(:,:,2) = mask(:,:,2) * backgroundColorOffsetCy(2); % green value
mask(:,:,3) = mask(:,:,3) * backgroundColorOffsetCy(3); % blue value

mask2 = NaN(screenYpixels, screenXpixels+10); %alpha mask
blendVec = linspace(1, 0, blendDistancePixels);

for i =1:blendDistancePixels
    mask2(i:end-(i-1),i:end-(i-1)) =  blendVec(i);
end

mask = cat(3,mask,mask2);
masktex=Screen('MakeTexture', windowPtr, mask);




%% START STIM PRESENTATION

HideCursor(windowPtr, []);

if doNotSendEvents ==0
    % trigger image scan start with digital port A
    DaqDConfigPort(daq,0,0); % configure port A for output
    err = DigiOut(daq, 0, 255, 0.1);
    
    DaqDConfigPort(daq,1,1) % configure port B for input
end

while ~KbCheck
    tic;
    for currentBlkNum = 1:numReps
        % randomizes the order of the conditions for this block
        cndOrder = datasample(1:numCnd,numCnd,'Replace', false);
        blockNum = blockNum+1;
        
        for trialCnd = 1:length(cndOrder)
            
            phase = 0;
            
            % Get trial cnds
            trialParams = Angle(cndOrder(trialCnd)); % get angle identity
            indexForOrientation = find(Angle==trialParams, 1); % get index for that angle
            
            % get color condition
            currentColLevel = ceil(cndOrder(trialCnd)/length(orientations));
            modulateCol = colorLevels(currentColLevel, :);
            
            % get first direction flag ( 0 == left first, 1 == right first)
            directionFlag = blockMovementsBalanced(currentColLevel, indexForOrientation);
            
            if directionFlag == 0
                movementDirection = 'Postive';
                movementEvent1 = 'POSITIVE MOVEMENT';
                movementEvent2 = 'NEGATIVE MOVEMENT';
            else
                movementDirection = 'Negative';
                movementEvent1 = 'NEGATIVE MOVEMENT';
                movementEvent2 = 'POSITIVE MOVEMENT';
            end
            
            
            if doNotSendEvents ==0
                AnalogueOutEvent(daq, 'TRIAL_START');
                stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_START');
            end
            
            
            
            if fullfieldStim ==0
                dstRect = OffsetRect(gratingrect, screenStimCentre(1)-radius, screenStimCentre(2)-radius);
            else
                dstRect = [];
            end
            %display trial conditions
            
            fprintf(['Block No: %i \n'...
                'Condition No: %i \n'...
                'Trial No: %i of %i \n' ...
                'Color Cnd: %i \n' ...
                'Orientation: %.1f degrees \n'...
                'First Direction = %s \n' ...
                '############################################## \n'] ...
                ,blockNum,cndOrder(trialCnd), trialCnd, length(cndOrder) , currentColLevel,  trialParams(1), movementDirection);
            
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
            
            % blank screen flips for prestimulus time period
            if doNotSendEvents ==0
                
                AnalogueOutEvent(daq, 'PRESTIM_ON');
                stimCmpEvents(end+1,:)= addCmpEvents('PRESTIM_ON');
            end
            
            for prestimFrameNp = 1:preStimFrames
                Screen('Flip', windowPtr);
            end
            
            if doNotSendEvents ==0
                AnalogueOutEvent(daq, 'PRESTIM_OFF');
                stimCmpEvents(end+1,:)= addCmpEvents('PRESTIM_OFF');
            end
            
            stimOnFlag =1;
            % start constrast ramp on
            if rampTime > 0
                for frameNo =1:contrast_rampFrames
                    % Increment phase by cycles/s:
                    phase = phase + phaseincrement;
                    %create auxParameters matrix
                    propertiesMat = [phase, freqPix, contrastLevels(frameNo), 0];
                    % draw grating on screen
                    %Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
                    
                    if doNotSendEvents ==0
                        if stimOnFlag ==1 % only sends stim on at the first draw of moving grating
                            AnalogueOutEvent(daq, 'STIM_ON');
                            stimCmpEvents(end+1,:)= addCmpEvents('STIM_ON');
                            
                            % add movement direction event
                            AnalogueOutEvent(daq, movementEvent1);
                            stimCmpEvents(end+1,:)= addCmpEvents(movementEvent1);
                            
                            stimOnFlag = 0;
                        end
                    end
                    
                    if directionFlag == 0
                        movementMod = 0;
                    else
                        movementMod = 180;
                    end
                    
                    Screen('DrawTexture', windowPtr, gratingid, [], dstRect , Angle(cndOrder(trialCnd)) + movementMod, [] , [], [modulateCol], [], [], propertiesMat' );
                    Screen('BlendFunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                    Screen('DrawTexture', windowPtr, masktex, [], [], 0);
                    Screen('Flip', windowPtr);
                    Screen('BlendFunction', windowPtr, GL_ONE, GL_ZERO);
                end
            end
            %% First movement direction
            for frameNo =1:totalNumFrames/2 % stim presentation loop
                phase = phase + phaseincrement;
                %create auxParameters matrix
                propertiesMat = [phase, freqPix, contrast, 0];
                
                % draw grating on screen
                %Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
                
                if directionFlag == 0
                    movementMod = 0;
                else
                    movementMod = 180;
                end
                Screen('DrawTexture', windowPtr, gratingid, [], dstRect , Angle(cndOrder(trialCnd)) + movementMod, [] , [], [modulateCol], [], [], propertiesMat' );
                Screen('BlendFunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('DrawTexture', windowPtr, masktex, [], [], 0);
                
                if doNotSendEvents ==0
                    if rampTime == 0
                        if stimOnFlag ==1 % only sends stim on at the first draw of moving grating
                            AnalogueOutEvent(daq, 'STIM_ON');
                            stimCmpEvents(end+1,:)= addCmpEvents('STIM_ON');
                            stimOnFlag = 0;
                        end
                    end
                end
                
                %             Screen('DrawDots', windowPtr, screenCentre, [5], [1 0 0], [] , [], []); % Fixation/ screen centre spot
                
                % Flip to the screen
                if doNotSendEvents ==0
                    AnalogueOutEvent(daq, 'SCREEN_REFRESH');
                    stimCmpEvents(end+1,:)= addCmpEvents('SCREEN_REFRESH');
                end
                Screen('Flip', windowPtr);
                Screen('BlendFunction', windowPtr, GL_ONE, GL_ZERO);
                
                % Abort requested? Test for keypress:
                if KbCheck
                    break;
                end
                
            end % end stim presentation loop
            
            %% second movement direction
            
            % add movment direction event
            AnalogueOutEvent(daq, movementEvent1);
            stimCmpEvents(end+1,:)= addCmpEvents(movementEvent1);
            
            for frameNo =1:totalNumFrames/2 % stim presentation loop
                phase = phase + phaseincrement;
                %create auxParameters matrix
                propertiesMat = [phase, freqPix, contrast, 0];
                
                % draw grating on screen
                %Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
                
                if directionFlag == 0
                    movementMod = 180;
                else
                    movementMod = 0;
                end
                Screen('DrawTexture', windowPtr, gratingid, [], dstRect , Angle(cndOrder(trialCnd)) + movementMod, [] , [], [modulateCol], [], [], propertiesMat' );
                Screen('BlendFunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('DrawTexture', windowPtr, masktex, [], [], 0);
                
                %             Screen('DrawDots', windowPtr, screenCentre, [5], [1 0 0], [] , [], []); % Fixation/ screen centre spot
                
                % Flip to the screen
                if doNotSendEvents ==0
                    AnalogueOutEvent(daq, 'SCREEN_REFRESH');
                    stimCmpEvents(end+1,:)= addCmpEvents('SCREEN_REFRESH');
                end
                Screen('Flip', windowPtr);
                
                Screen('BlendFunction', windowPtr, GL_ONE, GL_ZERO);
                
                % Abort requested? Test for keypress:
                if KbCheck
                    break;
                end
                
            end % end stim presentation loop
            
            
            % Abort requested? Test for keypress:
            if KbCheck
                break;
            end
            if doNotSendEvents ==0
                if rampTime == 0
                    AnalogueOutEvent(daq, 'STIM_OFF');
                    stimCmpEvents(end+1,:)= addCmpEvents('STIM_OFF');
                end
            end
            %             Screen('Flip', windowPtr);
            % ramp off
            if rampTime > 0
                % start constrast ramp off
                for frameNo =contrast_rampFrames:-1:1
                    % Increment phase by cycles/s:
                    phase = phase + phaseincrement;
                    %create auxParameters matrix
                    propertiesMat = [phase, freqPix, contrastLevels(frameNo), 0];
                    % draw grating on screen
                    %Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
                    
                    if directionFlag == 0
                        movementMod = 180;
                    else
                        movementMod = 0;
                    end
                    
                    Screen('DrawTexture', windowPtr, gratingid, [], dstRect , Angle(cndOrder(trialCnd)) + movementMod, [] , [], [modulateCol], [], [], propertiesMat' );
                    Screen('BlendFunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                    Screen('DrawTexture', windowPtr, masktex, [], [], 0);
                    
                end
                
                if doNotSendEvents ==0
                    AnalogueOutEvent(daq, 'STIM_OFF');
                    stimCmpEvents(end+1,:)= addCmpEvents('STIM_OFF');
                end
                
            end
            
            Screen('Flip', windowPtr);
            Screen('BlendFunction', windowPtr, GL_ONE, GL_ZERO);
            Screen('Flip', windowPtr);
            
            WaitSecs(ITItime);
            
            if doNotSendEvents ==0
                AnalogueOutEvent(daq, 'TRIAL_END');
                stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_END');
            end
        end
        % Abort requested? Test for keypress:
        if KbCheck
            break;
        end
    end % end number of blocks
    toc;
    break % breaks when reaches requested number of blocks
end

%% save things before close
if doNotSendEvents ==0
    saveCmpEventFile(stimCmpEvents, dataDir, indentString, timeSave);
end

ShowCursor([],[windowPtr],[]);

% Clear screen
sca;
end
