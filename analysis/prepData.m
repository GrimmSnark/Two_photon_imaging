function [experimentStructure , vol] =  prepData(dataDir, regOrNot)
% This function does basic preprocessing of t series imaging data inlcuding
% meta data and trial data extraction and image registration
% wrapper script for reading all the experiment and imaging meta data
% Input is image data directory for the t series and outputs
% experimentStructure and registered stack of image data, regOrNot is a 0/1
% flag to run the image registration

% dataDir = 'D:\Data\2P_Data\Raw\Mouse\Vascular\vasc_mouse1\';
 experimentStructure = [];


% get imaging meta data and trial data
experimentStructure = prepImagingMetaData(experimentStructure, dataDir);
experimentStructure = prepTrialData(experimentStructure, experimentStructure.prairiePathVoltage, 0, [], 0);

% start image processing
[experimentStructure, vol]= prepImagingData(experimentStructure, dataDir, 2, 0);

% Register imaging data
if regOrNot ==1
[vol,xyShifts] = imageRegistration(vol);
end

MIJImgStack = MIJ.createImage('Imaging data',vol,true);

end