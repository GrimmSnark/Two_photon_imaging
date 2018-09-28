folder = 'D:\Data\2P_Data\Processed\Mouse\gCamp6s\M1\5on_5off_4\TSeries-09042018-0830-011\20180905112245\';

load([folder 'experimentStructure.mat']);

vol = read_Tiffs(experimentStructure.fullfile,1);
if ndims(vol) ~=3
    vol = readMultipageTifFiles(experimentStructure.prairiePath);
end

profile on
% apply imageregistration shifts
registeredVol = shiftImageStack(vol,experimentStructure.xyShifts([2 1],:)'); % Apply actual shifts to tif stack


registeredVolGPU = gpuArray(registeredVol);


for  cnd =1 % for each condition
%     parfor_progress(length(experimentStructure.cndTrials{cnd}));
    for iter =1%: 4 %length(experimentStructure.cndTrials{cnd}) % for each trial of that type
        
        currentTrial = experimentStructure.cndTrials{cnd}(iter); % gets current trial number for that cnd
        currentStimChunk = experimentStructure.EventFrameIndx.STIM_ON(currentTrial):experimentStructure.EventFrameIndx.STIM_OFF(currentTrial);
        currentPreStimChunk = experimentStructure.EventFrameIndx.PRESTIM_ON(currentTrial):experimentStructure.EventFrameIndx.PRESTIM_OFF(currentTrial);
        
        %gpu
        reshapedVolGPU = reshape(registeredVolGPU(:,:,currentStimChunk), [], length(currentStimChunk));
        stdArrayGPU = arrayfun(@(I) std2(reshapedVolGPU(I,:)), [ 1, 1:size(reshapedVolGPU, 1)]);
        stdArrayGPU = reshape(stdArrayGPU(1:end-1), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine);
        stimSTDImageCNDGPU(:,:, cnd, iter) = stdArrayGPU;
        
        %cpu
        reshapedVol = reshape(registeredVol(:,:,currentStimChunk), [], length(currentStimChunk));
        stdArray = arrayfun(@(I) std2(reshapedVol(I,:)), [ 1, 1:size(reshapedVol, 1)]);
        stdArray = reshape(stdArray(1:end-1), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine);
        stimSTDImageCND(:,:, cnd, iter) = uint16(stdArray);
        
        %cpu 2
        stdArray = arrayfun(@(I) std3(reshapedVol(I,:)), [ 1, 1:size(reshapedVol, 1)]);
        stdArray = reshape(stdArray(1:end-1), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine);
        stimSTDImageCND2(:,:, cnd, iter) = uint16(stdArray);
        
%           parfor_progress; % get progress in parfor loop
        
    end
%     parfor_progress(0);
end

stimSTDImageCNDGPU = gather(stimSTDImageCNDGPU);

profile off

profsave(profile('info'),'myprofile_results');
