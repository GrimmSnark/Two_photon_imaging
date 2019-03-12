function prepData(dataDir, loadMeta, regOrNot, saveRegMovie, experimentType, channel2register, templateImageForReg, useBrightestFrameAlignment)
% This function does basic preprocessing of t series imaging data including
% meta data, trial data extraction and image registration
% Input- dataDir: image data directory for the t series
%
%        loadMeta: flag 1/0 for loading experiment metadata from xml file
%
%        regOrNot: flag 1/0 for running image registration
%
%        saveRegMovie: flag for save registered movie file, not necessary
%        and takes up time/space
%
%        experimentType: String of experiment type, ie 'orientation' etc
%        decides whether to load trial data and in what format
%
%        channel2register: can speicfy channel to register the stack with
%        if there are more than one recorded channel
%
%        templateImageForReg: 2D image array which is used for registering
%        tif stack (used for multiple tif stacks in the same recording
%        session), leave blank ([]), if not in use
%
%        useBrightestFrameAlignment: 1/0 flag to use average of brightest
%        frames in stack for image registration template


% dataDir = 'D:\Data\2P_Data\Raw\Mouse\Vascular\vasc_mouse1\';
experimentStructure = [];
defaultRegChannel = 1;

experimentStructure.experimentType = experimentType;

savePath = createSavePath(dataDir, 1);

experimentStructure.savePath = savePath;

% get imaging meta data and trial data
% start image processing
[experimentStructure, vol]= prepImagingDataFast(experimentStructure, dataDir, loadMeta); % faster version
% [experimentStructure, vol]= prepImagingData(experimentStructure, dataDir, Z_or_TStack, 1);

% check number of channels in imaging stack
channelIndxStart = strfind(experimentStructure.filenamesFrame{1}, '_Ch');
for i =1:length(experimentStructure.filenamesFrame)
    channelIdentity{i} = experimentStructure.filenamesFrame{i}(channelIndxStart:channelIndxStart+3);
end
channelNo = unique(channelIdentity);

% splits stack into two channels
if length(channelNo)>1
    volSplit =  reshape(vol,size(vol,1),size(vol,2),[], length(channelNo));
end


if isfield( experimentStructure, 'micronsPerPixel')
    micronsPerPix = experimentStructure.micronsPerPixel(1,1);
else
    micronsPerPix =[];
end

if ~isempty(experimentType)
    experimentStructure = prepTrialDataV2(experimentStructure, experimentStructure.prairiePathVoltage, experimentType);
end

%% If two channel stack
if length(channelNo)> 1 % choose one channel to register if multiple exist
    
    % Register imaging data and save registered image stack
    if regOrNot ==1
        if isempty(channel2register)
            channel2register = defaultRegChannel;
        end
        
        % if we want to use the brightness average
        if useBrightestFrameAlignment
            % no of images to use for average
            noOfImages = 100;
            
            % get image brightness in stack
            imageBrightness = zeros(size(volSplit, 3), 1);
            for i =1:size(volSplit, 3)
                imageBrightness(i) = mean2(volSplit(:,:,i,channel2register));
            end
            
            % sort image brightness
            [imageBrightnessVal, imageBrightnessIndx] = sort(imageBrightness);
            % make average image based on noOfImages brightest images
            templateImageForReg = uint16(mean(volSplit(:,:,imageBrightnessIndx(1:noOfImages-1),channel2register),3));
            
        end
        
        disp(['Starting image registration on Channel ' num2str(channel2register)]);
        [vol,xyShifts] = imageRegistration(volSplit(:,:,:,channel2register), [], micronsPerPix, [], templateImageForReg);
        experimentStructure.xyShifts = xyShifts;
    end
    % deal with first channel
    experimentStructure = prepDataSubFunction(vol, experimentStructure, saveRegMovie, channelNo{channel2register});
    
    
    % deal with second channel
    indForOtherChannel = find(~strcmp(channelNo, channelNo{channel2register}));
    vol = shiftImageStack(volSplit(:,:,:,indForOtherChannel),xyShifts([2 1],:)'); % Apply actual shifts to tif stack
    experimentStructure =  prepDataSubFunction(vol, experimentStructure, saveRegMovie, channelNo{indForOtherChannel});
    
    
else
    %% If single channel stack
    
    if regOrNot ==1
        
        % if we want to use the brightness average
        if useBrightestFrameAlignment
            % no of images to use for average
            noOfImages = 100;
            
            % get image brightness in stack
            imageBrightness = zeros(size(vol, 3), 1);
            for i =1:size(vol, 3)
                imageBrightness(i) = mean2(vol(:,:,i));
            end
            
            % sort image brightness
            [imageBrightnessVal, imageBrightnessIndx] = sort(imageBrightness);
            % make average image based on noOfImages brightest images
            templateImageForReg = uint16(mean(vol(:,:,imageBrightnessIndx(1:noOfImages-1)),3));
        end
        
        
        disp(['Starting image registration on Channel ' num2str(channel2register)]);
        [vol,xyShifts] = imageRegistration(vol, [], micronsPerPix, [], templateImageForReg);
        experimentStructure.xyShifts = xyShifts;
    end
    
    experimentStructure =  prepDataSubFunction(vol, experimentStructure, saveRegMovie);
    
end

% % save experimentStructure
% save([savePath 'experimentStructure.mat'], 'experimentStructure');

% save experimentStructure
save([savePath 'experimentStructure.mat'], 'experimentStructure');


end