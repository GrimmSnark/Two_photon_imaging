function PTB_RFMappingByHand()
% course manual mapping program, does not output any events but plays
% moving gabor continously. Allows the following commands
%
% Esc = ends experiement
% up Arrow = moves stim up the screen
% down Arrow = moves stim down screen
% left Arrow = moves stim left
% right Arrow = moves stim right
% space Key = toggles stim on and off
% enter Key = increases rotation of gabor
% back space = decreases rotation of gabor
% plus key = increase radius of gabor
% minus ky = decreases radius of gabor

%% set up parameters of stimuli
clc
sca;

% Should not change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

waitframes = 1;
initialCenter = [0, 0];

%Stimulus
%width = 10; % in degrees visual angle
stimeSizeRange = 2:2:50;
for i = 1:length(stimeSizeRange)
    widthInPix(i) = degreeVisualAngle2Pixels(1,stimeSizeRange(i));
end
 pixelsPerPress = degreeVisualAngle2Pixels(1,1);

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
orientation =linspace(0, 360, 16);

for x = 1:length(stimeSizeRange)
stimRect(:,x) = [0 0 widthInPix(x) widthInPix(x)];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up relative stim centre based on degree visual angle

%Screen('Preference', 'SkipSyncTests', 1);

PsychDefaultSetup(2); % PTB defaults for setup

screenNumber = max(Screen('Screens')); % makes display screen the secondary one
% resolution = Screen('Resolution',screenNumber); %% may give weird result, so hard coding for now

% screenCentre(1) = resolution.width/2; % uncomment to check for your setup
% screenCentre(2) = resolution.height/2;
screenCentre = [850 650]; % screen centre of Shel 1170 WEIRD, calcualted by physical measurement...

screenStimCentreOffset(1) = degreeVisualAngle2Pixels(1,initialCenter(1));
screenStimCentreOffset(2) = degreeVisualAngle2Pixels(1,initialCenter(2));

screenStimCentre = screenCentre + screenStimCentreOffset;

%% intial set up of experiment

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;

PsychImaging('PrepareConfiguration');

% look into PsychImaging('AddTask', 'General', 'UseGPGPUCompute', apitype [, flags]);???

PsychImaging('AddTask','General', 'FloatingPoint32Bit'); % sets accuracy of frame buffer to 32bit floating point

[windowPtr, ~] = PsychImaging('OpenWindow', screenNumber, grey); %opens screen and sets background to grey

% Create gabor gratings

for i =1:length(stimeSizeRange)
[gabortex(i),  gaborrect(:,i)]= CreateProceduralGabor(windowPtr, widthInPix(i), widthInPix(i), [],backgroundColorOffset, [], contrast);
end

% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', windowPtr);

% Get the size of the on screen window
% [screenXpixels, screenYpixels] = Screen('WindowSize', windowPtr); % uncomment for your setup

screenXpixels = 1700; % hard coded cause reasons.. weird screens % comment out for your setup
screenYpixels = 1300;

% The avaliable keys to press
escapeKey = KbName('ESCAPE');
upKey = KbName('UpArrow');
downKey = KbName('DownArrow');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
spaceKey = KbName('space');
enterKey = KbName('return');
backKey = KbName('backspace');
plusKey = KbName('+');
minusKey = KbName('-');

% Get frame rate fro moving patch
% frameRate=Screen('FrameRate',screenNumber);

% Get the number of frames stim needs to be on for
% totalNumFrames = frameRate * stimTime;

% Compute increment of phase shift per redraw:
phaseincrement = (cyclespersecond * 360) * ifi;

% Maximum priority level
topPriorityLevel = MaxPriority(windowPtr);
Priority(topPriorityLevel);

% This is the cue which determines whether we exit the demo
exitDemo = false ;

vbl  = Screen('Flip', windowPtr);
stimOn =0;
orientationNo = 1;
size = 4;
%%

% Loop the animation until the escape key is pressed
while exitDemo == false
    
    % Check the keyboard to see if a button has been pressed
    [~,~, keyCode] = KbCheck;
    
    % Depending on the button press, either move ths position of the square
    % or exit the demo
    if keyCode(escapeKey) % exit script
        exitDemo = true;
    elseif keyCode(leftKey) % move stim left
        screenStimCentre(1) = screenStimCentre(1) - pixelsPerPress;
    elseif keyCode(rightKey) % move stim right
        screenStimCentre(1) = screenStimCentre(1) + pixelsPerPress;
    elseif keyCode(upKey) % move stim up
        screenStimCentre(2) = screenStimCentre(2) - pixelsPerPress;
    elseif keyCode(downKey) % move stim down
        screenStimCentre(2) = screenStimCentre(2) + pixelsPerPress;
    elseif keyCode(spaceKey) % toggle stim on and off
        if stimOn ==1
            stimOn =0;
            disp('off');
            KbReleaseWait;
        elseif stimOn ==0
            stimOn =1;
            disp('on');
            KbReleaseWait;
        end
    elseif keyCode(enterKey) && orientationNo < length(orientation) % incease orientation degree
        orientationNo = orientationNo + 1;
        KbReleaseWait
    elseif keyCode(backKey) && orientationNo > 1 % decreae orientation degree
        orientationNo = orientationNo - 1;
        KbReleaseWait
    elseif keyCode(plusKey) && size < length(stimeSizeRange) % increase size of stim
        size = size+1;
    elseif keyCode(minusKey) && size > 1 % decrease sie of stim
        size = size-1;
    end
    
    
    
    % We set bounds to make sure our square doesn't go completely off of
    % the screen
    if screenStimCentre(1) < 0
        screenStimCentre(1) = 0;
    elseif screenStimCentre(1) > screenXpixels
        screenStimCentre(1) = screenXpixels;
    end
    
    if screenStimCentre(2) < 0
        screenStimCentre(2) = 0;
    elseif screenStimCentre(2) > screenYpixels
        screenStimCentre(2) = screenYpixels;
    end
    
    % Increment phase by cycles/s:
    phase = phase + phaseincrement;
    %create auxParameters matrix
    propertiesMat = [phase, freqPix, sigma(size), contrast, aspectRatio, 0, 0 ,0];
    
    dstRect = OffsetRect(stimRect(:,size)', screenStimCentre(1), screenStimCentre(2)); % chooses location based on random draw of cndOrder
    
    if stimOn ==1
        Screen('DrawTexture', windowPtr, gabortex(size), [], dstRect , orientation(orientationNo), [], [], [], [], kPsychDontDoRotation, propertiesMat' );
        disp(orientation(orientationNo));
    elseif stimOn ==0
        vbl  = Screen('Flip', windowPtr, vbl + (waitframes - 0.5) * ifi);
    end
    
    % Flip to the screen
    vbl  = Screen('Flip', windowPtr, vbl + (waitframes - 0.5) * ifi);
end

sca;


end