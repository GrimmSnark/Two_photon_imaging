function [stimSTDSum, preStimSTDSum,experimentStructure] = createStimSTDAverage(vol, experimentStructure)
% Function to create STD sum images for prestim and stim times
% Input: vol- registered 3D image stack
%        experimentStructure- structure for this experiement
%        
% Output: stimSTDSum- 2D image of summed STDs for stim trial window period 
%         preStimSTDSum- 2D image of summed STDs for prestim trial window period 
%         experimentStructure - modified experimentStructure


disp('Starting stim STD image calculation');
for  cnd =1:length(experimentStructure.cndTrials) % for each condition
    
    disp(['On Condition ' num2str(cnd) ' of ' num2str(length(experimentStructure.cndTrials))]);
    
    parfor iter =1:length(experimentStructure.cndTrials{cnd}) % for each trial of that type
        
        currentTrial = experimentStructure.cndTrials{cnd}(iter); % gets current trial number for that cnd
        currentStimChunk = experimentStructure.EventFrameIndx.STIM_ON(currentTrial):experimentStructure.EventFrameIndx.STIM_OFF(currentTrial);
        currentPreStimChunk = experimentStructure.EventFrameIndx.PRESTIM_ON(currentTrial):experimentStructure.EventFrameIndx.PRESTIM_OFF(currentTrial);
        
        %cpu
        reshapedVol = reshape(vol(:,:,currentStimChunk), [], length(currentStimChunk));
        stdArray = arrayfun(@(I) std2(reshapedVol(I,:)), [ 1, 1:size(reshapedVol, 1)]);
        stdArray = reshape(stdArray(1:end-1), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine);
        stimSTDImageCND(:,:, cnd, iter) = uint16(stdArray);
        
        
        reshapedVol = reshape(vol(:,:,currentPreStimChunk), [], length(currentPreStimChunk));
        stdArray = arrayfun(@(I) std2(reshapedVol(I,:)), [ 1, 1:size(reshapedVol, 1)]);
        stdArray = reshape(stdArray(1:end-1), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine);
        preStimSTDImageCND(:,:, cnd, iter) = uint16(stdArray);
    end
    
end

% reshape arrays to 2D images

stimSTDImage = reshape(stimSTDImageCND,  experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine,[]);
stimSTDSum = uint16(sum(stimSTDImage, 3));

preStimSTDImage = reshape(preStimSTDImageCND,  experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine,[]);
preStimSTDSum = uint16(sum(preStimSTDImage, 3));

% add to experimentStructure
experimentStructure.stimSTDImageCND = stimSTDImageCND;
experimentStructure.preStimSTDImageCND = preStimSTDImageCND;


end