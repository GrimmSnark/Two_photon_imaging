function PTBTestTTLIn(stimTime)

daq =[];

% set up DAQ
if isempty(daq)
    clear PsychHID;
    daq = DaqDeviceIndex([],0);
end

%% intial set up of experiment
PsychDefaultSetup(2); % PTB defaults for setup
screenNumber = max(Screen('Screens')); % makes display screen the secondary one


% Define black, white and grey for background
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

% Define colors for rectangle shape
rectColorBlack = [0 0 0];
rectColorWhite = [1 1 1];

PsychImaging('PrepareConfiguration');
[windowPtr, ~] = PsychImaging('OpenWindow', screenNumber, black); %opens screen and sets background to grey

% Get frame rate fro moving patch
frameRate=Screen('FrameRate',screenNumber);

% Get the number of frames stim needs to be on for
totalNumFrames = frameRate * stimTime;


% % Set trigger stuff
% options.FirstChannel=0;
% options.LastChannel=0;
% options.f=200;
% options.count=options.f*tmax;
% options.secs = 0.0001;
% options.immediate = 1;
% options.trigger = 2;
%
% err=DaqSetTrigger(daq,1)

port = 1; % Specifies the digital port that will be used. "port" 0 = port A, 1 = port B (1608FS only has one port from pin 21-35)
direction = 1; % "direction of signal" 0 = output, 1 = input
err = DaqDConfigPort(daq,port,direction);   % Configures the digital port accoridng to the above setting

while ~KbCheck
    
    
    triggerDigi = 0 ;
    while triggerDigi ==0
        triggerDigi = DaqDIn(daq, 1, 1);
    end
    
    
    for i = totalNumFrames
        Screen('FillRect', windowPtr, rectColorBlack, [] );
        Screen('Flip', windowPtr);
        
        % Abort requested? Test for keypress:
        if KbCheck
            break;
        end
    end
    
    for i = totalNumFrames
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
    
end








DeviceIndex = DaqFind;
options.FirstChannel=0;
options.LastChannel=0;
options.f=100;
options.count=options.f*tmax;
options.secs = 0.0001;
options.immediate = 1;
options.trigger = 1;

err=DaqSetTrigger(DeviceIndex,1)

params = DaqAInScanBegin(DeviceIndex,options)
start_time = GetSecs;
DI = DaqFind; % DeviceIndex
port = 0; %"port" 0 = port A, 1 = port B
direction = 0; % "direction" 0 = output, 1 = input

err = DaqDConfigPort(DI,port,direction)

current_time = GetSecs - start_time;

while currentTime < tmax;
    
    ind = find(t>currentTime, 1, 'first');
    Screen('FillRect', wPtr, [255 0 0], [square_pos(ind)+565 275 square_pos(ind)+715 425]);
    Screen('DrawingFinished', wPtr);
    params = DaqAInScanContinue(DeviceIndex,options);
    
    
    DaqDOut(DeviceIndex, 0, 255);
    [vbl visual_onset t1] = Screen(wPtr, 'Flip', vbl1 + (waitframes -0.5) * ifi);
    DaqDOut(DeviceIndex, 0, 0);
    current_time = GetSecs - start_time;
end


params = DaqAInScanContinue(DeviceIndex,options);
[pendulum_data,params] = DaqAInScanEnd(DeviceIndex,options);



end