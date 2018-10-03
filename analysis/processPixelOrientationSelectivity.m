function processPixelOrientationSelectivity(recordingDir)
% Function which plots orientation selectivty maps from STD stim images

recordingDir = 'D:\Data\2P_Data\Processed\Mouse\gCamp6s\M3\5on_5off_8\TSeries-09242018-1042-010\20180927124421\';
angles = (0:45:315)*2;
angles_rad = circ_ang2rad(angles);

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

% load experimentStructure
load([recordingDirProcessed 'experimentStructure.mat']);


% get means per cnd
for cnd = 1:length(experimentStructure.cndTotal)
    stimSTDImagesMean(:,:,cnd) = mean(experimentStructure.stimSTDImageCND(:,:,cnd,:), 4);
end

% normalise to max pixel val

stimSTDImagesMeanNorm = (stimSTDImagesMean / max(stimSTDImagesMean(:)));

% for each pixel arrange array
% counter = 1;
% for h = 1:size(stimSTDImagesMeanNorm,1)
%     for w = 1:size(stimSTDImagesMeanNorm,2)
%          pixelVectorAngles(counter,:, :) = [angles_rad' squeeze(stimSTDImagesMeanNorm(h,w,:))  squeeze(stimSTDImagesMean(h,w,:))];
%         
%     end 
% end
%         

% reshape array to pixel x rad angle x pixel weight x raw intensity
reshapedImageNorm = reshape(stimSTDImagesMeanNorm, [],length(experimentStructure.cndTotal));
reshapedImage = reshape(stimSTDImagesMean, [], length(experimentStructure.cndTotal));
pixelVectorAngles = zeros(length(reshapedImageNorm), length(experimentStructure.cndTotal), 3);

for pixelNo = 1:length(reshapedImageNorm)
    pixelVectorAngles(pixelNo,:,:) = [angles_rad ;reshapedImageNorm(pixelNo,:) ;reshapedImage(pixelNo,:)]';
end

% calculate vector mean per pixel per cnd
for pixelNo = 1:length(pixelVectorAngles)
   pixelWeightedMeanVector(pixelNo,:) = [circ_mean(pixelVectorAngles(pixelNo,:,1)', pixelVectorAngles(pixelNo,:,2)') mean(pixelVectorAngles(pixelNo,:,2)) mean(pixelVectorAngles(pixelNo,:,3))];
end

pixelWeightedMeanVector = [circ_rad2ang(pixelWeightedMeanVector(:,1)) pixelWeightedMeanVector(:,2) pixelWeightedMeanVector(:,3)];

% deal with negative average angles
for pixelNo = 1:length(pixelWeightedMeanVector)
    
    if pixelWeightedMeanVector(pixelNo,1) <0
        pixelWeightedMeanVectorCorrected(pixelNo) = ( pixelWeightedMeanVector(pixelNo,1) + 360)/2;
    else
        pixelWeightedMeanVectorCorrected(pixelNo) =  pixelWeightedMeanVector(pixelNo,1);
    end
end

% reconstruct array
 pixelWeightedMeanVectorCorrected =  [ pixelWeightedMeanVectorCorrected' pixelWeightedMeanVector(:,2) pixelWeightedMeanVector(:,2)];

% reshape into orientation image 
 orientationSelectivityImage = reshape(pixelWeightedMeanVectorCorrected(:,1), 512, 512);
 orientationAmplitudeImage = reshape(pixelWeightedMeanVectorCorrected(:,2), 512, 512);
 
 % rescale into colormap
 orientationSelectivityImageConverted = orientationSelectivityImage *(256/180);
 
 % plot color image
 
 imHandle = imagesc(orientationSelectivityImageConverted);
 figHandle = imgcf;
 colormap(ggb1)
 clbar = colorbar;
 clbar.Ticks = linspace(0,255, 5)
 clbar.TickLabels = 0:45:180;
 set(figHandle, 'Position' ,[3841,417,1280,951.333333333333]);
 axis square
 saveas(figHandle, [experimentStructure.savePath 'Pixel Orientation Pref.tif']);
 
 
%  figure
%  imagesc(orientationAmplitudeImage)
 

end