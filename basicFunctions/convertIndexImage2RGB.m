function rgbImg = convertIndexImage2RGB(indxImg, colormap, minVal, maxVal)
% Function to convert indexed image to rgb without any scaling issues
% Inputs - indxImg: imdex image array
%          colormap: colormap to use
%          minVal: optional if you want to normalise to a particular value
%          maxVal: same as above

% rescale
if nargin <3
    minVal = min(indxImg(:));
    maxVal = max(indxImg(:));
end
indxImgNorm = (indxImg - minVal)/(maxVal - minVal);


%map onto colormap
indxImgNormRescaled = indxImgNorm*length(colormap);
rgbImg = ind2rgb(round(indxImgNormRescaled), colormap);
end