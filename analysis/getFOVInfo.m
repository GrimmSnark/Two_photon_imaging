function [imageROI, imageLoc, micronsPerPixel , objectiveMag] =  getFOVInfo(recordingDir)
% retrives average recording image, location and magnification for future
% analysis

%% creates the appropriate filepaths
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


%% opens average file for pixel/ROI selection

if exist([recordingDirProcessed 'STD_Stim_Sum.tif'], 'file')
    imageROI = read_Tiffs([recordingDirProcessed 'STD_Stim_Sum.tif'],1);
else
    
    firstSubFolder = returnSubFolderList(recordingDirProcessed);
    
    if isempty(preproFolder2Open) % if not otherwise specified chooses the latest preprocessing folder
        preproFolder2Open = length(firstSubFolder);
    end
    
    recordingDirProcessed = [firstSubFolder(preproFolder2Open).folder '\' firstSubFolder(preproFolder2Open).name '\']; % gets analysis subfolder
    
    try
        imageROI = read_Tiffs([recordingDirProcessed 'STD_Stim_Sum.tif'],1); % reads in average image
        
    catch
        disp('Average image not found, check filepath or run prepData.m  or prepDataMultiSingle.m on the recording folder')
        return
    end
end

imageLoc = experimentStructure.currentPostion;
objectiveMag = experimentStructure.lensMag;
micronsPerPixel = experimentStructure.micronsPerPixel;

end