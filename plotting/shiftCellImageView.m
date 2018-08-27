function shiftCellImageView(patchCenter, patchFigAx)
% Shifts cell image view to new cell center
% Inputs: patchCenter ( x y coordinates for cell center)
%         patchFigAx (axis handle for image)


axisLims = patchFigAx.XLim; % gets current axis limits
newBoundary = round((axisLims(2)-axisLims(1))/2); % gets current view size in pixels

% sets new axis size around patch center
patchFigAx.XLim = [(patchCenter(1)-newBoundary) (patchCenter(1)+newBoundary)];
patchFigAx.YLim =[(patchCenter(2)-newBoundary) (patchCenter(2)+newBoundary)];

end