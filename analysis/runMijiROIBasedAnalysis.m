function runMijiROIBasedAnalysis(recordingDir, recordingType, overwriteROIFile, preproFolder2Open, neuropilCorrectionType, runFISSA, prestimTime, behaviouralResponseFlag)
% function which runs main analysis on calcium imaging data recorded on
% prairie bruker system. This function requires user input to define cell
% ROIs and calculates dF/F with neuropil subtraction. Also splits dF traces
% into cell x cnd x trials and calculates mean and std per cell per cnd
% Inputs - recordingDir (folder location which contains the T series folder
%                       imaging runs, can be processed or raw folder)
%
%          recordingType ('Single' or 'Multi' for number of t series
%                        folders found in the recordingDir, will also be
%                        dictated by whether you used prepDataMultiSingle
%                        or prepDataMultfileRecording)
%
%          overwriteROIFile (set 0 or 1, if set 1 will look for previously
%                           chosen ROI file)
%
%          preproFolder2Open (usually leave blank unless you want to
%                             specify the preprocessed folder number 1,2
%                             etc to use)
%
%          neuropilCorrectionType ('adaptive', 'fixed', 'none')
%
%          runFISSA ( 0/1 flag to run FISSA toolbox for data extraction)
%
%          prestimTime ( [], fixed prestim time for analysis before stim on,
%                      curretly not need as we have prestim events)
%
%          behaviouralResponseFlag (NOT used, future proofing for awake
%                                   animals)

%%
% Sets behavioural data flag to empty as not currently used
if nargin<8
    behaviouralResponseFlag =[];
end
%% Deals with ROI zip file creation and loading and makes neuropil surround ROIs

if contains(recordingDir, 'Raw') % if you specfy the raw folder then it finds the appropriate processed folder
    recordingDirRAW = recordingDir; % sets raw data path
    
    % sets processed data path
    recordingDirProcessed = createSavePath(recordingDir, 1, 1);
    recordingDirProcessed = recordingDirProcessed(1: find(recordingDirProcessed =='\', 2, 'last'));
    
elseif  contains(recordingDir, 'Processed')
    recordingDirProcessed = recordingDir; % sets processed data path
    recordingDirRAW = createRawFromSavePath(recordingDir); % sets raw data path
end

switch recordingType % decides if the requested folder for analysis is a single view movie or multiple movies of the same FOV
    
    case 'Single'
        
        %         if exist([recordingDirProcessed 'STD_Average.tif'], 'file')
        %             imageROI = read_Tiffs([recordingDirProcessed 'STD_Average.tif'],1);
        
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
        
    case 'Multi'
        
        firstSubFolder = returnSubFolderList(recordingDirProcessed);
        recordingDirProcessed = [recordingDirProcessed firstSubFolder(1).name '\'];
        
        if exist([recordingDirProcessed 'Recording_Average_ROI_Image.tif'], 'file')
            imageROI = read_Tiffs([ recordingDirProcessed 'Recording_Average_ROI_Image.tif'],1); % reads in average image
        else
            disp('Average image not found, check filepath or run prepDataMultfileRecording.m on the recording folder')
            return
        end
end

% initalize MIJI and get ROI manager open
intializeMIJ;
RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();
RC.runCommand('Show All without labels');
MIJ.run("Cell Magic Wand Tool");


% get image to FIJI
MIJImageROI = MIJ.createImage('ROI_image',imageROI,true); %#ok<NASGU> supressed warning as no need to worry about it

if overwriteROIFile
    % Sets up diolg box to allow for user input to choose cell ROIs
    happy = 0;
    while ~happy % loops for a long as you need to if you do not exit or choose continue, ie reset number of ROIs
        response = MFquestdlg([0.5,1],sprintf(['Choose cell ROIs with magic wand tool and "t" to add to ROI manager \n' ...
            'If you are happy to move on with analysis click Continue \n' ...
            'If you want to clear all current ROIs click Clear All \n' ...
            'Or exit out of this window to exit script']), ...
            'Wait for user to do stuff', ...
            'Continue', ...
            'Clear All', ...
            'Continue');
        
        if isempty(response) || strcmp(response, 'Continue')
            happy =1; % kicks you out of loop if continue or exit
        else
            RC.runCommand('Delete'); % resets ROIs if you select clear all
        end
    end
    
    switch response
        
        case ''
            disp('Please restart script'); % if exit, ends script
            return
            
        case 'Continue' % if continue, goes on with analysis
            ROInumber = RC.getCount();
            disp(['You have selected ' num2str(ROInumber) ' ROIs, moving onto analysis']);
    end
    
    RC.runCommand('Save', [recordingDirProcessed 'ROIcells.zip']); % saves zip file
else % if not overwrite, then tries to find already saved ROI file
    
    if exist([recordingDirProcessed 'ROIcells.zip'], 'file') % if zip file actually exists
        RC.runCommand('Open', [recordingDirProcessed 'ROIcells.zip']); % opens zip file
        ROInumber = RC.getCount();
        disp(['You have selected ' num2str(ROInumber) ' ROIs, moving onto analysis']);
        
    else %if does not exist
        disp('ROI zip file not found, adjust overwriteROIFile flag and rerun')
        return
    end
end

% calculate average cell ROI radius
averageROIRadius = calculateNeuropilRoiRadius(RC.getRoisAsArray);

% get cell ROI radius, match neuropil ROI radius
neuropilRois = generateNeuropilROIs(RC.getRoisAsArray,(averageROIRadius*2)); % generates neuropil surround ROIs

%% load the appropriate data subfolder, runs through all movie folders for this experiment

if strcmp(recordingType, 'Multi') % for multi video FOVs
    recordingDirProcessedRoot = recordingDirProcessed(1: find(recordingDirProcessed =='\', 2, 'last'));
    recordingFolders = returnSubFolderList(recordingDirProcessedRoot); % gets all image runs in this experiment
    recordingFolders = recordingFolders(2:end);
    
    for i =1:length(recordingFolders) % runs through them all to process (skips folder which contains recording average ROI image)
        
        % gets the number of analysis runs in the analysed folder
        currentRecordingFolder = [recordingDirProcessedRoot recordingFolders(i).name];
        currentSubFolders = returnSubFolderList(currentRecordingFolder);
        
        if isempty(preproFolder2Open) % if not otherwise specified chooses the latest preprocessing folder
            preproFolder2Open = length(currentSubFolders);
        end
        
        % load experimentStructure
        load([currentRecordingFolder '\' currentSubFolders(preproFolder2Open).name '\experimentStructure.mat'], 'experimentStructure');
        
        % feeds in data into experiement structure
        experimentStructure.cellCount = ROInumber; % cell number
        
        % sets ROI image for both cells and surround neuropil ROIs
        ROIobjects = RC.getRoisAsArray;
        cellROIs = ROIobjects(1:ROInumber);
        neuropilROIs = ROIobjects(ROInumber+1:end);
        experimentStructure.labeledCellROI = createLabeledROIFromImageJPixels([experimentStructure.pixelsPerLine experimentStructure.pixelsPerLine], cellROIs);
        experimentStructure.labeledNeuropilROI = createLabeledROIFromImageJPixels([experimentStructure.pixelsPerLine experimentStructure.pixelsPerLine], neuropilROIs);
        experimentStructure.averageROIRadius = averageROIRadius;
        
        % does main analysis
        experimentStructure = doAnalysisCalcium(experimentStructure, neuropilCorrectionType, runFISSA, prestimTime, behaviouralResponseFlag);
        
        % feeds into grand structure for all recordings
        % This is very likely to break.... FYI
        if strcmp(recordingType, 'Multi')
            if ~exist('grandStructure', 'var')
                grandStructure = [];
            end
            grandStructure = combineExperimentStructure(grandStructure, experimentStructure); % combine experimentStruct for each run
        end
        
        openImages = MIJ.getListImages;
        % closes all MIJI windows
        for x = 1:length(openImages)
            ij.IJ.selectWindow(openImages(x));
            MIJ.run("Close")
        end
        
    end % end of loop for each subfolder
    
else % for single video FOVs
    
    % load experimentStructure
    load([recordingDirProcessed 'experimentStructure.mat']);
    
    
    % feeds in data into experiement structure
    experimentStructure.cellCount = ROInumber;
    
    % sets ROI image for both cells and surround neuropil ROIs
    ROIobjects = RC.getRoisAsArray;
    cellROIs = ROIobjects(1:ROInumber);
    neuropilROIs = ROIobjects(ROInumber+1:end);
    experimentStructure.labeledCellROI = createLabeledROIFromImageJPixels([experimentStructure.pixelsPerLine experimentStructure.pixelsPerLine], cellROIs);
    experimentStructure.labeledNeuropilROI = createLabeledROIFromImageJPixels([experimentStructure.pixelsPerLine experimentStructure.pixelsPerLine], neuropilROIs);
    experimentStructure.averageROIRadius = averageROIRadius;
    
    % does main analysis
    experimentStructure = doAnalysisCalcium(experimentStructure, neuropilCorrectionType, runFISSA, prestimTime, behaviouralResponseFlag);
    
end


%% Save the grandStructure if multi FOV folder
if strcmp(recordingType, 'Multi')
    save([recordingDirProcessed 'grandStructure.mat'], 'grandStructure');
end

% Clean up windows
MIJ.closeAllWindows;

end