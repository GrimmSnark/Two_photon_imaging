function convertPixelOrientationSelectivityToCell(recordingDir, noOrientations, noColor,angleMax, useSTDorMean, channel2Use)
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

recordingDirProcessed = recordingDir; % sets processed data path


% load experimentStructure
load([recordingDirProcessed 'experimentStructure.mat']);
disp('Loaded in experimentStructure');

% set up cell ROI images
cellROIs = experimentStructure.labeledCellROI;
cellMapOrientation = zeros(experimentStructure.pixelsPerLine);
cellMapSelectivity = zeros(experimentStructure.pixelsPerLine);


%% Start calculations for mean angle and amplitude

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
    
    
    % correct for NaN and Inf values
    orientationAmplitudeImage(isnan(orientationAmplitudeImage)) = 0;
    valuesInAmpMap = unique(sort(orientationAmplitudeImage(:)));
    
    if valuesInAmpMap(end) == Inf
        maxVal =  valuesInAmpMap(end-1);
    else
        maxVal =  valuesInAmpMap(end);
    end
    
    orientationAmplitudeImage(orientationAmplitudeImage == Inf) = maxVal;
    
    % for each cell
    for dd = 1:experimentStructure.cellCount
        
        
        % get the index for the pixels within each cell and average them
        % for pref angle and selectivity amplitude
        cellAverageOri(dd) = circ_rad2ang(circ_mean(circ_ang2rad(orientationSelectivityImage(cellROIs == dd))));
        cellSelectivityAmp(dd) = mean(orientationAmplitudeImage(cellROIs == dd));
        
        
        % set average map values per ROI
        cellMapOrientation(cellROIs ==dd) = cellAverageOri(dd);
        cellMapSelectivity(cellROIs ==dd) = cellSelectivityAmp(dd);
        
        grandAverageOri(z,dd) = cellAverageOri(dd);
        grandAverageSelectivity(z,dd) = cellSelectivityAmp(dd);
        
    end
    
    cellMapSelectivityPerColor(:,:,z) = cellMapSelectivity;
    
    % deal with cell pref map
    cellMapOrientationConverted = (cellMapOrientation/180)* 256;
    
    cellMapOrientationConverted(cellMapOrientationConverted==0) = NaN;
    cellMapOrientationRGB = ind2rgb(round(cellMapOrientationConverted),ggb1);
    
    for x = 1:size(cellMapOrientationConverted,1)
        for c = 1:size(cellMapOrientationConverted,2)
            
            if isnan(cellMapOrientationConverted(x,c))
                cellMapOrientationRGB(x,c,:) = 1;
            end
        end
    end
    
    colormap(ggb1);
    figMap = imshow(cellMapOrientationRGB);
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
    colorBar = colorbar ;
    axis on
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    axis square
    tightfig;
    colorBar.Ticks = linspace(0,1, length(anglesPlot));
    colorBar.TickLabels = anglesPlot;
    
    saveas(figMap, [experimentStructure.savePath  'Pixel Cell Orientation Pref_Color_' num2str(z) '.tif']);
    imwrite(cellMapOrientationRGB, [experimentStructure.savePath 'Pixel Cell Orientation Pref_native_Color_' num2str(z) '.tif']);
    
    close();
end

% rescales to global max
cellMapSelectivityPerColorRescaled = cellMapSelectivityPerColor/max(cellMapSelectivityPerColor(:));
cellMapSelectivity256 = cellMapSelectivityPerColorRescaled*length(lcs);

for z = 1:noColor
    cellMapSelectivityRGB = ind2rgb(round(cellMapSelectivity256(:,:,z)), lcs);
    
    % convert to 8bit rgb
    cellMapSelectivityRGB = uint8(floor(cellMapSelectivityRGB*256));
    imwrite(cellMapSelectivityRGB, [experimentStructure.savePath 'Pixel Cell Orientation Selectivity_native_Color_' num2str(z) '_LCS.tif']);
    
end

experimentStructure.pixelCellOrienationAverage = grandAverageOri;
experimentStructure.pixelCellOrientationSelectivity = grandAverageSelectivity;

save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure');
end
