function [imHandle,currentAx,  cmap] = createPatchFig(imageROI, displayImage)
% Function overlays patch objiects of ROIs onto ROI image for easy display
% Inputs- imageROI: binary image of ROIs from imagej/Fiji, ie
%         experimentStructure.labeledCellROI
%         displayImage: Image array for display purposes
%
% Outputs- cmap: colormap to be used for traces etc

% find number of ROIs
numROIs = max(imageROI(:));
boundaries = cell(numROIs,1);
%iterate through ROI number to get them in appropriate order
for i = 1: numROIs
    tempImageROI = imageROI;
    tempImageROI(tempImageROI~=i) = 0;
    boundaries(i,1) = bwboundaries(tempImageROI, 4, 'noholes');

end
% sets color map for the cell ROIs
cmap = distinguishable_colors(numROIs+1,'k');
cmap(1,:) = [0,0,0];


imHandle = handle(imshow(displayImage));
hold on
currentAx = gca(gcf);
% build patch structure

for i =1:numROIs
    
    patch(currentAx,boundaries{i,1}(:,2), boundaries{i,1}(:,1), cmap(i+1, :), 'FaceAlpha', 0.3);
    
end

end
