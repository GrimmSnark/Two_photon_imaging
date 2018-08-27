function magnifyCellPic(cellLocation, zoomfactor, zoomlevel, patchFigAx, experimentStructure)
% Used to magnify cell image view around specified cell 
%
% Inputs: cellLocation (x y coordinates in pixels for cell center)
%         zoomfactor (amount to mangified by, current x4)
%         zoomlevel (1/2 magnify or not, can be explanded to muli-level at
%                   later date)
%         patchFigAx (Figure handle to image ax)
%         experimentStructure (data structure)

%% Sets zoom factor and new image center location
if zoomlevel >1
    zoomfactor = zoomfactor;
    patchCenter = cellLocation;
else
    zoomfactor =2;
    patchCenter = [experimentStructure.pixelsPerLine/2 experimentStructure.pixelsPerLine/2];
    
end
%% Sets new image boundaries
patchFigAx.Clipping = 'on'; % axis clipping on

FrameSize = experimentStructure.pixelsPerLine; % gets image size original 
newBoundary = round(FrameSize/zoomfactor); % sets new frame size

% gets image axis limits/ resizes image
patchFigAx.YLim = [(patchCenter(1)-newBoundary) (patchCenter(1)+newBoundary)];
patchFigAx.XLim =[(patchCenter(2)-newBoundary) (patchCenter(2)+newBoundary)];

end