function testGPUv2(folder)

% folder = 'D:\Data\2P_Data\Processed\Mouse\gCamp6s\M1\5on_5off_4\TSeries-09042018-0830-011\20180905112245\';

experimentStructure = load([folder '\experimentStructure.mat']);
experimentStructure = experimentStructure.experimentStructure; % fix loading in weirdness

registeredVol = load([folder '\registeredVol.mat']);
registeredVol = registeredVol.registeredVol;  % fix loading in weirdness

profile on

% transfer iamging array to gpu
registeredVolGPU = gpuArray(registeredVol);

% create standard deviation sum array over the stimulus on period
for  cnd =1: length(experimentStructure.cndTrials) % for each condition
%     parfor_progress(length(experimentStructure.cndTrials{cnd}));
    parfor iter =1:length(experimentStructure.cndTrials{cnd}) % for each trial of that type
        
        currentTrial = experimentStructure.cndTrials{cnd}(iter); % gets current trial number for that cnd
        currentStimChunk = experimentStructure.EventFrameIndx.STIM_ON(currentTrial):experimentStructure.EventFrameIndx.STIM_OFF(currentTrial); % gets the frame indexes for stimulus ON and OFF
        
        %gpu calculation
        reshapedVolGPU = reshape(registeredVolGPU(:,:,currentStimChunk), [], length(currentStimChunk)); % reshapes array into pixel by frame array
        stdArrayGPU = arrayfun(@(I) std2(reshapedVolGPU(I,:)), [ 1, 1:size(reshapedVolGPU, 1)]); % gets the std per pixel
        stdArrayGPU = reshape(stdArrayGPU(1:end-1), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine); % reshapes into std image 512 x 512
        stimSTDImageCNDGPU(:,:, cnd, iter) = stdArrayGPU; % adds the image to the grand array
        
        %cpu calculation
        reshapedVol = reshape(registeredVol(:,:,currentStimChunk), [], length(currentStimChunk)); % reshapes array into pixel by frame array
        stdArray = arrayfun(@(I) std2(reshapedVol(I,:)), [ 1, 1:size(reshapedVol, 1)]); % gets the std per pixel
        stdArray = reshape(stdArray(1:end-1), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine); % reshapes into std image 512 x 512
        stimSTDImageCND(:,:, cnd, iter) = stdArray; % adds the image to the grand array
                
%           parfor_progress; % get progress in parfor loop
        
    end
%     parfor_progress(0);
end

stimSTDImageCNDGPU = gather(stimSTDImageCNDGPU);

profile off

profsave(profile('info'),'myprofile_results');

end
