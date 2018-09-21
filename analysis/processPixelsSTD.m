function processPixelsSTD(MIJImageROI, registeredVolMIJI, registeredVol, experimentStructure, analysisFrames)

% run through each pixel MATLAB...
% pixelNum = size(registeredVol,1);
%
% stimSTDImageCND = zeros(pixelNum,pixelNum,length(experimentStructure.cndTotal), length(experimentStructure.cndTrials{1}));
% preStimSTDImageCND = zeros(pixelNum,pixelNum,length(experimentStructure.cndTotal), length(experimentStructure.cndTrials{1}));
%
% t0=tic;
% for h = 1:pixelNum
%     for w = 1:pixelNum
%         for  cnd =1:length(experimentStructure.cndTotal) % for each condition
%             if any(experimentStructure.cndTotal(cnd)) % checks if there are any trials of that type
%                 for iter =1:length(experimentStructure.cndTrials{cnd}) % for each trial of that type
%
%                     disp(['Working on pixel (' num2str(w) ',' num2str(h) ')']);
%                     currentTrial = experimentStructure.cndTrials{cnd}(iter); % gets current trial number for that cnd
%
%                     stimSTDImageCND(h,w, cnd, iter) = std2(registeredVol(h,w,experimentStructure.EventFrameIndx.STIM_ON(currentTrial):experimentStructure.EventFrameIndx.STIM_OFF(currentTrial)));
%                     preStimSTDImageCND(h,w, cnd, iter) = std2(registeredVol(h,w,experimentStructure.EventFrameIndx.PRESTIM_ON(currentTrial):experimentStructure.EventFrameIndx.PRESTIM_OFF(currentTrial)));
%
%                 end
%             end
%         end
%     end
% end
%
% stimSTDImageCND = uint16(stimSTDImageCND);
% preStimSTDImageCND = uint16(preStimSTDImageCND);
%
% timeElapsed = toc(t0);
% fprintf('Finished matlab pixel STD - Time elapsed is %4.2f seconds',timeElapsed);


% MATLAB using arrayfun GPU

% t0 = tic;
%
% registeredVolGPU = gpuArray(registeredVol);
%
% for  cnd =1:length(experimentStructure.cndTotal) % for each condition
%     if any(experimentStructure.cndTotal(cnd)) % checks if there are any trials of that type
%         for iter =1:length(experimentStructure.cndTrials{cnd}) % for each trial of that type
%
%             currentTrial = experimentStructure.cndTrials{cnd}(iter); % gets current trial number for that cnd
%             currentStimChunk = experimentStructure.EventFrameIndx.STIM_ON(currentTrial):experimentStructure.EventFrameIndx.STIM_OFF(currentTrial);
%             currentPreStimChunk = experimentStructure.EventFrameIndx.PRESTIM_ON(currentTrial):experimentStructure.EventFrameIndx.PRESTIM_OFF(currentTrial);
%
%             reshapedVolGPU = reshape(registeredVolGPU(:,:,currentStimChunk), [], length(currentStimChunk));
%             stdArrayGPU = arrayfun(@(I) std2(reshapedVolGPU(I,:)), [ 1, 1:size(reshapedVolGPU, 1)]);
%             stdArrayGPU = reshape(stdArrayGPU(1:end-1), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine);
%             stimSTDImageCNDGPU(:,:, cnd, iter) = stdArrayGPU;
%
%               reshapedVolGPU = reshape(registeredVolGPU(:,:,currentPreStimChunk), [], length(currentPreStimChunk));
%             stdArrayGPU = arrayfun(@(I) std2(reshapedVolGPU(I,:)), [ 1, 1:size(reshapedVolGPU, 1)]);
%             stdArrayGPU = reshape(stdArrayGPU(1:end-1), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine);
%             preStimSTDImageCNDGPU(:,:, cnd, iter) = stdArrayGPU;
%
%
%         end
%     end
% end
%
% stimSTDImageCNDGPU = uint16(gather(stimSTDImageCNDGPU));
% preStimSTDImageCNDGPU = uint16(gather(preStimSTDImageCNDGPU));
%
%
% timeElapsed = toc(t0);
% fprintf('Finished cpu pixel STD - Time elapsed is %4.2f seconds \n',timeElapsed);




% MATLAB using arrayfun CPU

t0 = tic;
stimSTDImageCND = zeros( experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine, length(experimentStructure.cndTrials), experimentStructure.cndTotal(1));
preStimSTDImageCND = zeros( experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine, length(experimentStructure.cndTrials), experimentStructure.cndTotal(1));

cndTotals = experimentStructure.cndTotal;
for  cnd =1:length(experimentStructure.cndTotal) % for each condition
    parfor iter = 1:cndTotals(cnd)% for each trial of that type
        
        currentTrial = experimentStructure.cndTrials{cnd}(iter); % gets current trial number for that cnd
        
        if isempty(analysisFrames)
        currentStimChunk = experimentStructure.EventFrameIndx.STIM_ON(currentTrial):experimentStructure.EventFrameIndx.STIM_OFF(currentTrial);
        currentPreStimChunk = experimentStructure.EventFrameIndx.PRESTIM_ON(currentTrial):experimentStructure.EventFrameIndx.PRESTIM_OFF(currentTrial);
        else
            if analysisFrames==0
                currentStimChunk = experimentStructure.EventFrameIndx.STIM_ON(currentTrial):experimentStructure.EventFrameIndx.STIM_OFF(currentTrial);
                currentPreStimChunk = (experimentStructure.EventFrameIndx.STIM_ON(currentTrial)-1) - (length(currentStimChunk)-1):experimentStructure.EventFrameIndx.STIM_ON(currentTrial)-1;
            else
                currentStimChunk = experimentStructure.EventFrameIndx.STIM_ON(currentTrial):experimentStructure.EventFrameIndx.STIM_ON(currentTrial)+ analysisFrames;
                currentPreStimChunk = (experimentStructure.EventFrameIndx.STIM_ON(currentTrial)-1) - length(currentStimChunk):experimentStructure.EventFrameIndx.STIM_ON(currentTrial)-1;  
            end
        end
            
        
        reshapedVol = reshape(registeredVol(:,:,currentStimChunk), [], length(currentStimChunk));
        stdArray = arrayfun(@(I) std2(reshapedVol(I,:)), [ 1, 1:size(reshapedVol, 1)]);
        stdArray = reshape(stdArray(1:end-1), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine);
        stimSTDImageCND(:,:, cnd, iter) = uint16(stdArray);
        
        reshapedVol = reshape(registeredVol(:,:,currentPreStimChunk), [], length(currentPreStimChunk));
        stdArray = arrayfun(@(I) std2(reshapedVol(I,:)), [ 1, 1:size(reshapedVol, 1)]);
        stdArray = reshape(stdArray(1:end-1), experimentStructure.pixelsPerLine, experimentStructure.pixelsPerLine);
        preStimSTDImageCND(:,:, cnd, iter) = uint16(stdArray);
        
        
    end
end

timeElapsed = toc(t0);
fprintf('Finished cpu pixel STD - Time elapsed is %4.2f seconds \n',timeElapsed);

%%
% t0 = tic;
% for  cnd =1:length(experimentStructure.cndTotal) % for each condition
%     if any(experimentStructure.cndTotal(cnd)) % checks if there are any trials of that type
%         for iter =1:length(experimentStructure.cndTrials{cnd}) % for each trial of that type
%
%             currentTrial = experimentStructure.cndTrials{cnd}(iter); % gets current trial number for that cnd
%
%             stdMIJI = ij.plugin.ZProjector.run(registeredVolMIJI, 'sd', experimentStructure.EventFrameIndx.STIM_ON(currentTrial), experimentStructure.EventFrameIndx.STIM_OFF(currentTrial));
%
%             convertImp = ij.process.ImageConverter(stdMIJI);
%             convertImp.convertToGray16;
%             processerM = stdMIJI.getProcessor();
%             stimSTDImageCNDMIJI(:,:,cnd,iter) = processerM.getIntArray;
%
%         end
%     end
% end
%
% stimSTDImageCNDMIJI16 = typecastArray(stimSTDImageCNDMIJI, 'uint16');
%
% stimSTDImageCNDMIJI16 = arrayfun(@(stimSTDImageCNDMIJI) typecast(stimSTDImageCNDMIJI, 'uint16'), stimSTDImageCNDMIJI, 'UniformOutput',false);
%
% for  cnd =1:length(experimentStructure.cndTotal) % for each condition
%     if any(experimentStructure.cndTotal(cnd)) % checks if there are any trials of that type
%         for iter =1:length(experimentStructure.cndTrials{cnd}) % for each trial of that type
%
%             currentTrial = experimentStructure.cndTrials{cnd}(iter); % gets current trial number for that cnd
%
%             stdMIJI = ij.plugin.ZProjector.run(registeredVolMIJI, 'sd', experimentStructure.EventFrameIndx.PRESTIM_ON(currentTrial), experimentStructure.EventFrameIndx.PRESTIM_OFF(currentTrial));
%
%             convertImp = ij.process.ImageConverter(stdMIJI);
%             convertImp.convertToGray16;
%             processerM = stdMIJI.getProcessor();
%             preStimSTDImageCNDMIJI(:,:,cnd,iter) = processerM.getIntArray();
%
%         end
%     end
% end
%
% % preStimSTDImageCNDMIJI16 = typecastArray(preStimSTDImageCNDMIJI, 'uint16');
%
% timeElapsed = toc(t0);
% fprintf('Finished MIJI pixel STD - Time elapsed is %4.2f seconds',timeElapsed);
%%


% reshape for summing
stimSTDImage = reshape(stimSTDImageCND, size(stimSTDImageCND,1), size(stimSTDImageCND,2), []);
preStimSTDImage = reshape(preStimSTDImageCND, size(preStimSTDImageCND,1), size(preStimSTDImageCND,2), []);

stimSTDImageSum = uint16(sum(stimSTDImage,3));
preStimSTDImageSum = uint16(sum(preStimSTDImage,3));


% stimSTDImageGPU = reshape(stimSTDImageCNDGPU, size(stimSTDImageCNDGPU,1), size(stimSTDImageCNDGPU,2), []);
% preStimSTDImageGPU = reshape(preStimSTDImageCNDGPU, size(preStimSTDImageCNDGPU,1), size(preStimSTDImageCNDGPU,2), []);
%
% stimSTDImageSumGPU = uint16(sum(stimSTDImageGPU,3));
% preStimSTDImageSumGPU = uint16(sum(preStimSTDImageGPU,3));
%
%
% stimSTDImageMIJI = reshape(stimSTDImageCNDMIJI16, size(stimSTDImageCNDMIJI16,1), size(stimSTDImageCNDMIJI16,2), []);
% preStimSTDImageMIJI = reshape(preStimSTDImageCNDMIJI16, size(preStimSTDImageCNDMIJI16,1), size(preStimSTDImageCNDMIJI16,2), []);
%
% stimSTDImageMIJISum = uint16(sum(stimSTDImageMIJI,3));
% preStimSTDImageMIJISum = uint16(sum(preStimSTDImageMIJI,3));
%
%




% transfers to FIJI
% stimSTDImageHandle = MIJ.createImage( 'Stim STD Average CPU', stimSTDImageSum,true);
% preStimSTDImageHandle = MIJ.createImage( 'Prestim STD Average CPU', preStimSTDImageSum,true);
% stimSTDImageMIJIHandle = MIJ.createImage( 'Stim STD Average MIJI', stimSTDImageMIJISum,true);
% preStimSTDImageMIJIHandle = MIJ.createImage( 'Prestim STD Average MIJI', preStimSTDImageMIJISum,true);

% stimSTDImageGPUHandle = MIJ.createImage( 'Stim STD Average GPU', stimSTDImageSumGPU,true);
% preStimSTDImageGPUHandle = MIJ.createImage( 'Prestim STD Average GPU', preStimSTDImageSumGPU,true);
%


experimentStructure.stimSTDImageCND = stimSTDImageCND;
experimentStructure.preStimSTDImageCND = preStimSTDImageCND;

% save experimentStructure
save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure');

% save images
options.overwrite =true;
saveastiff(stimSTDImageSum, [experimentStructure.savePath 'Stim STD Sum.tif'],options);
saveastiff(preStimSTDImageSum, [experimentStructure.savePath 'PreStim STD Sum.tif'], options);


for i = 1:size(stimSTDImageCND,3)
    
    stimSTDImageCNDSum(:,:,i) = sum(stimSTDImageCND(:,:,i,:), 4);
    
    
end

stimSTDImageCNDSum = uint16(stimSTDImageCNDSum);


for x = 1: size(stimSTDImageCNDSum,3)
    saveastiff(stimSTDImageCNDSum(:,:,x), [experimentStructure.savePath 'Stim STD Sum Cnd ' num2str(x)  '.tif'], options);
    
end

for i = 1:size(preStimSTDImageCND,3)
    
    preStimSTDImageCNDSum(:,:,i) = sum(preStimSTDImageCND(:,:,i,:), 4);
    
    
end

preStimSTDImageCNDSum = uint16(preStimSTDImageCNDSum);


for x = 1: size(preStimSTDImageCNDSum,3)
    saveastiff(preStimSTDImageCNDSum(:,:,x), [experimentStructure.savePath 'Prestim STD Sum Cnd ' num2str(x)  '.tif'], options);
    
end

end