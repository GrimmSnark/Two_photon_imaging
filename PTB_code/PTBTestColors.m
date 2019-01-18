function PTBTestColors
% Displays black & white screen for defined on & off times to see how the
% screen stim and send events into Prairie sync up

%% set up parameters of stimuli
clc
sca;


%% intial set up of experiment
PsychDefaultSetup(2); % PTB defaults for setup
screenNumber = min(Screen('Screens')); % makes display screen the secondary one


% Define black, white and grey for background
% r g b
g = 255/255;
color = [0 g 0];

PsychImaging('PrepareConfiguration');
[windowPtr, ~] = PsychImaging('OpenWindow', screenNumber, color); %opens screen and sets background to grey

%% START STIM PRESENTATION


WaitSecs(5); % intial wait time

while ~KbCheck
        Screen('Flip', windowPtr);
    
end

% Clear screen
sca;

end