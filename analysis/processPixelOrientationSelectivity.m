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

%% Start calculations
% get means per cnd
for cnd = 1:length(experimentStructure.cndTotal)
    stimSTDImagesMean(:,:,cnd) = mean(experimentStructure.stimSTDImageCND(:,:,cnd,:), 4);
end

% normalise to max pixel val

stimSTDImagesMeanNorm = (stimSTDImagesMean / max(stimSTDImagesMean(:)));

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
        
        % Green stimulus
        % circ toolbox
        pixelWeightedMeanVectorG(pixelNo,:) = [circ_mean(pixelVectorAngles(pixelNo,1:8,1)', pixelVectorAngles(pixelNo,1:8,2)') mean(pixelVectorAngles(pixelNo,1:8,2)) mean(pixelVectorAngles(pixelNo,1:8,3))];
        
        % Kevin code
        angleStructG = mean_vector_direction_magnitude([circ_rad2ang(pixelVectorAngles(pixelNo,1:8,1))' pixelVectorAngles(pixelNo,1:8,2)']) ;
        pixelWeightedMeanVectorV2G(pixelNo,:) = [angleStructG.mean_angle_degrees/2 angleStructG.mean_magnitude mean(pixelVectorAngles(pixelNo,:,3))];
        
        % Blue Stimulus
        % circ toolbox
        pixelWeightedMeanVectorB(pixelNo,:) = [circ_mean(pixelVectorAngles(pixelNo,9:16,1)', pixelVectorAngles(pixelNo,9:16,2)') mean(pixelVectorAngles(pixelNo,9:16,2)) mean(pixelVectorAngles(pixelNo,9:16,3))];
        
        % kevin code
        angleStructB = mean_vector_direction_magnitude([circ_rad2ang(pixelVectorAngles(pixelNo,9:16,1))' pixelVectorAngles(pixelNo,9:16,2)']) ;
        pixelWeightedMeanVectorV2B(pixelNo,:) = [angleStructB.mean_angle_degrees/2 angleStructB.mean_magnitude mean(pixelVectorAngles(pixelNo,:,3))];
    end
    
    % coverts radians back into degrees ( one cause of the weirdness)
    pixelWeightedMeanVectorG = [wrapTo2Pi((pixelWeightedMeanVectorG(:,1)/2))* 180/pi pixelWeightedMeanVectorG(:,2) pixelWeightedMeanVectorG(:,3)];
    pixelWeightedMeanVectorB = [wrapTo2Pi((pixelWeightedMeanVectorB(:,1)/2))* 180/pi pixelWeightedMeanVectorB(:,2) pixelWeightedMeanVectorB(:,3)];
    
    % deal with angles greater than 180 for all structures (only interested in
    % orientation not direction
    parfor pixelNo = 1:length(pixelWeightedMeanVectorG)
        
        % green circ toolbox
        if pixelWeightedMeanVectorG(pixelNo,1) > 180
            pixelWeightedMeanVectorCorrectedG(pixelNo) = pixelWeightedMeanVectorG(pixelNo,1) - 180;
        else
            pixelWeightedMeanVectorCorrectedG(pixelNo) =  pixelWeightedMeanVectorG(pixelNo,1);
        end
        
        % blue circ toolbox
        if pixelWeightedMeanVectorB(pixelNo,1) > 180
            pixelWeightedMeanVectorCorrectedB(pixelNo) =  pixelWeightedMeanVectorB(pixelNo,1) - 180;
        else
            pixelWeightedMeanVectorCorrectedB(pixelNo) =  pixelWeightedMeanVectorB(pixelNo,1);
        end
        
        % green kevin code
        if pixelWeightedMeanVectorV2G(pixelNo,1) > 180
            pixelWeightedMeanVectorCorrectedG2(pixelNo) =  pixelWeightedMeanVectorV2G(pixelNo,1) - 180 ;
        else
            pixelWeightedMeanVectorCorrectedG2(pixelNo) =  pixelWeightedMeanVectorV2G(pixelNo,1);
        end
        
        % blue kevin code
        if pixelWeightedMeanVectorV2B(pixelNo,1) > 180
            pixelWeightedMeanVectorCorrectedB2(pixelNo) =  pixelWeightedMeanVectorV2B(pixelNo,1) - 180 ;
        else
            pixelWeightedMeanVectorCorrectedB2(pixelNo) =  pixelWeightedMeanVectorV2B(pixelNo,1);
        end
        
    end
    
    % reconstruct array
    pixelWeightedMeanVectorCorrectedG =  [ pixelWeightedMeanVectorCorrectedG' pixelWeightedMeanVectorG(:,2) pixelWeightedMeanVectorG(:,3)];
    pixelWeightedMeanVectorCorrectedB =  [ pixelWeightedMeanVectorCorrectedB' pixelWeightedMeanVectorB(:,2) pixelWeightedMeanVectorB(:,3)];
    
    pixelWeightedMeanVectorCorrectedG2 =  [ pixelWeightedMeanVectorCorrectedG2' pixelWeightedMeanVectorV2G(:,2) pixelWeightedMeanVectorV2G(:,3)];
    pixelWeightedMeanVectorCorrectedB2 =  [ pixelWeightedMeanVectorCorrectedB2' pixelWeightedMeanVectorV2B(:,2) pixelWeightedMeanVectorV2B(:,3)];
    
    
    % reshape into orientation images
    orientationSelectivityImageG = reshape(pixelWeightedMeanVectorCorrectedG(:,1), 512, 512);
    orientationSelectivityImageB = reshape(pixelWeightedMeanVectorCorrectedB(:,1), 512, 512);
    
    orientationSelectivityImage2G = reshape(pixelWeightedMeanVectorCorrectedG2(:,1), 512, 512);
    orientationSelectivityImage2B = reshape(pixelWeightedMeanVectorCorrectedB2(:,1), 512, 512);
    
    
    orientationAmplitudeImageG = reshape(pixelWeightedMeanVectorCorrectedG(:,2), 512, 512);
    orientationAmplitudeImageB = reshape(pixelWeightedMeanVectorCorrectedB(:,2), 512, 512);
    
    % rescale into colormap
    orientationSelectivityImageConvertedG = orientationSelectivityImageG *(256/180);
    orientationAmplitudeImageG = reshape(pixelWeightedMeanVectorCorrectedG(:,2), 512, 512);
    
    orientationSelectivityImageConvertedB = orientationSelectivityImageB *(256/180);
    orientationAmplitudeImageB = reshape(pixelWeightedMeanVectorCorrectedB(:,2), 512, 512);
    
    orientationSelectivityImageConverted2G = orientationSelectivityImage2G *(256/180);
    orientationAmplitudeImage2G =  reshape(pixelWeightedMeanVectorCorrectedG2(:,2), 512, 512);
    
    orientationSelectivityImageConverted2B = orientationSelectivityImage2B *(256/180);
    orientationAmplitudeImage2B =  reshape(pixelWeightedMeanVectorCorrectedB2(:,2), 512, 512);
    
    
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
    imwrite(orientationAmplitudeImage2G, [experimentStructure.savePath 'Pixel Orientation Selectivity_native_Green.tif']);
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
    saveas(figHandle, [experimentStructure.savePath 'Pixel Orientation Pref BlueV3.tif']);
    
    imwrite(orientationSelectivityImageConvertedB, ggb1, [experimentStructure.savePath 'Pixel Orientation Pref_native_Blue.tif']);
    imwrite(orientationAmplitudeImage2B, [experimentStructure.savePath 'Pixel Orientation Selectivity_native_Blue.tif']);
    
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