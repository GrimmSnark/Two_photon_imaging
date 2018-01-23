function [experimentStructure, vol]= prepImagingData(path2ImagingFolder)
% This should read in metadata into experimentStructure and read in imaging
% files into vol as a pixel x pixel x frame array

experimentStructure.prairiePath = path2ImagingFolder;
experimentStructure = prepImagingMetaData(experimentStructure, experimentStructure.prairiePath);

frameFilepath = [experimentStructure.prairiePath experimentStructure.filenamesFrame{1,1}];
vol = imreadBF(frameFilepath,1,1:length(experimentStructure.filenamesFrame),1);
%StackSlider(vol); % will display the stack of images, need to click
%greyscale button

end