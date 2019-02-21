folder = 'D:\Data\2P_Data\Processed\Mouse\gCamp6s\M4\5on_5off_4\TSeries-10102018-1051-002\20181011141729\';

load([folder 'experimentStructure.mat']);

vol = read_Tiffs(experimentStructure.fullfile,1);
if ndims(vol) ~=3
    vol = readMultipageTifFiles(experimentStructure.prairiePath);
end

% apply imageregistration shifts
registeredVol = shiftImageStack(vol,experimentStructure.xyShifts([2 1],:)'); % Apply actual shifts to tif stack

% transfer iamging array to gpu
registeredVolGPU = gpuArray(registeredVol);
tic
% create standard deviation sum array over the stimulus on period
for  cnd =1:3 % length(experimentStructure.cndTrials) % for each condition
    %     parfor_progress(length(experimentStructure.cndTrials{cnd}));
    for iter =1:length(experimentStructure.cndTrials{cnd}) % for each trial of that type
        
        currentTrial = experimentStructure.cndTrials{cnd}(iter); % gets current trial number for that cnd
        currentStimChunk = experimentStructure.EventFrameIndx.STIM_ON(currentTrial):experimentStructure.EventFrameIndx.STIM_OFF(currentTrial); % gets the frame indexes for stimulus ON and OFF
        %gpu calculation
        reshapedVolGPU = double(reshape(registeredVolGPU(:,:,currentStimChunk), [], length(currentStimChunk))); % reshapes array into pixel by frame array
        
        l = length(reshapedVolGPU(1,:));
        mean_x = sum(reshapedVolGPU,2)/l;
        xc = reshapedVolGPU - mean_x;
        stdArrayGPU  = sqrt(sum(xc .* xc, 2)) / sqrt(l - 1);
        
        stdArrayGPU = reshape(stdArrayGPU(1:end), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine); % reshapes into std image 512 x 512
        stimSTDImageCNDGPU(:,:, cnd, iter) = stdArrayGPU; % adds the image to the grand array
       
        
        
        %         stdArrayGPU = arrayfun(@(I) std2(reshapedVolGPU(I,:)), [ 1, 1:size(reshapedVolGPU, 1)]); % gets the std per pixel
        %         stdArrayGPU = reshape(stdArrayGPU(1:end-1), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine); % reshapes into std image 512 x 512
        %         stimSTDImageCNDGPU(:,:, cnd, iter) = stdArrayGPU; % adds the image to the grand array
        
%         tic
%         %cpu calculation
        reshapedVol = reshape(registeredVol(:,:,currentStimChunk), [], length(currentStimChunk)); % reshapes array into pixel by frame array
        stdArray = arrayfun(@(I) std2(reshapedVol(I,:)), [1:size(reshapedVol, 1)]); % gets the std per pixel
        stdArray = reshape(stdArray(1:end), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine); % reshapes into std image 512 x 512
        stimSTDImageCND(:,:, cnd, iter) = stdArray; % adds the image to the grand array
        disp('CPU time')
%         toc;
        
        %           parfor_progress; % get progress in parfor loop
        
    end
    %     parfor_progress(0);
end

stimSTDImageCNDGPU = gather(stimSTDImageCNDGPU);
stimSTDImageCNDGPU = uint16(stimSTDImageCNDGPU);
toc

