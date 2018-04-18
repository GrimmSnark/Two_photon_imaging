width = 4;
stimCenter = [0 0];

%% set up parameters of stimuli
clc
sca;

% Should not change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stimTime = 1; %in s
ITItime = 1; % intertrial time
ISItime = 1; % interstim time
firstTime =1;
blockNum = 0;
% 
% dataDir = 'C:\PostDoc Docs\Ca Imaging Project\PTB_Timing_Files\'; % save dir for timing files
% timeSave = datestr(now,'yyyymmddHHMMSS');
% indentString = 'RF_mapping_';
stimCmpEvents = [1 1] ;

%Stimulus
%width = 10; % in degrees visual angle
widthInPix = degreeVisualAngle2Pixels(1,width);
backgroundColorOffset = [0.5 0.5 0.5 0]; %RGBA offset color
contrast =50;


stimRect = [0 0 widthInPix widthInPix];

%% Set up relative stim centre based on degree visual angle

PsychDefaultSetup(2); % PTB defaults for setup

screenNumber = max(Screen('Screens')); % makes display screen the secondary one
resolution = Screen('Resolution',screenNumber); %% may give weird result, so hard coding for now

% screenCentre(1) = resolution.width/2;
% screenCentre(2) = resolution.height/2;
screenCentre = [910 785]; % screen centre of Shel 1170 WEIRD, calcualted by physical measurement..

screenStimCentreOffset(1) = degreeVisualAngle2Pixels(1,stimCenter(1));
screenStimCentreOffset(2) = degreeVisualAngle2Pixels(1,stimCenter(2));

screenStimCentre = screenCentre + screenStimCentreOffset;


%% Set up stim grid locations based on stimCenter and stim size

stimGrid = [15 28]; % This should not be changed but if it does needs to keep the [even odd] format
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

middleRowN = cellfun(@FrstNeg,fliplr(middleRow), 'UniformOutput',false);
middleRow = [middleRowN middleRow];

% make quater of the grid to start
for i = 1:floor(stimGrid(1)/2) % for each row
    
    for x = 1:stimGrid(2)/2 % for each colomn
        tempGrid{i,x}= [(widthInPix*x) (widthInPix*i)];
        
    end
end

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

relPostitonsVector = reshape(finalPostionsStim,1,[]);

%% intial set up of experiment

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
totalNumFrames = frameRate * stimTime;

% Get bas rectangle size in pix
baseRect = [ 0 0 


%% Start stim presentation

% trigger image scan start
% DaqDConfigPort(daq,0,0);
% err = DigiOut(daq, 0, 255, 0.1);

while ~KbCheck
    
%     AnalogueOutEvent(daq, 'TRIAL_START');
%     stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_START');
%     
    %randomizes the condition order
    cndOrder = datasample(1:noOfPositions,noOfPositions,'Replace', false);
    
    % send out condition order to 2P computer and CmpEventFile
%     AnalogueOutEvent(daq, 'PARAM_START');
%     stimCmpEvents(end+1,:)= addCmpEvents('PARAM_START');
%     
%     for i=1:length(cndOrder)
%         AnalogueOutCode(daq, cndOrder(i)); % comdition num
%         stimCmpEvents(end+1,:)= addCmpEvents(cndOrder(i));
%         WaitSecs(0.001);
%     end
%     
%     AnalogueOutEvent(daq, 'PARAM_END');
%     stimCmpEvents(end+1,:)= addCmpEvents('PARAM_END');
%     %      cndOrder = 1:noOfPositions; % for testing purposes
    %     cndOrder = ones(noOfPositions)*54;
    
    
    
    for stim =1:length(indexPerFrame)
        
        
        
        
        
    end
    
    
    for stim =1:length(cndOrder) % runs through all stims
        dstRect = OffsetRect(stimRect, relPostitonsVector{1,cndOrder(stim)}(1), relPostitonsVector{1,cndOrder(stim)}(2)); % chooses location based on random draw of cndOrder
       
        stimOnFlag =1;
        for frameNo =1:totalNumFrames
            % Increment phase by cycles/s:
            phase = phase + phaseincrement;
            %create auxParameters matrix
            propertiesMat = [phase, freqPix, sigma, contrast, aspectRatio, 0, 0 ,0];
            

            Screen('DrawTexture', windowPtr, gabortex, [], dstRect , orientation, [], [], [], [], [], propertiesMat' );
            
            
            if stimOnFlag ==1 % only sends stim on at the first draw of moving grating
                AnalogueOutEvent(daq, 'STIM_ON');
                stimCmpEvents(end+1,:)= addCmpEvents('STIM_ON');
                stimOnFlag = 0;
            end
            
            % Flip to the screen
            AnalogueOutEvent(daq, 'SCREEN_REFRESH');
            stimCmpEvents(end+1,:)= addCmpEvents('SCREEN_REFRESH');
            Screen('Flip', windowPtr);
            
            % Abort requested? Test for keypress:
            if KbCheck
                break;
            end
            
        end
        
        
        Screen('Flip', windowPtr);
        AnalogueOutEvent(daq, 'STIM_OFF');
        stimCmpEvents(end+1,:)= addCmpEvents('STIM_OFF');
        
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
    AnalogueOutEvent(daq, 'TRIAL_END');
    stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_END');
end

%% save things before close
saveCmpEventFile(stimCmpEvents, dataDir, indentString, timeSave);

sca;

