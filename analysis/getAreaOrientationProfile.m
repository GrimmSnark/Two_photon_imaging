function getAreaOrientationProfile(recordingDir, chunkBefore, chunkAfter)

recordingDir = 'D:\Data\2P_Data\Processed\Mouse\gCamp6s\M3\5on_5off_7\TSeries-09242018-1042-009\20180927122400\';
chunkBefore = 7;
chunkAfter = 10;
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
    imageROI = read_Tiffs([recordingDirProcessed 'STD_Stim_sum.tif'],1);
else
    
    firstSubFolder = returnSubFolderList(recordingDirProcessed);
    
    if isempty(preproFolder2Open) % if not otherwise specified chooses the latest preprocessing folder
        preproFolder2Open = length(firstSubFolder);
    end
    
    recordingDirProcessed = [firstSubFolder(preproFolder2Open).folder '\' firstSubFolder(preproFolder2Open).name '\']; % gets analysis subfolder
    
    try
        imageROI = read_Tiffs([recordingDirProcessed 'STD_Stim_sum.tif'],1); % reads in average image
        
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

% load experimentStructure
load([recordingDirProcessed 'experimentStructure.mat']);

%% Get ROIs

if exist([recordingDirProcessed 'ROIcells.zip'], 'file') % if zip file actually exists
    RC.runCommand('Open', [recordingDirProcessed 'ROIcells.zip']); % opens zip file
    ROInumber = RC.getCount();
    disp(['You have selected ' num2str(ROInumber) ' ROIs, moving onto analysis']);
    
else %if does not exist
    disp('ROI zip file not found')
end


% select region in Average image

pause

ROI = MIJImageROI.getRoi;
registeredVolMIJI.setRoi(ROI);
% get selected region trace


plot = ij.plugin.ZAxisProfiler.getPlot(registeredVolMIJI);
RT(:,1) = plot.getXValues();
RT(:,2) = plot.getYValues();

rawFTrace = RT(:,2);

% split up in cnds

for  x =1:length(experimentStructure.cndTotal) % for each condition
    for y =1:length(experimentStructure.cndTrials{x}) % for each trial of that type
        
        currentTrial = experimentStructure.cndTrials{x}(y); % gets current trial number for that cnd
        
        currentChunk =  experimentStructure.EventFrameIndx.STIM_ON(currentTrial)-chunkBefore:experimentStructure.EventFrameIndx.STIM_ON(currentTrial)+chunkAfter;
        
        traceChunked(x,y,:)= rawFTrace(currentChunk);
        
    end
end

% plot cnds
cndMeans = squeeze(mean(traceChunked,2));
cndStds = squeeze(std(traceChunked,[],2));

figure;
figHandleAx = gca;
hold on

for i =1:size(cndMeans,1)
      lengthOfData = length(cndMeans);
    if i >1
        spacing = 5;
        xlocations = ((lengthOfData +lengthOfData* (i-1))- (lengthOfData-1) :lengthOfData + lengthOfData* (i-1)) + spacing*(i-1);
        xlocationMid(i) = xlocations(lengthOfData/2);
        stimOnY(i)=xlocations(1)+chunkBefore;
        stimOffY(i) = stimOnY(i) + (experimentStructure.stimOnFrames(2) - experimentStructure.stimOnFrames(1));
    else
        spacing = 0;
        xlocations = 0:lengthOfData-1;
        xlocationMid(i) = xlocations(lengthOfData/2);
        stimOnY(i)=xlocations(1)+chunkBefore;
         stimOffY(i) = stimOnY(i) + (experimentStructure.stimOnFrames(2) - experimentStructure.stimOnFrames(1));
    end
    
    errorbar(figHandleAx, xlocations, cndMeans(i,:), cndStds(i,:), 'Color' , 'k')
end

xticks(xlocationMid);
xticklabels(0:45:315);

vline(stimOnY, 'r')
vline(stimOffY, 'r')

end