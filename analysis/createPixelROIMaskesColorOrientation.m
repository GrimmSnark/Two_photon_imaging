function createPixelROIMaskesColorOrientation(recordingDir, noColor)



% load experimentStructure
load([recordingDir 'experimentStructure.mat']);
disp('Loaded in experimentStructure');

cellROIs = experimentStructure.labeledCellROI;
cellROIs(cellROIs>0) = 255;
% cellROIs = repmat(cellROIs,1,1,3);
cellROIs = logical(cellROIs);

inverseROI = ones(size(cellROIs));
inverseROI(cellROIs>0) = 0;
inverseROI = logical(inverseROI);

for z = 1:noColor
    
    pixelImage = imread( [experimentStructure.savePath 'Pixel Orientation Pref_native_Color_' num2str(z) '.tif']);
    pixelImageMasked = nan(size(pixelImage));
    pixelImageMaskedInverse = pixelImageMasked;
    
    pixelImageMasked(cellROIs) = pixelImage(cellROIs);
    pixelImageMaskedRGB = ind2rgb(pixelImageMasked,ggb1);
    pixelImageMaskedRGB(repmat(inverseROI,1,1,3)) = 255;
    
    
    pixelImageMaskedInverse(inverseROI) = pixelImage(inverseROI);
    pixelImageMaskedInverseRGB = ind2rgb(pixelImageMaskedInverse,ggb1);
    pixelImageMaskedInverseRGB(repmat(cellROIs,1,1,3)) = 255;
    
    
    imwrite(pixelImageMaskedRGB,  [experimentStructure.savePath 'Pixel Orientation Cell Mask Pref_native_Color_' num2str(z) '.tif']);
    imwrite(pixelImageMaskedInverseRGB,  [experimentStructure.savePath 'Pixel Orientation Cell Mask Inverse Pref_native_Color_' num2str(z) '.tif']);
end




end
