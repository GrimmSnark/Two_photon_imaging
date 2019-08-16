function [gratingid, gratingrect, gratingMatrix] = createSquareWaveGrating(windowPtr,width, height, onColor, backgroundColor, cycleInPix)

%% build grating
% calculate on/off pix cycle 
onPeriod = round(cycleInPix/2);

% get full cycle in pixels
gratingLine = [ones(1, onPeriod) zeros(1, onPeriod)];

% get number of cycles per screen
numOfCycles = ceil(width/length(gratingLine));

% build grating RGB matric
onCol = permute(repmat(onColor, height, 1, onPeriod), [1 3 2]);
offCol = permute(repmat(backgroundColor, height, 1, onPeriod), [1 3 2]);
gratingMatrix = repmat([onCol offCol], 1, numOfCycles,1);

%% Add to PTB
gratingid=Screen('MakeTexture', windowPtr, gratingMatrix);
% Query and return its bounding rectangle:
gratingrect = Screen('Rect', gratingid);



end