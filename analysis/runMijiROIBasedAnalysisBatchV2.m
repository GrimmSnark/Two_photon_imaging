function runMijiROIBasedAnalysisBatchV2(recordingDir, recordingType, preproFolder2Open, prestimTime, channel2Use)
% function which runs main analysis on calcium imaging data recorded on
% prairie bruker system. This function requires user input to define cell
% ROIs and calculates dF/F with neuropil subtraction. Also splits dF traces
% into cell x cnd x trials and calculates mean and std per cell per cnd
%
% Simplied version with uses FISSA neuropil extraction and also calculates
% another version of dF/F based on frame before stimulus (FBS) baseline
%
% Inputs - recordingDir (folder location which contains the T series folder
%                       imaging runs, can be processed or raw folder)
%
%          recordingType ('Single' or 'Multi' for number of t series
%                        folders found in the recordingDir, will also be
%                        dictated by whether you used prepDataMultiSingle
%                        or prepDataMultfileRecording)
%
%
%          preproFolder2Open (usually leave blank unless you want to
%                             specify the preprocessed folder number 1,2
%                             etc to use)
%
%          prestimTime ( [], fixed prestim time for analysis before stim on,
%                      curretly not need as we have prestim events)
%          channel2Use - specify channel to use for Ca analysis (ie 1/2) if
%                        multichannel file, if single channel recording can
%                        be left blank 
%
%          behaviouralResponseFlag (NOT used, future proofing for awake
%                                   animals)


%%
% Sets behavioural data flag to empty as not currently used

    behaviouralResponseFlag =[];
% 

%% create appropriate filepaths
if contains(recordingDir, 'Raw') % if you specfy the raw folder then it finds the appropriate processed folder
    recordingDirRAW = recordingDir; % sets raw data path
    
    % sets processed data path
    recordingDirProcessed = createSavePath(recordingDir, 1, 1);
    recordingDirProcessed = recordingDirProcessed(1: find(recordingDirProcessed =='\', 2, 'last'));
    
elseif  contains(recordingDir, 'Processed')
    recordingDirProcessed = recordingDir; % sets processed data path
    recordingDirRAW = createRawFromSavePath(recordingDir); % sets raw data path
end

% load in pointers to ROI manager
RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();


% load in ROI file
if exist([recordingDirProcessed 'ROIcells.zip'], 'file') % if zip file actually exists
    RC.runCommand('Open', [recordingDirProcessed 'ROIcells.zip']); % opens zip file
    ROInumber = RC.getCount();
    disp(['You have selected ' num2str(ROInumber) ' ROIs, moving onto analysis']);
    
else%if does not exist
    
    firstSubFolder = returnSubFolderList(recordingDirProcessed);
    
    if isempty(preproFolder2Open) % if not otherwise specified chooses the latest preprocessing folder
        preproFolder2Open = length(firstSubFolder);
    end
    
    recordingDirProcessed = [firstSubFolder(preproFolder2Open).folder '\' firstSubFolder(preproFolder2Open).name '\']; % gets analysis subfolder
    
    RC.runCommand('Open', [recordingDirProcessed 'ROIcells.zip']); % opens zip file
    ROInumber = RC.getCount();
    disp(['You have selected ' num2str(ROInumber) ' ROIs, moving onto analysis']);
    
    %     disp('ROI zip file not found, adjust overwriteROIFile flag and rerun')
    %     return
end

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
        
        % sets ROI image for cells
        ROIobjects = RC.getRoisAsArray;
        cellROIs = ROIobjects(1:ROInumber);
        experimentStructure.labeledCellROI = createLabeledROIFromImageJPixels([experimentStructure.pixelsPerLine experimentStructure.pixelsPerLine], cellROIs);
        
        % does main analysis
        experimentStructure = doAnalysisCalciumV2(experimentStructure, prestimTime, channel2Use, behaviouralResponseFlag);
        
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
    experimentStructure.labeledCellROI = createLabeledROIFromImageJPixels([experimentStructure.pixelsPerLine experimentStructure.pixelsPerLine], cellROIs);    
    % does main analysis
    experimentStructure = doAnalysisCalciumV2(experimentStructure, prestimTime, channel2Use, behaviouralResponseFlag);    
end

%% Save the grandStructure if multi FOV folder
if strcmp(recordingType, 'Multi')
    save([recordingDirProcessed 'grandStructure.mat'], 'grandStructure');
end

% Clean up windows
MIJ.closeAllWindows;
end