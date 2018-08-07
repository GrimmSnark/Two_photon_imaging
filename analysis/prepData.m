function [stdVol] = prepData(dataDir, loadMeta, regOrNot, saveRegMovie, experimentType, templateImageForReg)
% This function does basic preprocessing of t series imaging data including
% meta data, trial data extraction and image registration
% Input- dataDir: image data directory for the t series
%        loadMeta: flag 1/0 for loading experiment metadata from xml file
%        regOrNot: flag 1/0 for running image registration
%        saveRegMovie: flag for save registered movie file, not necessary
%        and takes up time/space
%        experimentType: String of experiment type, ie 'orientation' etc
%        decides whether to load trial data and in what format
%        templateImageForReg: 2D image array which is used for registering
%        tif stack (used for multiple tif stacks in the same recording
%        session), leave blank ([]), if not in use
%
% Output- stdVol: standard deviation average of the movie file after motion
%         correction


% dataDir = 'D:\Data\2P_Data\Raw\Mouse\Vascular\vasc_mouse1\';
experimentStructure = [];

experimentStructure.experimentType = experimentType;

savePath = createSavePath(dataDir, 1);

experimentStructure.savePath = savePath;

% get imaging meta data and trial data
% start image processing
[experimentStructure, vol]= prepImagingDataFast(experimentStructure, dataDir, loadMeta); % faster version
% [experimentStructure, vol]= prepImagingData(experimentStructure, dataDir, Z_or_TStack, 1);

if isfield( experimentStructure, 'micronsPerPixel')
    micronsPerPix = experimentStructure.micronsPerPixel(1,1);
else
    micronsPerPix =[];
end

if ~isempty(experimentType)
    experimentStructure = prepTrialData(experimentStructure, experimentStructure.prairiePathVoltage, 0, [], experimentType);
end

% Register imaging data and save registered image stack
if regOrNot ==1
    disp('Starting image registration');
    [vol,xyShifts] = imageRegistration(vol, [], micronsPerPix, [], templateImageForReg);
    experimentStructure.xyShifts = xyShifts;
    
    if saveRegMovie ==1
        %         savePath = createSavePath(dataDir, 1);
        disp('Saving registered image stack')
        saveastiff(vol, [savePath 'registered.tif']);
        disp('Finished saving registered image stack');
        %     saveImagingData(vol,savePath,1,size(vol,3));
    end
end

% Create STD average image and save
stdVol = std(double(vol), [], 3);
stdVol = uint16(stdVol);
saveastiff(stdVol, [savePath 'STD_Average.tif']);

%Create normal average image and save
meanVol = mean(double(vol),3);
meanVol = uint16(meanVol);
saveastiff(meanVol, [savePath 'Average.tif']);

% save experimentStructure
    save([savePath 'experimentStructure.mat'], 'experimentStructure');

end