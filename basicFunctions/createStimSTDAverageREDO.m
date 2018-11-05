function createStimSTDAverageREDO(recordingDir)
% Resave stim sum images for the recordings, written to fix previous level
% clipping error

if contains(recordingDir, 'Raw') % if you specfy the raw folder then it finds the appropriate processed folder
    recordingDirRAW = recordingDir; % sets raw data path
    
    % sets processed data path
    recordingDirProcessed = createSavePath(recordingDir, 1, 1);
    recordingDirProcessed = recordingDirProcessed(1: find(recordingDirProcessed =='\', 2, 'last'));
    
elseif  contains(recordingDir, 'Processed')
    recordingDirProcessed = recordingDir; % sets processed data path
    recordingDirRAW = createRawFromSavePath(recordingDir); % sets raw data path
end


% load experimentStructure
load([recordingDirProcessed 'experimentStructure.mat']);

stimSTDImage = reshape(experimentStructure.stimSTDImageCND,  experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine,[]);
stimSTDSum = rescale(sum(stimSTDImage, 3))*65535; % rescales to 16 bit image without clipping or loss...
stimSTDSum = uint16(stimSTDSum);

preStimSTDImage = reshape(experimentStructure.preStimSTDImageCND,  experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine,[]);
preStimSTDSum = rescale(sum(preStimSTDImage, 3))*65535; % rescales to 16 bit image without clipping or loss...
preStimSTDSum = uint16(preStimSTDSum);


%save images
saveastiff(stimSTDSum, [experimentStructure.savePath 'STD_Stim_Sum.tif']);
saveastiff(preStimSTDSum, [experimentStructure.savePath 'STD_Prestim_Sum.tif']);

end
