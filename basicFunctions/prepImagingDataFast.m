function [experimentStructure, vol]= prepImagingDataFast(experimentStructure, path2ImagingFolder, loadMetaData)
% This should read in metadata into experimentStructure and read in imaging
% files into vol as a pixel x pixel x frame array. Fast version but reads
% all channels and z series together. Stack needs to be split depending on
% iamaging parameters

experimentStructure.prairiePath = [path2ImagingFolder '\']; % sets folder path

if loadMetaData ==1 %  if metal exsists from praire xml file
    experimentStructure = prepImagingMetaData(experimentStructure, experimentStructure.prairiePath); % gets metadata from the xml files
    frameFilepath = [experimentStructure.prairiePath experimentStructure.filenamesFrame{1,1}]; %builds fullfile location for images
else
    file = dir([experimentStructure.prairiePath '*.tif']);
    frameFilepath = [experimentStructure.prairiePath file(1).name ];
end

experimentStructure.fullfile = frameFilepath;


vol = read_Tiffs(frameFilepath,1);
if ndims(vol) ~=3
    vol = readMultipageTifFiles(experimentStructure.prairiePath);
end

% TODO work out how to deal with z and t stacks together...

%StackSlider(vol); % will display the stack of images, need to click
%greyscale button

end