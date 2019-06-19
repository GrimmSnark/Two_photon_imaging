function [labeledROI, XYLocs ] = createFilledMatlabROIFromFIJIROI(FIJIROI, experimentStructure)  
% creates filled matlab binary array and gets coordinates from FIJI roi

X = FIJIROI.getXBase;
Y = FIJIROI.getYBase;

% Get local mask for ROI object
localCellMask = FIJIROI.getMask();
height = localCellMask.getHeight();
width  = localCellMask.getWidth();
boundedPixels = double(localCellMask.getPixels());
localCellImg = reshape(boundedPixels,[width,height]);
labeledROI(Y+[1:height],X+[1:width]) = localCellImg';

labeledROI(labeledROI == -1) =1;
[indxR, indC] = find(labeledROI);

% check for edge fill

% colums
%find intersection with max side of array
maxPixels = find(indC == experimentStructure.pixelsPerLine);
if ~isempty(maxPixels)
    % find bounds on max size
    maxCol = max(indxR(maxPixels));
    minCol = min(indxR(maxPixels));
    
    
    if (maxCol-minCol) > 1
        labeledROI(minCol:maxCol,experimentStructure.pixelsPerLine) =1;
        
    else     % if there is only one touch on max side try and figure out the other touched side
        maxRPixel = find(indxR == experimentStructure.pixelsPerLine );
        
        if ~isempty(maxRPixel)
            labeledROI(maxCol:experimentStructure.pixelsPerLine,experimentStructure.pixelsPerLine) =1;
        else
            labeledROI(1:maxCol,experimentStructure.pixelsPerLine) =1;
        end
    end
end


minPixels = find(indC == 1);
if ~isempty(minPixels)
    maxCol = max(indxR(minPixels));
    minCol = min(indxR(minPixels));
    
    if (maxCol-minCol) > 1
        labeledROI(minCol:maxCol,experimentStructure.pixelsPerLine) =1;
        
    else     % if there is only one touch on max side try and figure out the other touched side
        maxRPixel = find(indxR ==experimentStructure.pixelsPerLine );
        
        if ~isempty(maxRPixel)
            labeledROI(maxCol:experimentStructure.pixelsPerLine,1) =1;
        else
            labeledROI(1:maxCol,1) =1;
        end
    end
end

% rows
maxPixels = find(indxR == experimentStructure.pixelsPerLine);
if ~isempty(maxPixels)
    maxR = max(indC(maxPixels));
    minR = min(indC(maxPixels));
    
     if (maxR-minR) > 1
        labeledROI(experimentStructure.pixelsPerLine, minR:maxR) =1;
        
    else     % if there is only one touch on max side try and figure out the other touched side
        maxCPixel = find(indC == experimentStructure.pixelsPerLine );
        
        if ~isempty(maxCPixel)
            labeledROI(experimentStructure.pixelsPerLine, maxR:experimentStructure.pixelsPerLine) =1;
        else
            labeledROI(experimentStructure.pixelsPerLine, 1:maxR) =1;
        end
     end 
end


minPixels = find(indxR == 1);
if ~isempty(minPixels)
     maxR = max(indC(minPixels));
    minR = min(indC(minPixels));
    
    if (maxR-minR) > 1
            labeledROI(experimentStructure.pixelsPerLine, minR:maxR) =1;
        
    else     % if there is only one touch on max side try and figure out the other touched side
        maxCPixel = find(indC ==experimentStructure.pixelsPerLine );
        
        if ~isempty(maxCPixel)
            labeledROI(1, maxR:experimentStructure.pixelsPerLine) =1;
        else
            labeledROI(1, 1:maxR) =1;
        end
    end
end


labeledROI = imfill(labeledROI,'holes');
XYLocs = bwboundaries(labeledROI);
XYLocs = XYLocs{:};
end