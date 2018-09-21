function runPixelWiseAnalysis(recordingDir, analysisType, roiChosen, padSize, analysisFrames)

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

%% opens average file for pixel/ROI selection

if exist([recordingDirProcessed 'Average.tif'], 'file')
    imageROI = read_Tiffs([recordingDirProcessed 'Average.tif'],1);
else
    
    firstSubFolder = returnSubFolderList(recordingDirProcessed);
    
    if isempty(preproFolder2Open) % if not otherwise specified chooses the latest preprocessing folder
        preproFolder2Open = length(firstSubFolder);
    end
    
    recordingDirProcessed = [firstSubFolder(preproFolder2Open).folder '\' firstSubFolder(preproFolder2Open).name '\']; % gets analysis subfolder
    
    try
        imageROI = read_Tiffs([recordingDirProcessed 'Average.tif'],1); % reads in average image
        
    catch
        disp('Average image not found, check filepath or run prepData.m  or prepDataMultiSingle.m on the recording folder')
        return
    end
end

% initalize MIJI and get ROI manager open
intializeMIJ;
RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();


% get image to FIJI
MIJImageROI = MIJ.createImage('ROI_image',imageROI,true); %#ok<NASGU> supressed warning as no need to worry about it

%% Get imaging data and motion correct
% load experimentStructure
load([recordingDirProcessed 'experimentStructure.mat']);

vol = read_Tiffs(experimentStructure.fullfile,1);
if ndims(vol) ~=3
    vol = readMultipageTifFiles(experimentStructure.prairiePath);
end
% apply imageregistration shifts
registeredVol = shiftImageStack(vol,experimentStructure.xyShifts([2 1],:)'); % Apply actual shifts to tif stack

% transfers to FIJI
registeredVolMIJI = MIJ.createImage( 'Registered Volume', registeredVol,true);

%% Get ROIs

if exist([recordingDirProcessed 'ROIcells.zip'], 'file') % if zip file actually exists
    RC.runCommand('Open', [recordingDirProcessed 'ROIcells.zip']); % opens zip file
    ROInumber = RC.getCount();
    disp(['You have selected ' num2str(ROInumber) ' ROIs, moving onto analysis']);
    
else %if does not exist
    disp('ROI zip file not found')
end

switch analysisType
    case 'ROI_pixelLine'
        
        processPixels(roiChosen, padSize, MIJImageROI, registeredVolMIJI, registeredVol, experimentStructure);
        
    case 'Stim_STDwindow'
        
        processPixelsSTD(MIJImageROI, registeredVolMIJI, registeredVol, experimentStructure, analysisFrames);
end



end