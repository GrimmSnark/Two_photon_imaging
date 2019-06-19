function processPixelOrientationSelectivityV2(recordingDir, noOrientations, noColor,angleMax, useSTDorMean, channel2Use)
% Function which plots orientation selectivty maps from STD or mean stim
% images
%
% Inputs: recordingDir - processed data directory file path
%         noOrientations - number of orientations tested in the experiment
%                          ie 4/8 etc
%         noColor - number of colors tested, ie 1 for black/white, 2 for
%                   mouse color paradigm etc
%         angleMax - 360 or 180 for the Max angle tested
%         useSTDorMean - 0/1 flag for using STD (0) or mean (1) per 
%                        condition array for calculations
%         channel2Use - OPTIONAL, specify channel , 1/2 etc for
%                       multichannel recording
%
% recordingDir = 'D:\Data\2P_Data\Processed\Mouse\gCamp6s\M3\5on_5off_8\TSeries-09242018-1042-010\20180927124421\';

if nargin < 6 || isempty(channel2Use)
    channel2Use = 2; % sets up deafult channel to use for multi-channel images
end

angles = linspace(0, angleMax, noOrientations+1);
angles = angles(1:end-1)*2; % angles x2 to make radians and orientation cal easier

if noColor > 1
    angles = repmat(angles, 1, noColor);
end

angles_rad = circ_ang2rad(angles);

recordingDirProcessed = recordingDir; % sets processed data path


% load experimentStructure
load([recordingDirProcessed 'experimentStructure.mat']);
disp('Loaded in experimentStructure');

%% Start calculations

% get the appropriate entry to use for calculations

if useSTDorMean ==1
    
    data2Use = 'stimSTDImageCND';
else
    data2Use = 'stimMeanImageCND';
    
end

% check number of channels in imaging stack
channelIndxStart = strfind(experimentStructure.filenamesFrame{1}, '_Ch');
for i =1:length(experimentStructure.filenamesFrame)
    channelIdentity{i} = experimentStructure.filenamesFrame{i}(channelIndxStart:channelIndxStart+3);
end
channelNo = unique(channelIdentity);


if length(channelNo)>1
    channelIndentifer = channelNo{channel2Use};
    data2Use = [data2Use channelIndentifer];
    disp(['Using Channel '  num2str(channel2Use) ' for orientation pixel calculation']);
end


% get means per cnd
for cnd = 1:length(experimentStructure.cndTotal)
    eval(['stimSTDImagesMean(:,:,cnd) = mean(experimentStructure.' data2Use '(:,:,cnd,:), 4);']);
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
if noColor ==2
    parfor pixelNo = 1:length(pixelVectorAngles)
        
        % Green stimulus
        % Kevin code
        angleStructG = mean_vector_direction_magnitude([circ_rad2ang(pixelVectorAngles(pixelNo,1:8,1))' pixelVectorAngles(pixelNo,1:8,2)']) ;
        pixelWeightedMeanVectorG(pixelNo,:) = [angleStructG.mean_angle_degrees/2 angleStructG.mean_magnitude mean(pixelVectorAngles(pixelNo,:,3))];
        
        % Blue Stimulus
        % kevin code
        angleStructB = mean_vector_direction_magnitude([circ_rad2ang(pixelVectorAngles(pixelNo,9:16,1))' pixelVectorAngles(pixelNo,9:16,2)']) ;
        pixelWeightedMeanVectorB(pixelNo,:) = [angleStructB.mean_angle_degrees/2 angleStructB.mean_magnitude mean(pixelVectorAngles(pixelNo,:,3))];
    end
    
    % deal with angles greater than 180 for all structures (only interested in
    % orientation not direction
    parfor pixelNo = 1:length(pixelWeightedMeanVectorG)
        
        
        
        % green kevin code
        if pixelWeightedMeanVectorG(pixelNo,1) > 180
            pixelWeightedMeanVectorCorrectedG(pixelNo) =  pixelWeightedMeanVectorG(pixelNo,1) - 180 ;
        else
            pixelWeightedMeanVectorCorrectedG(pixelNo) =  pixelWeightedMeanVectorG(pixelNo,1);
        end
        
        % blue kevin code
        if pixelWeightedMeanVectorB(pixelNo,1) > 180
            pixelWeightedMeanVectorCorrectedB(pixelNo) =  pixelWeightedMeanVectorB(pixelNo,1) - 180 ;
        else
            pixelWeightedMeanVectorCorrectedB(pixelNo) =  pixelWeightedMeanVectorB(pixelNo,1);
        end
        
    end
    
    % reconstruct array
    pixelWeightedMeanVectorCorrectedG =  [ pixelWeightedMeanVectorCorrectedG' pixelWeightedMeanVectorG(:,2) pixelWeightedMeanVectorG(:,3)];
    pixelWeightedMeanVectorCorrectedB =  [ pixelWeightedMeanVectorCorrectedB' pixelWeightedMeanVectorB(:,2) pixelWeightedMeanVectorB(:,3)];
    
    
    % reshape into orientation images
    orientationSelectivityImageG = reshape(pixelWeightedMeanVectorCorrectedG(:,1), 512, 512);
    orientationAmplitudeImageG =  reshape(pixelWeightedMeanVectorCorrectedG(:,2), 512, 512);
    
    orientationSelectivityImageB = reshape(pixelWeightedMeanVectorCorrectedB(:,1), 512, 512);
    orientationAmplitudeImageB =  reshape(pixelWeightedMeanVectorCorrectedB(:,2), 512, 512);
    
    
    % rescale into colormap
    orientationSelectivityImageConvertedG = orientationSelectivityImageG *(256/180);
    orientationSelectivityImageConvertedB = orientationSelectivityImageB *(256/180);
    
    
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
    saveas(figHandle, [experimentStructure.savePath 'Pixel Orientation Pref Green.svg']);
    
    imwrite(orientationSelectivityImageConvertedG, ggb1, [experimentStructure.savePath 'Pixel Orientation Pref_native_Green.tif']);
    imwrite(orientationAmplitudeImageG, [experimentStructure.savePath 'Pixel Orientation Selectivity_native_Green.tif']);
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
    imwrite(orientationAmplitudeImageB, [experimentStructure.savePath 'Pixel Orientation Selectivity_native_Blue.tif']);
    
    close;
    
    
else % if only 'grey color'
    parfor pixelNo = 1:length(pixelVectorAngles)
        angleStruct = mean_vector_direction_magnitude([circ_rad2ang(pixelVectorAngles(pixelNo,:,1))' pixelVectorAngles(pixelNo,:,2)']) ;
        pixelWeightedMeanVector(pixelNo,:) = [angleStruct.mean_angle_degrees/2 angleStruct.mean_magnitude mean(pixelVectorAngles(pixelNo,:,3))];
        
    end
    
    % deal with negative average angles
    parfor pixelNo = 1:length(pixelWeightedMeanVector)
        
        % green kevin code
        if pixelWeightedMeanVector(pixelNo,1) > 180
            pixelWeightedMeanVectorCorrected(pixelNo) =  pixelWeightedMeanVector(pixelNo,1) - 180 ;
        else
            pixelWeightedMeanVectorCorrected(pixelNo) =  pixelWeightedMeanVector(pixelNo,1);
        end
    end
    
    % reconstruct array
    pixelWeightedMeanVectorCorrected =  [ pixelWeightedMeanVectorCorrected' pixelWeightedMeanVector(:,2) pixelWeightedMeanVector(:,3)];
    
    % reshape into orientation image
    orientationSelectivityImage = reshape(pixelWeightedMeanVectorCorrected(:,1), 512, 512);
    orientationAmplitudeImage = reshape(pixelWeightedMeanVectorCorrected(:,2), 512, 512);
    
    % rescale into colormap
    orientationSelectivityImageConverted = orientationSelectivityImage *(256/180);
    
    
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
    saveas(figHandle, [experimentStructure.savePath 'Pixel Orientation Pref.svg']);
    
    imwrite(orientationSelectivityImageConverted, ggb1, [experimentStructure.savePath 'Pixel Orientation Pref_native.tif']);
    imwrite(orientationAmplitudeImage, [experimentStructure.savePath 'Pixel Orientation Selectivity_native.tif']);
    
    orientationAmplitudeImageRGB = convertIndexImage2RGB(orientationAmplitudeImage,lcs);
    
    imwrite(orientationAmplitudeImageRGB, [experimentStructure.savePath 'Pixel Orientation Selectivity_native_Color_LCS.tif']);
    
    close;
end
%  figure
%  imagesc(orientationAmplitudeImage)


end