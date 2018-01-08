function PTBTestScreenSync(stimTime)
% Displays black & white screen for defined on & off times to see how the
% screen stim and send events into Prairie sync up

%% set up parameters of stimuli
clc
sca;

% Should not change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dataDir = 'C:\PostDoc Docs\Ca Imaging Project\PTB_Timing_Files\'; % save dir for timing files
timeSave = datestr(now,'yyyymmddHHMMSS');
indentString = 'ScreenSync_';
stimCmpEvents = [1 1] ;

% set up DAQ box
daq =[];

% set up DAQ
if isempty(daq)
    clear PsychHID;
    daq = DaqDeviceIndex([],0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


%% START STIM PRESENTATION

% trigger image scan start
DaqDConfigPort(daq,0,0);
err = DigiOut(daq, 0, 255, 0.1);

WaitSecs(1); % intial wait time

while ~KbCheck
    
    disp('Stim On');
    Screen('FillRect', windowPtr, rectColorWhite, [] );
    
    AnalogueOutEvent(daq, 'STIM_ON');
    stimCmpEvents(end+1,:)= addCmpEvents('STIM_ON');
    Screen('Flip', windowPtr);
    
    WaitSecs(stimTime);
    
    disp('Stim Off');
    Screen('FillRect', windowPtr, rectColorBlack, [] );
    AnalogueOutEvent(daq, 'STIM_OFF');
    stimCmpEvents(end+1,:)= addCmpEvents('STIM_OFF');
    Screen('Flip', windowPtr);
    
    WaitSecs(stimTime);
    
end

%% save things before close
 saveCmpEventFile(stimCmpEvents, dataDir, indentString, timeSave);

% Clear screen
sca;

end