function processPixelOrientationSelectivity(recordingDir, isColorOrientation)
% Function which plots orientation selectivty maps from STD stim images

% recordingDir = 'D:\Data\2P_Data\Processed\Mouse\gCamp6s\M3\5on_5off_8\TSeries-09242018-1042-010\20180927124421\';

if isColorOrientation ==1
    angles = (0:45:315)*2;
    angles = [angles angles];
else
    angles = (0:45:315)*2;
end
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
disp('Loaded in experimentStructure');

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

parfor pixelNo = 1:length(reshapedImageNorm)
    pixelVectorAngles(pixelNo,:,:) = [angles_rad ;reshapedImageNorm(pixelNo,:) ;reshapedImage(pixelNo,:)]';
end

% calculate vector mean per pixel per cnd
if isColorOrientation ==1
    parfor pixelNo = 1:length(pixelVectorAngles)
        pixelWeightedMeanVectorG(pixelNo,:) = [circ_mean(pixelVectorAngles(pixelNo,1:8,1)', pixelVectorAngles(pixelNo,1:8,2)') mean(pixelVectorAngles(pixelNo,1:8,2)) mean(pixelVectorAngles(pixelNo,1:8,3))];
        
        pixelWeightedMeanVectorB(pixelNo,:) = [circ_mean(pixelVectorAngles(pixelNo,9:16,1)', pixelVectorAngles(pixelNo,9:16,2)') mean(pixelVectorAngles(pixelNo,9:16,2)) mean(pixelVectorAngles(pixelNo,9:16,3))];
        
        angleStructG = mean_vector_direction_magnitude([circ_rad2ang(pixelVectorAngles(pixelNo,1:8,1))' pixelVectorAngles(pixelNo,1:8,2)']) ;
        pixelWeightedMeanVectorV2G(pixelNo,:) = [angleStructG.mean_angle_degrees angleStructG.mean_magnitude mean(pixelVectorAngles(pixelNo,:,3))];
        
        angleStructB = mean_vector_direction_magnitude([circ_rad2ang(pixelVectorAngles(pixelNo,9:16,1))' pixelVectorAngles(pixelNo,9:16,2)']) ;
        pixelWeightedMeanVectorV2B(pixelNo,:) = [angleStructB.mean_angle_degrees angleStructB.mean_magnitude mean(pixelVectorAngles(pixelNo,:,3))];
    end
    
    pixelWeightedMeanVectorG = [circ_rad2ang(pixelWeightedMeanVectorG(:,1)) pixelWeightedMeanVectorG(:,2) pixelWeightedMeanVectorG(:,3)];
    pixelWeightedMeanVectorB = [circ_rad2ang(pixelWeightedMeanVectorB(:,1)) pixelWeightedMeanVectorB(:,2) pixelWeightedMeanVectorB(:,3)];
    
% deal with negative average angles
parfor pixelNo = 1:length(pixelWeightedMeanVectorG)
    
    if pixelWeightedMeanVectorG(pixelNo,1) <0
        pixelWeightedMeanVectorCorrectedG(pixelNo) = ( pixelWeightedMeanVectorG(pixelNo,1) + 360)/2;
    else
        pixelWeightedMeanVectorCorrectedG(pixelNo) =  pixelWeightedMeanVectorG(pixelNo,1);
    end
    
    if pixelWeightedMeanVectorB(pixelNo,1) <0
        pixelWeightedMeanVectorCorrectedB(pixelNo) = ( pixelWeightedMeanVectorB(pixelNo,1) + 360)/2;
    else
        pixelWeightedMeanVectorCorrectedB(pixelNo) =  pixelWeightedMeanVectorB(pixelNo,1);
    end
end

% reconstruct array
 pixelWeightedMeanVectorCorrectedG =  [ pixelWeightedMeanVectorCorrectedG' pixelWeightedMeanVectorG(:,2) pixelWeightedMeanVectorG(:,3)];
 pixelWeightedMeanVectorCorrectedB =  [ pixelWeightedMeanVectorCorrectedB' pixelWeightedMeanVectorB(:,2) pixelWeightedMeanVectorB(:,3)];
 
 
 % reshape into orientation image 
 orientationSelectivityImageG = reshape(pixelWeightedMeanVectorCorrectedG(:,1), 512, 512);
  orientationSelectivityImageB = reshape(pixelWeightedMeanVectorCorrectedB(:,1), 512, 512);
 
 orientationSelectivityImage2G = reshape(pixelWeightedMeanVectorV2G(:,1), 512, 512);
  orientationSelectivityImage2B = reshape(pixelWeightedMeanVectorV2B(:,1), 512, 512);
 
 
 orientationAmplitudeImageG = reshape(pixelWeightedMeanVectorCorrectedG(:,2), 512, 512);
  orientationAmplitudeImageB = reshape(pixelWeightedMeanVectorCorrectedB(:,2), 512, 512);

 % rescale into colormap
 orientationSelectivityImageConvertedG = orientationSelectivityImageG *(256/180);
  orientationAmplitudeImageG = reshape(pixelWeightedMeanVectorCorrectedG(:,2), 512, 512);
  
  orientationSelectivityImageConvertedB = orientationSelectivityImageB *(256/180);
  orientationAmplitudeImageB = reshape(pixelWeightedMeanVectorCorrectedB(:,2), 512, 512);

  orientationSelectivityImageConverted2G = orientationSelectivityImage2G *(256/180);
  orientationSelectivityImageConverted2G = orientationSelectivityImage2G *(256/180);
 
 
 % plot color image
 figure
 imHandle = imagesc(orientationSelectivityImageConvertedG);
 figHandle = imgcf;
 colormap(ggb1)
 clbar = colorbar;
 clbar.Ticks = linspace(0,255, 5);
 clbar.TickLabels = 0:45:180;
 set(figHandle, 'Position' ,[3841,417,1280,951.333333333333]);
 axis square
 saveas(figHandle, [experimentStructure.savePath 'Pixel Orientation Pref Green.tif']);
 
 imwrite(orientationSelectivityImageConvertedG, ggb1, [experimentStructure.savePath 'Pixel Orientation Pref_native_Green.tif']);
 close;
 
  figure
 imHandle = imagesc(orientationSelectivityImageConvertedB);
 figHandle = imgcf;
 colormap(ggb1)
 clbar = colorbar;
 clbar.Ticks = linspace(0,255, 5);
 clbar.TickLabels = 0:45:180;
 set(figHandle, 'Position' ,[3841,417,1280,951.333333333333]);
 axis square
 saveas(figHandle, [experimentStructure.savePath 'Pixel Orientation Pref Blue.tif']);
 
 imwrite(orientationSelectivityImageConvertedB, ggb1, [experimentStructure.savePath 'Pixel Orientation Pref_native_Blue.tif']);
 close;


else
    for pixelNo = 1:length(pixelVectorAngles)
        pixelWeightedMeanVector(pixelNo,:) = [circ_mean(pixelVectorAngles(pixelNo,:,1)', pixelVectorAngles(pixelNo,:,2)') mean(pixelVectorAngles(pixelNo,:,2)) mean(pixelVectorAngles(pixelNo,:,3))];
        
        angleStruct = mean_vector_direction_magnitude([circ_rad2ang(pixelVectorAngles(pixelNo,:,1))' pixelVectorAngles(pixelNo,:,2)']) ;
        pixelWeightedMeanVectorV2(pixelNo,:) = [angleStruct.mean_angle_degrees angleStruct.mean_magnitude mean(pixelVectorAngles(pixelNo,:,3))];
    end
    
    pixelWeightedMeanVector = [circ_rad2ang(pixelWeightedMeanVector(:,1)) pixelWeightedMeanVector(:,2) pixelWeightedMeanVector(:,3)];
    
    % deal with negative average angles
    parfor pixelNo = 1:length(pixelWeightedMeanVector)
        
        if pixelWeightedMeanVector(pixelNo,1) <0
            pixelWeightedMeanVectorCorrected(pixelNo) = ( pixelWeightedMeanVector(pixelNo,1) + 360)/2;
        else
            pixelWeightedMeanVectorCorrected(pixelNo) =  pixelWeightedMeanVector(pixelNo,1);
        end
    end
    
    % reconstruct array
    pixelWeightedMeanVectorCorrected =  [ pixelWeightedMeanVectorCorrected' pixelWeightedMeanVector(:,2) pixelWeightedMeanVector(:,3)];
    
    % reshape into orientation image
    orientationSelectivityImage = reshape(pixelWeightedMeanVectorCorrected(:,1), 512, 512);
    
    orientationSelectivityImage2 = reshape(pixelWeightedMeanVectorV2(:,1), 512, 512);
    
    
    orientationAmplitudeImage = reshape(pixelWeightedMeanVectorCorrected(:,2), 512, 512);
    
    % rescale into colormap
    orientationSelectivityImageConverted = orientationSelectivityImage *(256/180);
    orientationSelectivityImageConverted2 = orientationSelectivityImage2 *(256/180);
    
    
    % plot color image
    figure
    imHandle = imagesc(orientationSelectivityImageConverted);
    figHandle = imgcf;
    colormap(ggb1)
    clbar = colorbar;
    clbar.Ticks = linspace(0,255, 5);
    clbar.TickLabels = 0:45:180;
    set(figHandle, 'Position' ,[3841,417,1280,951.333333333333]);
    axis square
    saveas(figHandle, [experimentStructure.savePath 'Pixel Orientation Pref.tif']);
    
    imwrite(orientationSelectivityImageConverted, ggb1, [experimentStructure.savePath 'Pixel Orientation Pref_native.tif']);
    close;
    



end
%  figure
%  imagesc(orientationAmplitudeImage)
 

end