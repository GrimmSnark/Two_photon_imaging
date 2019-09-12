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
freq = .004;
contrast = 1;

% Build a procedural gabor texture for a grating with a support of tw x th
% pixels, and a RGB color offset of 0.5 -- a 50% gray.
% squarewavetex = CreateProceduralSquareWaveGrating(win, screenXpixels, screenXpixels, [0.5 0.5 0.5 1], []);
squarewavetex = CreateProceduralSineGrating(win, screenXpixels, screenXpixels, [0.5 0.5 0.5 0], [], 0.5);






% f=1/p;
% fr=f*2*pi    % frequency in radians.
 fr=freq*4*pi;    % frequency in radians.

% Create one single static 1-D grating image.
% We only need a texture with a single row of pixels(i.e. 1 pixel in height) to
% define the whole grating! If the 'srcRect' in the 'Drawtexture' call
% below is "higher" than that (i.e. visibleSize >> 1), the GPU will
% automatically replicate pixel rows. This 1 pixel height saves memory
% and memory bandwith, ie. it is potentially faster on some GPUs.
x=meshgrid(0:(screenXpixels/2)-1, 1);
grating=0.5 + 0.5*cos(fr*x);

% Store grating in texture: Set the 'enforcepot' flag to 1 to signal
% Psychtoolbox that we want a special scrollable power-of-two texture:
gratingtex=Screen('MakeTexture', win, grating, [], 1);







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



Screen('DrawTexture', win, squarewavetex, [], [0  0 screenXpixels/2 screenXpixels ], [], [],[],[], [], [], [phase, freq, contrast, 10]);
 grat2Start = screenXpixels/2 + 10 ;
Screen('DrawTexture', win, gratingtex, [], [ grat2Start 0 screenXpixels screenXpixels ], [], [],[],[], [], []);
% Screen(win,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
% Screen('DrawTexture', win, masktex, [], [], 0);


vbl = Screen('Flip', win);

WaitSecs(10);
% Close window, release all ressources:
sca


end