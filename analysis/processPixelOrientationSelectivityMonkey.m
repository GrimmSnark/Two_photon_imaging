function processPixelOrientationSelectivityMonkey(recordingDir, noOrientations, noColor,angleMax, useSTDorMean, channel2Use)
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
anglesPlot = angles;
angles = angles(1:end-1)*2;
if noColor > 1
    angles = repmat(angles, 1, noColor);
end

% angles_rad = circ_ang2rad(angles);

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
% pixelVectorAngles = zeros(length(reshapedImageNorm), length(experimentStructure.cndTotal), 3);

parfor pixelNo = 1:length(reshapedImageNorm)
    pixelVectorAngles(pixelNo,:,:) = [angles ;reshapedImageNorm(pixelNo,:) ;reshapedImage(pixelNo,:)]';
end

% calculate vector mean per pixel per cnd
colorCndStart = [1:noOrientations:length(experimentStructure.cndTotal) length(experimentStructure.cndTotal)];
condCndEnd = colorCndStart-1;
condCndEnd = condCndEnd(2:end);
condCndEnd(end) = length(experimentStructure.cndTotal);

for x =1:noColor
    parfor pixelNo = 1:length(pixelVectorAngles)
        angleStructG = mean_vector_direction_magnitude([pixelVectorAngles(pixelNo,colorCndStart(x):condCndEnd(x),1)' pixelVectorAngles(pixelNo,colorCndStart(x):condCndEnd(x),2)']) ;
        pixelWeightedMeanVector(pixelNo,:, x) = [angleStructG.mean_angle_degrees/2 angleStructG.mean_magnitude mean(pixelVectorAngles(pixelNo,colorCndStart(x):condCndEnd(x),3))];
    end

%     pixelWeightedMeanVector(:,:,x) = abs(pixelWeightedMeanVector(:,:,x));
    % deal with angles greater than 180 for all structures (only interested in
    % orientation not direction
    parfor pixelNo = 1:length(pixelWeightedMeanVector)
        
        if pixelWeightedMeanVector(pixelNo,1, x) > 180
            pixelWeightedMeanVectorRealigned(pixelNo,x) =  pixelWeightedMeanVector(pixelNo,1,x) - 180 ;
        else
            pixelWeightedMeanVectorRealigned(pixelNo,x) =  pixelWeightedMeanVector(pixelNo,1,x);
        end
    end
    
      % reconstruct array
    pixelWeightedMeanVectorCorrected(:,:,x) =  [ pixelWeightedMeanVectorRealigned(:,x) pixelWeightedMeanVector(:,2,x) pixelWeightedMeanVector(:,3,x)];   
end


for z = 1:noColor
    
    % reshape into orientation images
    orientationSelectivityImage = reshape(pixelWeightedMeanVectorCorrected(:,1,z), 512, 512);
    orientationAmplitudeImage =  reshape(pixelWeightedMeanVectorCorrected(:,2,z), 512, 512);  
    
    % rescale into colormap
    orientationSelectivityImageConverted = (orientationSelectivityImage/180)*256;    
    % plot color image
    figure
    imHandle = imagesc(orientationSelectivityImageConverted);
    figHandle = imgcf;
    colormap(ggb1)
    clbar = colorbar;
    clbar.Ticks = linspace(0,255, length(anglesPlot));
    clbar.TickLabels = anglesPlot;
    set(figHandle, 'Position' ,[3841,417,1280,951.333333333333]);
    axis square
    saveas(figHandle, [experimentStructure.savePath 'Pixel Orientation Pref_Color_' num2str(z) '.tif']);
    
    imwrite(orientationSelectivityImageConverted, ggb1, [experimentStructure.savePath 'Pixel Orientation Pref_native_Color_' num2str(z) '.tif']);
    imwrite(orientationAmplitudeImage, [experimentStructure.savePath 'Pixel Orientation Selectivity_native_Color_' num2str(z) '.tif']);
    
    % correct for NaN and Inf values
    orientationAmplitudeImage(isnan(orientationAmplitudeImage)) = 0; 
    valuesInAmpMap = unique(sort(orientationAmplitudeImage(:)));
    
    if valuesInAmpMap(end) == Inf
       maxVal =  valuesInAmpMap(end-1);
    else
         maxVal =  valuesInAmpMap(end);
    end
        
     orientationAmplitudeImage(orientationAmplitudeImage == Inf) = maxVal; 
    
    % rescale and write Amplitude map in LCS colors
    orientationAmplitudeImageRGB = convertIndexImage2RGB(orientationAmplitudeImage,lcs);
    
    imwrite(orientationAmplitudeImageRGB, [experimentStructure.savePath 'Pixel Orientation Selectivity_native_Color_' num2str(z) '_LCS.tif']);
    
    close;
end
    
end
