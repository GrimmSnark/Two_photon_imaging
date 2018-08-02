function [experimentStructure, vol]= prepImagingData(experimentStructure, path2ImagingFolder, Z_or_TStack, loadMetaData, varargin)
% This should read in metadata into experimentStructure and read in imaging
% files into vol as a pixel x pixel x frame array, Z_or_TStack set as 1 for
% Z stack, set as 2 for T stack


experimentStructure.prairiePath = path2ImagingFolder; % sets folder path

if loadMetaData ==1 %  if metal exsists from praire xml file
    experimentStructure = prepImagingMetaData(experimentStructure, experimentStructure.prairiePath); % gets metadata from the xml files
    frameFilepath = [experimentStructure.prairiePath experimentStructure.filenamesFrame{1,1}]; %builds fullfile location for images
    
    if ~isempty(varargin) % if only one channel specficied
        channelToload =  varargin{1};
        numOfFrames = length(experimentStructure.filenamesFrame)/2;
    else
        channelToload = 1;
        numOfFrames = length(experimentStructure.filenamesFrame);
    end
    
else
    file = dir([experimentStructure.prairiePath '*.tif']);
    frameFilepath = [experimentStructure.prairiePath file.name ];
    meta=imreadBFmeta(frameFilepath);
    numOfFrames = meta.nframes;
    channelToload = 1;
end

%
% if exist('channelToUse', 'var' ) % limits filenames to just the channel picked if one is specified
%     experimentStructure.filenamesFrame(~contains(experimentStructure.filenamesFrame, ['Ch' num2str(channelToUse)])) = [];
% end
%

tic
if Z_or_TStack == 1 % if z stack
    vol = imreadBF(frameFilepath,1:numOfFrames,1,channelToload);
elseif  Z_or_TStack == 2 % if t stack
    vol = imreadBF(frameFilepath,1,1:numOfFrames,channelToload);
end
toc

% TODO work out how to deal with z and t stacks together...

%StackSlider(vol); % will display the stack of images, need to click
%greyscale button

end