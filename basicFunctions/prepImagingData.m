function [experimentStructure, vol]= prepImagingData(path2ImagingFolder, Z_or_TStack)
% This should read in metadata into experimentStructure and read in imaging
% files into vol as a pixel x pixel x frame array, Z_or_TStack set as 1 for
% Z stack, set as 2 for T stack

experimentStructure.prairiePath = path2ImagingFolder;
experimentStructure = prepImagingMetaData(experimentStructure, experimentStructure.prairiePath);

frameFilepath = [experimentStructure.prairiePath experimentStructure.filenamesFrame{1,1}];

if Z_or_TStack == 1
    vol = imreadBF(frameFilepath,1:length(experimentStructure.filenamesFrame),1,1);
elseif  Z_or_TStack == 2
    vol = imreadBF(frameFilepath,1,1:length(experimentStructure.filenamesFrame),1);
end

%StackSlider(vol); % will display the stack of images, need to click
%greyscale button

end