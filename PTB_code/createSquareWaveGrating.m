function [gratingid, gratingrect, gratingMatrix] = createSquareWaveGrating(windowPtr,width, height, onColor, backgroundColor, cycleInPix, fastCreation)

%% build grating
% calculate on/off pix cycle
onPeriod = round(cycleInPix/2);

% get full cycle in pixels
gratingLine = [ones(1, onPeriod) zeros(1, onPeriod)];

% get number of cycles per screen
numOfCycles = ceil(width/length(gratingLine));

% build grating RGB matrix

if fastCreation ==1
    % if fast creation set, only produces single row, this gets
    % automatically turned into a full grating by make texture A LOT
    % FASTER!!
    onCol = reshape(repmat(onColor, onPeriod, 1), [1,onPeriod,length(onColor)]);
    offCol = reshape(repmat(backgroundColor, onPeriod, 1), [1,onPeriod,length(onColor)]);
    gratingMatrix = repmat([onCol offCol], 1, numOfCycles, 1);
else
    onCol = permute(repmat(onColor, height, 1, onPeriod), [1 3 2]);
    offCol = permute(repmat(backgroundColor, height, 1, onPeriod), [1 3 2]);
    gratingMatrix = repmat([onCol offCol], 1, numOfCycles,1);
end

%% Add to PTB
gratingid=Screen('MakeTexture', windowPtr, gratingMatrix);
% Query and return its bounding rectangle:
gratingrect = Screen('Rect', gratingid);



end