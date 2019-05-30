function [stimSTDSum, preStimSTDSum,experimentStructure] = createStimSTDAverage(vol, experimentStructure,channelIdentifier)
% Function to create STD sum images for prestim and stim times
% Input: vol- registered 3D image stack
%        experimentStructure- structure for this experiement
%        channelIdentifier- OPTIONAL, string for identifying channel if
%        multiple exist
%        
% Output: stimSTDSum- 2D image of summed STDs for stim trial window period 
%         preStimSTDSum- 2D image of summed STDs for prestim trial window period 
%         experimentStructure - modified experimentStructure

if nargin<3
    channelIdentifier =[];
end

disp('Starting stim STD image calculation');
cndLength = length(experimentStructure.cndTrials);
for  cnd =1:cndLength % for each condition
    
     disp(['On Condition ' num2str(cnd) ' of ' num2str(length(experimentStructure.cndTrials))]);
    trialNo = length(experimentStructure.cndTrials{cnd}); % for each trial of that type
    parfor iter =1:trialNo
        
        currentTrial = experimentStructure.cndTrials{cnd}(iter); % gets current trial number for that cnd
        currentStimChunk = experimentStructure.EventFrameIndx.STIM_ON(currentTrial):experimentStructure.EventFrameIndx.STIM_OFF(currentTrial);
        stimChunkLength = length(currentStimChunk);
        currentPreStimChunk = experimentStructure.EventFrameIndx.PRESTIM_ON(currentTrial):experimentStructure.EventFrameIndx.PRESTIM_OFF(currentTrial);
        
        %cpu
        reshapedVol = reshape(vol(:,:,currentStimChunk), [], stimChunkLength);
        sizeReshapedVol = size(reshapedVol, 1);
        stdArray = arrayfun(@(I) std2(reshapedVol(I,:)), [ 1, 1:sizeReshapedVol]);
        stdArray = stdArray(1:end-1);
        stdArray = reshape(stdArray, experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine);
        stimSTDImageCND(:,:, cnd, iter) = stdArray;
        
        
        reshapedVol = reshape(vol(:,:,currentPreStimChunk), [], length(currentPreStimChunk));
        stdArray = arrayfun(@(I) std2(reshapedVol(I,:)), [ 1, 1:size(reshapedVol, 1)]);
        stdArray = reshape(stdArray(1:end-1), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine);
        preStimSTDImageCND(:,:, cnd, iter) = stdArray;
    end
    
end

% reshape arrays to 2D images

stimSTDImage = reshape(stimSTDImageCND,  experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine,[]);
stimSTDSum = rescale(sum(stimSTDImage, 3))*65535; % rescales to 16 bit image without clipping or loss...
stimSTDSum = uint16(stimSTDSum);

preStimSTDImage = reshape(preStimSTDImageCND,  experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine,[]);
preStimSTDSum = rescale(sum(preStimSTDImage, 3))*65535;
preStimSTDSum = uint16(preStimSTDSum);

% add to experimentStructure

if ~isempty(channelIdentifier) % if multiple channels in recording
  eval(['experimentStructure.stimSTDImageCND' channelIdentifier ' = uint16(gather(stimSTDImageCND));'])
   eval(['experimentStructure.preStimSTDImageCND' channelIdentifier ' = uint16(gather(preStimSTDImageCND));' ])
else
  experimentStructure.stimSTDImageCND = stimSTDImageCND;
experimentStructure.preStimSTDImageCND = preStimSTDImageCND;
end


end