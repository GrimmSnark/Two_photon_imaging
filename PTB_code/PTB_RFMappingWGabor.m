function PTB_RFMappingWGabor(width,stimCenter,varargin)
% Visual field mappping script for defining response in recording areas
% with gabor like patch grid, basically reverse correlation
% width = gabor size, stimCenter = [x,y] center loction for stimulation in
% degrees of visual angle

%% set up parameters of stimuli
clc
sca;

doNotSendEvents = 0;
if ~isempty(varargin)
    doNotSendEvents = 1;
end

% Should not change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stimTime = 1; %in s
ITItime = 1; % intertrial time
ISItime = 1; % interstim time
firstTime =1;
blockNum = 0;

dataDir = 'C:\PostDoc Docs\Ca Imaging Project\PTB_Timing_Files\'; % save dir for timing files
timeSave = datestr(now,'yyyymmddHHMMSS');
indentString = 'RF_mapping_';
stimCmpEvents = [1 1] ;

%Stimulus
%width = 10; % in degrees visual angle
widthInPix = degreeVisualAngle2Pixels(1,width);

freq = 1 ; % in cycles per degree
freq = 1/freq; % hack hack hack
freqPix = degreeVisualAngle2Pixels(1,freq);
freqPix =1/freqPix; % use the inverse as the function below takes bloody cycles/pixel...
phase = 0;
backgroundColorOffset = [0.5 0.5 0.5 0]; %RGBA offset color
contrast =50;

cyclespersecond =2; % temporal frequency to stimulate all cells
sigma = widthInPix/8;
aspectRatio =1;
orientation =90;

stimRect = [0 0 widthInPix widthInPix];


if doNotSendEvents ==0
    % set up DAQ box
    daq =[];
    
    % set up DAQ
    if isempty(daq)
        clear PsychHID;
        daq = DaqDeviceIndex([],0);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up relative stim centre based on degree visual angle

PsychDefaultSetup(2); % PTB defaults for setup

screenNumber = max(Screen('Screens')); % makes display screen the secondary one


% Get the size of the on screen window
% [screenXpixels, screenYpixels] = Screen('WindowSize', windowPtr); % uncomment for your setup

screenXpixels = 1915; % hard coded cause reasons.. weird screens % comment out for your setup
screenYpixels = 1535;

screenCentre = [0.5 * screenXpixels , 0.5 * screenYpixels]; % screen centre of Shel 1170 WEIRD, calcualted by physical measurement...

screenStimCentreOffset(1) = degreeVisualAngle2Pixels(1,stimCenter(1));
screenStimCentreOffset(2) = degreeVisualAngle2Pixels(1,stimCenter(2));

screenStimCentre = screenCentre + screenStimCentreOffset;



%% Set up stim grid locations based on stimCenter and stim size

stimGrid = [9 12]; % This should not be changed but if it does needs to keep the [even odd] format
noOfPositions = stimGrid(1) * stimGrid(2);
tempGrid = cell(floor(stimGrid(1)/2), stimGrid(2)/2); % temporary quater grid
middleRow  = cell(1,stimGrid(2)/2); % middle row is seperate due to odd number

coordinateGrid = cell(stimGrid);

for i = 1:size(coordinateGrid,1)
    for x = 1:size(coordinateGrid,2)
        coordinateGrid{i, x} = screenStimCentre;
    end
end

% create stim postions for centre row
for i =1: stimGrid(2)/2 % for half the columns
    middleRow{1,i} = [(widthInPix*i) 0];
end

% fix middle row x offsets
middleOffsetCell = repmat({[widthInPix/2 0]},1,stimGrid(2)/2); % create offset cell array to center stimuli to account of top left drawing of stimulus location by PTB...
middleRow = cellfun(@minus,middleRow, middleOffsetCell, 'UniformOutput',false);


middleRowN = cellfun(@FrstNeg,fliplr(middleRow), 'UniformOutput',false);
middleRow = [middleRowN middleRow];

% make quater of the grid to start
for i = 1:floor(stimGrid(1)/2) % for each row
    
    for x = 1:stimGrid(2)/2 % for each colomn
        tempGrid{i,x}= [(widthInPix*x) (widthInPix*i)];
        
    end
end

% shift over grid to the right by radius of gabor...so that the gabors
% touch the center point

rightOffsetCell = repmat({[widthInPix/2 0]},(floor(stimGrid(1)/2)),stimGrid(2)/2); % create offset cell array to center stimuli to account of top left drawing of stimulus location by PTB...
tempGrid = cellfun(@minus,tempGrid, rightOffsetCell, 'UniformOutput',false);

% make all the quaters with proper signs
rightGridP = flip(tempGrid,1);
rightGridN = cellfun(@ScndNeg,tempGrid, 'UniformOutput',false);
leftGridP =  cellfun(@FrstNeg, fliplr(rightGridP), 'UniformOutput',false);
leftGridN = cellfun(@ScndNeg, flipud(leftGridP), 'UniformOutput',false);


% concatenate it all together

topGrid = [leftGridP rightGridP];
bottomGrid = [leftGridN rightGridN];
relPositionsGrid = vertcat(topGrid,middleRow, bottomGrid);

finalPostionsStim = cellfun(@plus,coordinateGrid,relPositionsGrid,'UniformOutput',false);
finalPostionsStim = flipud(finalPostionsStim);

relPostitonsVector = reshape(finalPostionsStim,1,[]);

offsetCell = repmat({[widthInPix/2 widthInPix/2]},1,108); % create offset cell array to center stimuli to account of top left drawing of stimulus location by PTB...

relPostitonsVector = cellfun(@minus, relPostitonsVector, offsetCell,'UniformOutput',false);

%% intial set up of experiment

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;

PsychImaging('PrepareConfiguration');

% look into PsychImaging('AddTask', 'General', 'UseGPGPUCompute', apitype [, flags]);???

PsychImaging('AddTask','General', 'FloatingPoint32Bit'); % sets accuracy of frame buffer to 32bit floating point

[windowPtr, ~] = PsychImaging('OpenWindow', screenNumber, grey); %opens screen and sets background to grey

% Create gabor grating
gabortex = CreateProceduralGabor(windowPtr, widthInPix, widthInPix, [],backgroundColorOffset, [], contrast);

% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', windowPtr);

% Get frame rate fro moving patch
frameRate=Screen('FrameRate',screenNumber);

% Get the number of frames stim needs to be on for
totalNumFrames = frameRate * stimTime;

% Compute increment of phase shift per redraw:
phaseincrement = (cyclespersecond * 360) * ifi;
disp('Finished prepping');

%% Start stim presentation

if doNotSendEvents ==0
    % trigger image scan start
    DaqDConfigPort(daq,0,0);
    err = DigiOut(daq, 0, 255, 0.1);
end

while ~KbCheck
    
    if doNotSendEvents ==0
        AnalogueOutEvent(daq, 'TRIAL_START');
        stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_START');
    end
    
    %randomizes the condition order
    cndOrder = datasample(1:noOfPositions,noOfPositions,'Replace', false);
    
    if doNotSendEvents ==0
        % send out condition order to 2P computer and CmpEventFile
        AnalogueOutEvent(daq, 'PARAM_START');
        stimCmpEvents(end+1,:)= addCmpEvents('PARAM_START');
        
        for i=1:length(cndOrder)
            AnalogueOutCode(daq, cndOrder(i)); % comdition num
            stimCmpEvents(end+1,:)= addCmpEvents(cndOrder(i));
            WaitSecs(0.001);
        end
        
        AnalogueOutEvent(daq, 'PARAM_END');
        stimCmpEvents(end+1,:)= addCmpEvents('PARAM_END');
    end
    %            cndOrder = 1:noOfPositions; % for testing purposes
    %         cndOrder = ones(noOfPositions)*51;
    %     disp('Got cnd Order');
    
    for stim =1:length(cndOrder) % runs through all stims
        dstRect = OffsetRect(stimRect, relPostitonsVector{1,cndOrder(stim)}(1), relPostitonsVector{1,cndOrder(stim)}(2)); % chooses location based on random draw of cndOrder
        
        stimOnFlag =1;
        for frameNo =1:totalNumFrames
            % Increment phase by cycles/s:
            phase = phase + phaseincrement;
            %create auxParameters matrix
            propertiesMat = [phase, freqPix, sigma, contrast, aspectRatio, 0, 0 ,0];
            
            
            Screen('DrawTexture', windowPtr, gabortex, [], dstRect , orientation, [], [], [], [], [], propertiesMat' );
            
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
            %              Screen('DrawDots', windowPtr, screenStimCentre, [5], [1 0 0], [] , [], []); % Fixation/ screen centre spot
            
            Screen('Flip', windowPtr);
            disp(['Displaying Stim No. ' num2str(cndOrder(stim))]);
            
            % Abort requested? Test for keypress:
            if KbCheck
                break;
            end
            
        end
        
        Screen('Flip', windowPtr);
        if doNotSendEvents ==0
            AnalogueOutEvent(daq, 'STIM_OFF');
            stimCmpEvents(end+1,:)= addCmpEvents('STIM_OFF');
        end
        
        % Abort requested? Test for keypress:
        if KbCheck
            break;
        end
        
        WaitSecs(ISItime); % wait ITI time
        
    end
    
    if KbCheck
        break;
    end
    
    WaitSecs(ITItime); % wait ITI time
    if doNotSendEvents ==0
        AnalogueOutEvent(daq, 'TRIAL_END');
        stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_END');
    end
end

%% save things before close
if doNotSendEvents ==0
    saveCmpEventFile(stimCmpEvents, dataDir, indentString, timeSave);
end

sca;

end