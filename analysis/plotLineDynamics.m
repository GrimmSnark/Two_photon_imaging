function plotLineDynamics(MIJImageROI,registeredVolMIJI, experimentStructure)
% Subfunction called by lineAnalysisForBloodVessels which actually plots
% line selection averages per condition in a stim on locked time series.
roiLine = MIJImageROI.getRoi();
pointsOnLine = roiLine.getContainedPoints();

for i = 1:length(pointsOnLine)
    pointsOnLineCoordinates(i,:) = [ pointsOnLine(i).getX pointsOnLine(i).getY ];
    registeredVolMIJI.setRoi(pointsOnLineCoordinates(i,1), pointsOnLineCoordinates(i,2),1,1);
    
    plotF = ij.plugin.ZAxisProfiler.getPlot(registeredVolMIJI);
    RT(:,1) = plotF.getXValues();
    RT(:,2) = plotF.getYValues();
    zProfilesPerPixel(i,:)= RT(:,2);
    
end

stimOnLine = zeros(length(zProfilesPerPixel), 1);

% stimOnLine(experimentStructure.EventFrameIndx.STIM_ON) = max(zProfilesPerPixel(:)/2);
% markedZProfilesPerPixel = [stimOnLine zProfilesPerPixel'];
% axisLabel  = imagesc(markedZProfilesPerPixel);
% axis equal
% scrollplot('axis', 'xy');
% colormap(lcs);

for cnd = 1:length(experimentStructure.cndTotal)
    cndIndexs = find(experimentStructure.cnd(:,2) == cnd);
    for trial = 1:length(cndIndexs)
        framStimStart = experimentStructure.EventFrameIndx.STIM_ON(cndIndexs(trial));
        
        cndLines(cnd,trial,:,:) = zProfilesPerPixel(:,framStimStart-7:(framStimStart + experimentStructure.meanFrameLength) -1);
    end
end

cndLineMeans = squeeze(mean(cndLines,2));
figHandle = figure('units','normalized','outerposition',[0 0 1 1]);

cndLineMeans = cndLineMeans([2 3 6 7],:,:);
maxVal = max(cndLineMeans(:));
minVal = min(cndLineMeans(:));
for plotNo = 1:size(cndLineMeans,1)
    colormap(lcs);

    subplot( 2, 4, plotNo);
    handeIm = imagesc(squeeze(cndLineMeans(plotNo,:,:))');
    tempImg = squeeze(cndLineMeans(plotNo,:,:))';
%    rgbTempImg = convertIndexImage2RGB(tempImg, lcs, minVal, maxVal);
%  
%     imwrite(rgbTempImg, [experimentStructure.savePath ' Cnd ' num2str(plotNo) ' Line Plot .tiff']);
    title(['Condition: ' num2str(plotNo)]);
    
    
    yticks([0:7:size(cndLineMeans, 2)]);
    yticklabels(-5:5:25);
    
    lineSize = length(cndLineMeans(1,:,1));
    lineSizeinMicron = round(lineSize * experimentStructure.micronsPerPixel(1), -1);
    increment = experimentStructure.micronsPerPixel(1)*10;
    middleXTickValue = lineSize/2;
    
    currentTick = middleXTickValue;
    runningtotal = [];
    while currentTick > 0
        runningtotal = [runningtotal currentTick] ;
        currentTick = currentTick-increment;
    end
    
    runningtotal2 = middleXTickValue+ increment;
    currentTick = runningtotal2;
    while currentTick < lineSize
        currentTick = currentTick+increment;
        runningtotal2 = [runningtotal2 currentTick];
    end
    
    xtickVals = [fliplr(runningtotal) runningtotal2(1:end-1)];
    xticks(xtickVals)
    xticklabels(-20:10:20);
    
end
saveas(figHandle, [experimentStructure.savePath 'Vessel Line Plot X1_' num2str(pointsOnLineCoordinates(1,1)) ' Y1_' num2str(pointsOnLineCoordinates(1,2)) ' X2_' num2str(pointsOnLineCoordinates(end,1)) ' Y2_' num2str(pointsOnLineCoordinates(end,2)) '.png']);
saveas(figHandle, [experimentStructure.savePath 'Vessel Line Plot X1_' num2str(pointsOnLineCoordinates(1,1)) ' Y1_' num2str(pointsOnLineCoordinates(1,2)) ' X2_' num2str(pointsOnLineCoordinates(end,1)) ' Y2_' num2str(pointsOnLineCoordinates(end,2)) '.svg']);

% close;
end
