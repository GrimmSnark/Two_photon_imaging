function rgbImg = convertIndexImage2RGB(indxImg, colormap)
% Function to convert indexed image to rgb without any scaling issues
% Inputs - indxImg: imdex image array
%          colormap: colormap to use

% rescale
indxImgNorm = rescale(indxImg);


%map onto colormap
indxImgNormRescaled = indxImgNorm*length(colormap);
rgbImg = ind2rgb(round(indxImgNormRescaled), colormap);

% convert to 8bit rgb
rgbImg = uint8(floor(rgbImg*256));
end