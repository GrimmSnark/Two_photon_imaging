function experimentStructure = doAnalysisCalciumV2(experimentStructure, prestimTime, channel2Use ,behaviouralResponseFlag)
% Function enacts main Ca trace analysis for movie files, applys motion
% correction shifts which were previously calculated, exacts rawF for cells
% and neuropil, does neuropil correction, calculates dF/F and segements out
% traces into cell x cnd x trace and makes averages & STDs per cnd
%
% Inputs - experimentStructure (structure containing all experimental data)
%
%          neuropilCorrectionType ('adaptive', 'fixed', 'none')
%
%          runFISSA - flag 0/1 to run FISSA analysis through python
%
%          prestimTime ( [], fixed prestim time for analysis before stim on,
%                      curretly not need as we have prestim events)
%
%          channel2Use - specify channel to use for Ca analysis (ie 1/2) if
%                        multichannel file, if single channel recording can
%                        be left blank
%
%          behaviouralResponseFlag (NOT used, future proofing for awake
%                                   animals)
%
% Outputs - experimentStructure (updated structure)

%Sets default channel to use for multichannel recordings
if isempty(channel2Use)
    channel2Use = 2;
end

%% Clear previously calculated stuff

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IF YOU ADD ANY MORE ANALYSIS FIELDS THEY NEED TO BE ADDED TO REMOVEFIELDS
% OTHERWISE OVERWRITE ERRROS CAN OCCUR
removeFields = { 'rawF', 'rawF_neuropil', 'xPos', 'yPos', 'rate', ...
    'baseline', 'dF', 'dFperCnd','dFperCndMean','dFperCndSTD', ...
    'meanFrameLength'};

removeFieldLogical = isfield(experimentStructure, removeFields);

if any(removeFieldLogical)
    experimentStructure = rmfield(experimentStructure, removeFields(removeFieldLogical));
end

%% Basic setup of tif stack
% sets up ROI manager for this function
RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();

% read in tiff file

vol = read_Tiffs(experimentStructure.fullfile,1);
if ndims(vol) ~=3
    vol = readMultipageTifFiles(experimentStructure.prairiePath);
end


% check number of channels in imaging stack
channelIndxStart = strfind(experimentStructure.filenamesFrame{1}, '_Ch');
for i =1:length(experimentStructure.filenamesFrame)
    channelIdentity{i} = experimentStructure.filenamesFrame{i}(channelIndxStart:channelIndxStart+3);
end
channelNo = unique(channelIdentity);

% chooses correct channel to analyse in multichannel recording
if length(channelNo)>1
    volSplit =  reshape(vol,size(vol,1),size(vol,2),[], length(channelNo));
    vol = volSplit(:,:,:,channel2Use);
end



% apply imageregistration shifts
if isfield(experimentStructure, 'options_nonrigid') && ~isempty(experimentStructure.options_nonrigid) % if using non rigid correctionn
    registeredVol = apply_shifts(vol,experimentStructure.xyShifts,experimentStructure.options_nonrigid);
else
    registeredVol = shiftImageStack(vol,experimentStructure.xyShifts([2 1],:)'); % Apply actual shifts to tif stack
end
%% FISSA neuropil extraction calculation... runs python script through win cmd
% save registered image stack if you want to run FISSA toolbox

if ~exist([experimentStructure.savePath 'FISSA\'], 'dir')
    mkdir([experimentStructure.savePath 'FISSA\']);
end

disp('Saving registered image stack')
options.overwrite = true;
saveastiff(registeredVol, [experimentStructure.savePath 'FISSA\registered.tif'], options);
disp('Finished saving registered image stack');

% create FISSA run file
createFISSARunFile(experimentStructure);

% call to system to run python file
system(['python "' experimentStructure.savePath 'FISSA\FISSA_run.py"']);

% extract out the FISSA results
experimentStructure = extractFISSA_results(experimentStructure);

% transfers to FIJI
registeredVolMIJI = MIJ.createImage( 'Registered Volume', registeredVol,true);

%% start running raw trace extraction

experimentStructure.rawF = [];
experimentStructure.xPos = zeros(experimentStructure.cellCount,1);
experimentStructure.yPos = zeros(experimentStructure.cellCount,1);
for x = 1:experimentStructure.cellCount
    % Select cell ROI in ImageJ
    fprintf('Processing Cell %d\n',x)
    
    % Get cell ROI name and parse out (X,Y) coordinates
    RC.select(x-1); % Select current cell
    [tempLoc1,tempLoc2] = strtok(char(RC.getName(x-1)),'-');
    experimentStructure.yPos(x) =  str2double(tempLoc1);
    experimentStructure.xPos(x) = -str2double(tempLoc2);
    
    % Get the fluorescence timecourse for the cell and neuropol ROI by
    % using ImageJ's "z-axis profile" function. We can also rename the
    % ROIs for easier identification.1
    ij.IJ.getInstance().toFront();
    
    % for imagej 1.50c
    %         MIJ.run('Plot Z-axis Profile'); % For each image, this outputs four summary metrics: number of pixels (in roi), mean ROI value, min ROI value, and max ROI value
    %         RT = MIJ.getResultsTable();
    %         MIJ.run('Clear Results');
    %                 MIJ.run('Close','');
    
    %   for imagej >1.50c
    plotVal = ij.plugin.ZAxisProfiler.getPlot(registeredVolMIJI);
    RT(:,1) = plotVal.getXValues();
    RT(:,2) = plotVal.getYValues();
    
    %RC.setName(sprintf('Cell ROI %d',i));
    experimentStructure.rawF(x,:) = RT(:,2);
end

%% Define a moving and fluorescence baseline using a percentile filter
experimentStructure.rate      = 1/experimentStructure.framePeriod; % frames per second
experimentStructure.baseline  = 0*experimentStructure.extractedF_FISSA;

for q =1:experimentStructure.cellCount
    fprintf('Computing baseline for cell %d \n', q);
    
    % Compute a moving baseline with a 60s percentile lowpass filter smoothed by a 60s Butterworth filter
    offset = 100; % helps get around dividing my zero errors...
    [~,percentileFiltCutOff(q)] = estimate_percentile_level((experimentStructure.extractedF_FISSA(q,:)'+offset),length(registeredVol),length(registeredVol));
    
    if      percentileFiltCutOff(q) <10
        percentileFiltCutOff(q) = 5;
    end
    
    lowPassFiltCutOff    = 30; %in seconds
    experimentStructure.baseline(q,:)  = baselinePercentileFilter((experimentStructure.extractedF_FISSA(q,:)'+offset),experimentStructure.rate,lowPassFiltCutOff,percentileFiltCutOff(q));
end

experimentStructure.percentileFiltCutOff = percentileFiltCutOff(q);

% computer delta F/F traces
experimentStructure.dF = ((experimentStructure.extractedF_FISSA+offset)-experimentStructure.baseline)./experimentStructure.baseline;

% [experimentStructure.dF2, experimentStructure.baseline2, experimentStructure.sn] = estimate_baseline((experimentStructure.extractedF_FISSA+offset)-experimentStructure.baseline, experimentStructure);
%

% experimentStructure = baselineCalAM((experimentStructure.extractedF_FISSA+offset),experimentStructure);

%% Add some basic trace segementation into cell x cnd x trial for dF/F

if isempty(behaviouralResponseFlag) % if no behaviour, ie trials are the same length no fixation breaks or errors
    % works out prestim time, will use input field or 1 second default, only used if not starting trial segementation with PRESTIM_ON event
    if ~isempty(prestimTime)
        prestimFrameTime = round(prestimTime * experimentStructure.rate);
    else
        prestimFrameTime = round(1 * experimentStructure.rate);
    end
    
    % works out what frame length to cut each trial into for further
    % analysis
    if isfield(experimentStructure.EventFrameIndx, 'PRESTIM_ON')
        analysisFrameLength = ceil(mean(experimentStructure.EventFrameIndx.TRIAL_END - experimentStructure.EventFrameIndx.PRESTIM_ON));
        stimOnFrames = [ceil(mean(experimentStructure.EventFrameIndx.STIM_ON - experimentStructure.EventFrameIndx.PRESTIM_ON))+1 ...
            ceil(mean(experimentStructure.EventFrameIndx.STIM_OFF - experimentStructure.EventFrameIndx.PRESTIM_ON))-1];
    else
        analysisFrameLength = ceil(mean(experimentStructure.EventFrameIndx.TRIAL_END - (experimentStructure.EventFrameIndx.STIM_ON- prestimFrameTime)));
        stimOnFrames = [ceil(mean(experimentStructure.EventFrameIndx.STIM_ON -(experimentStructure.EventFrameIndx.STIM_ON- prestimFrameTime)))-1 ...
            ceil(mean(experimentStructure.EventFrameIndx.STIM_OFF - (experimentStructure.EventFrameIndx.STIM_ON- prestimFrameTime)))-1];
        noPrestim_Flag =1; %#ok<NASGU> supressed warning as no need to worry about it
    end
    
    experimentStructure.meanFrameLength = analysisFrameLength; % saves the analysis frame length into structure, just FYI
    experimentStructure.stimOnFrames = stimOnFrames; % saves the frame index for the trial at which stim on and off occured, ie [7 14] from prestim on
    
    % chunks up dF into cell x cnd x trial
    for p = 1:experimentStructure.cellCount % for each cell
        for  x =1:length(experimentStructure.cndTotal) % for each condition
            if any(experimentStructure.cndTotal(x)) % checks if there are any trials of that type
                for y =1:length(experimentStructure.cndTrials{x}) % for each trial of that type
                    
                    currentTrial = experimentStructure.cndTrials{x}(y); % gets current trial number for that cnd
                    
                    if exist('noPrestim_Flag', 'var') % deals with chunk type, ie from PRESTIM_ON or STIM_ON minus prestimTime
                        currentTrialFrameStart = experimentStructure.EventFrameIndx.STIM_ON(currentTrial)- prestimFrameTime;
                    else
                        currentTrialFrameStart = experimentStructure.EventFrameIndx.PRESTIM_ON(currentTrial);
                    end
                    %full trial prestimON-trialEND cell cnd trial
                    experimentStructure.dFperCnd{p}{x}(:,y) = experimentStructure.dF(p,currentTrialFrameStart:currentTrialFrameStart+ (analysisFrameLength-1)); %chunks data and sorts into structure
                    
                    % prestim response and average response per cell x cnd x trial
                    
                    if exist('noPrestim_Flag', 'var') % deals with chunk type, ie from PRESTIM_ON or STIM_ON minus prestimTime
                        experimentStructure.dFpreStimWindow{p}{y,x} = experimentStructure.dF(p,currentTrialFrameStart:experimentStructure.EventFrameIndx.STIM_ON(currentTrial)-1);
                    else
                        experimentStructure.dFpreStimWindow{p}{y,x} = experimentStructure.dF(p,currentTrialFrameStart:experimentStructure.EventFrameIndx.PRESTIM_OFF(currentTrial)-1);
                    end
                    
                    experimentStructure.dFpreStimWindowAverage{p}{y,x} = mean(experimentStructure.dFpreStimWindow{p}{y,x});
                    
                    % stim response and average response per cell x cnd x trial
                    
                    experimentStructure.dFstimWindow{p}{y,x} = experimentStructure.dF(p,experimentStructure.EventFrameIndx.STIM_ON(currentTrial):experimentStructure.EventFrameIndx.STIM_OFF(currentTrial));
                    experimentStructure.dFstimWindowAverage{p}{y,x} = mean(experimentStructure.dFstimWindow{p}{y,x});
                end
            end
        end
    end
else % if there are behaviours......TO DO!!!! whenever we get to awake animals
    
    % TO DO
    % Nothing to see here
    % Move along....This is not the code you are looking for
    
end

% sets up average traces per cnd and STDs
for i = 1:length(experimentStructure.dFperCnd) % for each cell
    for x = 1:length(experimentStructure.dFperCnd{i}) % for each condition
        experimentStructure.dFperCndMean{i}(:,x) = mean(experimentStructure.dFperCnd{i}{x}, 2); % means for each cell frame value x cnd
        experimentStructure.dFperCndSTD{i}(:,x) = std(experimentStructure.dFperCnd{i}{x}, 0, 2); % std for each cell frame value x cnd
    end
end

experimentStructure = calculateDFOnFrameBeforeStimOn(experimentStructure);


% % do other processing specfic to the experiment ie OSIs etc
% switch experimentStructure.experimentType
%
%     case 'RFmap'
%
%     otherwise %'Orientation'
%
% end

%% Save the updated experimentStructure
save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure');
end