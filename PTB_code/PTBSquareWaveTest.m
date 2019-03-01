function PTBSquareWaveTest

Screen('Preference', 'VisualDebugLevel', 1); % removes welcome screen
PsychDefaultSetup(2);

gray = 0.5;

% Choose screen with maximum id - the secondary display:
screenid = max(Screen('Screens'));

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', screenid); % uncomment for your setup

% Open a window
PsychImaging('PrepareConfiguration');
win = PsychImaging('OpenWindow', screenid, gray);
% Screen(win,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Initial stimulus params for the grating:
phase = 0;
freq = .04;
contrast = 1;

% Build a procedural gabor texture for a grating with a support of tw x th
% pixels, and a RGB color offset of 0.5 -- a 50% gray.
squarewavetex = CreateProceduralSquareWaveGrating(win, screenXpixels, screenXpixels, [0.5 0.5 0.5 1], []);

% create alpha blend window
blendDistance = 500;
mask = ones(screenYpixels, screenXpixels+10)* gray; % background col
mask2 = NaN(screenYpixels, screenXpixels+10); %alpha mask
blendVec = linspace(1, 0, blendDistance);

for i =1:blendDistance
   mask2(i:end-(i-1),i:end-(i-1)) =  blendVec(i);
end


mask = cat(3,mask,mask2);

masktex=Screen('MakeTexture', win, mask);



Screen('DrawTexture', win, squarewavetex, [], [], [], [],[],[], [], [], [phase, freq, contrast, 10]);
Screen(win,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('DrawTexture', win, masktex, [], [], 0);


vbl = Screen('Flip', win);

WaitSecs(5);
% Close window, release all ressources:
sca


end