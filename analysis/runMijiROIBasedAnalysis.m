function runMijiROIBasedAnalysis(recordingDir, overwriteROIFile, preproFolder2Open, neuropilCorrectionType, prestimTime)

%% Deals with ROI zip file creation and loading and makes neuropil surround ROIs
if exist([recordingDir 'Recording_Average_ROI_Image.tif'], 'file')
    imageROI = read_Tiffs([recordingDir 'Recording_Average_ROI_Image.tif'],1);
else
    disp('Average image not found, check filepath or run prepDataMultfileRecording.m on the recording folder')
    return
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
        response = MFquestdlg([0.5,1],sprintf(['Choose cell ROIs with magic wand tool and ctr+t to add to ROI manager \n' ...
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
    
    RC.runCommand('Save', [recordingDir 'ROIcells.zip']); % saves zip file
else % if not overwrite, then tries to find already saved ROI file
    
    if exist([recordingDir 'ROI.zip'], 'file') % if zip file actually exists
        RC.runCommand('Open', [recordingDir 'ROIcells.zip']); % opens zip file
    else %if does not exist
        disp('ROI zip file not found, adjust overwriteROIFile flag and rerun')
        return
    end
end

generateNeuropilROIs(RC.getRoisAsArray);

%% load the appropriate data subfolder, runs through all movie folders for this experiment

experimentStructure = [];

recordingFolders = returnSubFolderList(recordingDir); % gets all image runs in this experiment

for i =1:length(recordingFolders) % runs through them all to process
    
    % gets the number of analysis runs in the analysed folder
    currentRecordingFolder = [recordingDir recordingFolders(i).name];
    currentSubFolders = returnSubFolderList(currentRecordingFolder);
    
    if isempty(preproFolder2Open) % if not otherwise specified chooses the latest preprocessing folder
        preproFolder2Open = length(currentSubFolders);
    end
    
    % load experimentStructure
    load([currentRecordingFolder '\' currentSubFolders(preproFolder2Open).name '\experimentStructure.mat'], 'experimentStructure');
    
    % read in tiff file
    vol = read_Tiffs(experimentStructure.fullfile,1);
    
    % apply imageregistration shifts
    registeredVol = shiftImageStack(vol,experimentStructure.xyShifts([2 1],:)'); % Apply actual shifts to tif stack
    
    % transfers to FIJI
    currentImgStack =MIJ.createImage(registeredVol); %#ok<NASGU> supressed warning as no need to worry about it
    
    %% start running actual trace extraction
    
    experimentStructure.rawF = [];
    experimentStructure.rawF_neuropil = [];
    experimentStructure.xPos = zeros(cellNumber,1);
    experimentStructure.yPos = zeros(cellNumber,1);
    for x = 1:ROInumber
        % Select cell ROI in ImageJ
        fprintf('Processing Cell %d\n',x)
        
        % Get cell ROI name and parse out (X,Y) coordinates
        RC.select(x-1); % Select current cell
        [tempLoc1,tempLoc2] = strtok(char(RC.getName(x-1)),'-');
        experimentStructure.xPos(x) =  str2double(tempLoc1);
        experimentStructure.yPos(x) = -str2double(tempLoc2);
        
        % Get the fluorescence timecourse for the cell and neuropol ROI by
        % using ImageJ's "z-axis profile" function. We can also rename the
        % ROIs for easier identification.
        for isNeuropilROI = 0:1
            ij.IJ.getInstance().toFront();
            MIJ.run('Plot Z-axis Profile'); % For each image, this outputs four summary metrics: number of pixels (in roi), mean ROI value, min ROI value, and max ROI value
            RT = MIJ.getResultsTable();
            MIJ.run('Clear Results');
            MIJ.run('Close','');
            if isNeuropilROI
                %RC.setName(sprintf('Neuropil ROI %d',i));
                experimentStructure.rawF_neuropil(x,:) = RT(:,2);
            else
                %RC.setName(sprintf('Cell ROI %d',i));
                experimentStructure.rawF(x,:) = RT(:,2);
                RC.select((x-1)+ROInumber); % Now select the associated neuropil ROI
            end
        end
    end
    
    %% subtract neuropil signal
    
    % Compute the neuropil-contributed signal from our cells, and eliminate
    % them from our raw cellular trace
    for y = 1:cellNumber
        % Determine scaling factor
        switch neuropilCorrectionType
            case 'adaptive'
                X = cat(1,experimentStructure.rawF_neuropil(y,:),experimentStructure.rawF(y,:));
                coeffs=robustfit(X(1,:),X(2,:));
                coeffs(coeffs>1)=1;
                coeffs(coeffs<-1)=-1;
                experimentStructure.subtractionFactor(y) = coeffs(2);
            case 'fixed'
                experimentStructure.subtractionFactor(y) = 0.7; %0.3-0.6--> Kerlin et al., 2010 (Reid),  0.7--> Chen et al., 2013 (Svoboda), 0.5-0.8--> Golstein et al., 2013 (Pennartz), % 1.0-->Miller et al., 2014 (Yuste lab)
            case 'none'
                experimentStructure.subtractionFactor(y) = 0;
        end
        
        experimentStructure.correctedF(y,:) = experimentStructure.rawF(y,:)-experimentStructure.subtractionFactor(y)*experimentStructure.rawF_neuropil(y,:);
    end
    
    %% Define a moving and fluorescence baseline using a percentile filter
    experimentStructure.rate      = 1/experimentStructure.framePeriod; % frames per second
    experimentStructure.baseline  = 0*experimentStructure.correctedF;
    
    for q =1:ROInumber
        fprintf('Computing baseline for cell %d', q);
        
        % Compute a moving baseline with a 60s percentile lowpass filter smoothed by a 60s Butterworth filter
        percentileFiltCutOff = 10;
        lowPassFiltCutOff    = 60; %in seconds
        experimentStructure.baseline(q,:)  = baselinePercentileFilter(experimentStructure.correctedF(q,:)',experimentStructure.rate,lowPassFiltCutOff,percentileFiltCutOff);
    end
    
    % computer delta F/F traces
    experimentStructure.dF = (experimentStructure.correctedF-experimentStructure.baseline)./experimentStructure.baseline;
    
    %% Add some basic trace segementation into cell x cnd x trial for dF/F
    
    if isempty(behavouralResponseFlag) % if no behaviour, ie trials are the same length no fixation breaks or errors
        % works out prestim time, will use input field or 1 second default, only used if not starting trial segementation with PRESTIM_ON event
        if ~isempty(prestimTime)
            prestimFrameTime = round(prestimTime * experimentStructure.rate);
        else
            prestimFrameTime = round(1 * experimentStructure.rate);
        end
        
        % works out what frame length to cut each trial into for further
        % analysis
        if isfield(experimentStructure.EventFrameInd, 'PRESTIM_ON')
            analysisFrameLength = ceil(mean(experimentStructure.EventFrameIndx.TRIAL_END - experimentStructure.EventFrameIndx.PRESTIM_ON));
        else
            analysisFrameLength = ceil(mean(experimentStructure.EventFrameIndx.TRIAL_END - (experimentStructure.EventFrameIndx.STIM_ON- prestimFrameTime)));
            noPrestim_Flag =1; %#ok<NASGU> supressed warning as no need to worry about it
        end
        
        % chunks up dF into cell x cnd x trial
        for p = 1:ROInumber % for each cell
            for  x =1:length(experimentStructure.cndTotal) % for each condition
                if any(experimentStructure.cndTotal(x)) % checks if there are any trials of that type
                    for y =1:length(experimentStructure.cndTrials{x}) % for each trial of that type
                        
                        currentTrial = experimentStructure.cndTrials{x}(y); % gets current trial number for that cnd
                        
                        if exist('noPrestim_Flag', 'var') % deals with chunk type, ie from PRESTIM_ON or STIM_ON minus prestimTime
                            currentTrialFrameStart = experimentStructure.EventFrameIndx.STIM_ON(currentTrial);
                        else
                            currentTrialFrameStart = experimentStructure.EventFrameIndx.PRESTIM_ON(currentTrial);
                        end
                        %cell cnd trial
                        experimentStructure.dFperCnd{p}{x}(y,:) = experimentStructure.dF(p,currentTrialFrameStart:currentTrialFrameStart+ analysisFrameLength); %chunks data and sorts into structure
                    end
                end
            end
        end
    else % if there are behaviours......TO DO!!!! whenever we get to awake animals
        
        % TO DO
        % Nothing to see here
        % Move along....This is not the code you are looking for
        
    end
    
    % feeds into grand structure for all recordings
    % This is very likely to break.... FYI
    if ~exist('grandArray', 'var')
        grandStructure = [];
    end
    
    grandStructure = [grandStructure experimentStructure.dFperCnd];
    
    % do other processing specfic to the experiment ie OSIs etc
    switch experimentStructure.experimentType
        
        case 'RFmap'
            
        otherwise %'Orientation'
            
    end
    
    %% Save the updated experimentStructure
    save([currentRecordingFolder '\' currentSubFolders(preproFolder2Open).name '\experimentStructure.mat'], experimentStructure);
end % end of loop for each subfolder

%% Save the grandStructure
save([currentRecordingFolder '\grandStructure.mat'], grandStructure);

end