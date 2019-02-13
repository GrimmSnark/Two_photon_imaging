function PTBMelanopsinMnky(preStimTime, stimTime, postStimTime, numReps, varargin)

%% set up parameters of stimuli
clc
sca;


doNotSendEvents = 0;
fullfieldStim = 0;

if ~isempty(varargin)
    doNotSendEvents = 1;
end

if isempty(numReps)
    numReps = Inf;
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

% Color offsets for similar energy (specific for screen)
redMax = 1;
% greenMax = 0.7255;
greenMax = 1;
blueMax = 1;

backgroundRed = redMax/2;
backgroundGreen = greenMax/2;
backgroundBlue = blueMax/2;

backgroundColorOffsetCy = [backgroundRed backgroundGreen backgroundBlue 1]; %RGBA offset color

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

PsychImaging('PrepareConfiguration');

% look into PsychImaging('AddTask', 'General', 'UseGPGPUCompute', apitype [, flags]);???

PsychImaging('AddTask','General', 'FloatingPoint32Bit'); % sets accuracy of frame buffer to 32bit floating point

[windowPtr, ~] = PsychImaging('OpenWindow', screenNumber, [ backgroundColorOffsetCy(1:3) ] ); %opens screen and sets background to grey


% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', windowPtr);

% Get frame rate fro moving patch
frameRate=Screen('FrameRate',screenNumber);

% Get the number of frames stim needs to be on for
totalNumFrames = frameRate * stimTime;

% Get number of frames for prestimulus time
preStimFrames = frameRate * preStimTime;

% Get number of frames for prestimulus time
postStimFrames = frameRate * postStimTime;












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
            
                currentColLevel = ceil(cndOrder(trialCnd)/length(orientations));
                modulateCol = colorLevels(currentColLevel, :);
       
            
            if doNotSendEvents ==0
                AnalogueOutEvent(daq, 'TRIAL_START');
                stimCmpEvents(end+1,:)= addCmpEvents('TRIAL_START');
            end
            
            % Get trial cnds
            trialParams = Angle(cndOrder(trialCnd));
            
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
                '############################################## \n'] ...
                ,blockNum,cndOrder(trialCnd), trialCnd, length(cndOrder) , currentColLevel,  trialParams(1));
            
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
                    %create auxParameters matrix
                    propertiesMat = [0, freqPix, contrastLevels(frameNo), 0];
                    % draw grating on screen
                    %Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
                    
                    if doNotSendEvents ==0
                        if stimOnFlag ==1 % only sends stim on at the first draw of moving grating
                            AnalogueOutEvent(daq, 'STIM_ON');
                            stimCmpEvents(end+1,:)= addCmpEvents('STIM_ON');
                            stimOnFlag = 0;
                        end
                    end
                    
                    if cndOrder(trialCnd) <9
                        Screen('DrawTexture', windowPtr, gratingidG, [], dstRect , Angle(cndOrder(trialCnd)), [] , [], [modulateCol], [], [], propertiesMat' );
                    else
                        Screen('DrawTexture', windowPtr, gratingidB, [], dstRect , Angle(cndOrder(trialCnd)), [] , [], [modulateCol], [], [], propertiesMat' );
                    end
                    Screen('Flip', windowPtr);
                end
            end
            
            for frameNo =1:totalNumFrames % stim presentation loop
                %create auxParameters matrix
                propertiesMat = [0, freqPix, contrast, 0];
                
                % draw grating on screen
                %Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
                
                if cndOrder(trialCnd) <9
                    Screen('DrawTexture', windowPtr, gratingidG, [], dstRect , Angle(cndOrder(trialCnd)), [] , [], [modulateCol], [], [], propertiesMat' );
                else
                    Screen('DrawTexture', windowPtr, gratingidB, [], dstRect , Angle(cndOrder(trialCnd)), [] , [], [modulateCol], [], [], propertiesMat' );
                end
                
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
                
%                 % Abort requested? Test for keypress:
                if KbCheck
                    break;
                end
%                 
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
            
            if rampTime > 0
                % start constrast ramp off
                for frameNo =contrast_rampFrames:-1:1
                    %create auxParameters matrix
                    propertiesMat = [0, freqPix, contrastLevels(frameNo), 0];
                    % draw grating on screen
                    %Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
                    
                    if cndOrder(trialCnd) <9
                        Screen('DrawTexture', windowPtr, gratingidG, [], dstRect , Angle(cndOrder(trialCnd)), [] , [], [modulateCol], [], [], propertiesMat' );
                    else
                        Screen('DrawTexture', windowPtr, gratingidB, [], dstRect , Angle(cndOrder(trialCnd)), [] , [], [modulateCol], [], [], propertiesMat' );
                    end
                    Screen('Flip', windowPtr);
                end
                
                if doNotSendEvents ==0
                    AnalogueOutEvent(daq, 'STIM_OFF');
                    stimCmpEvents(end+1,:)= addCmpEvents('STIM_OFF');
                end
                
            end
            
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

end