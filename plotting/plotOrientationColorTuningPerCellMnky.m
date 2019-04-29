function plotOrientationColorTuningPerCellMnky(experimentStructure, cellNo, orientationNo, colorNo,  useSTDorSEM)
% plots and saves figure for cells with preferred stimulus average (with
% individual trial and the average responses for each condition. Written
% for ORIENTATION/COLOR stimulus
% Inputs:   experimentStucture- experiment processed data from
%                               experimentStrucure.mat
%           cellNo- number or vector of numbers for cells to plot
%           useSTDorSEM- 1= STD errrobars, 2 = SEM errorbars


for i =cellNo %[2 38 69 86] %1:cellNumber
    figure('units','normalized','outerposition',[0 0 1 1])
    % Compute summary stats for responses
    angles     = linspace(0,180,orientationNo+1);
    angles     = angles(1:end-1);
    
    cndCheck = orientationNo * colorNo;
    
    if cndCheck ~=length(experimentStructure.cndTotal)
        disp('Wrong no of orientation and color conditions entered!!!');
        disp('Please fix and rerun');
        return
    end
    
    % get Data
    yData     = cell2mat(experimentStructure.dFstimWindowAverageFBS{1,i});
    blankResponseMean = mean(mean(cell2mat(experimentStructure.dFpreStimWindowAverageFBS{1,i})));
    blackResponseStd = mean(std(cell2mat(experimentStructure.dFpreStimWindowAverageFBS{1,i})));
    yResponse     = experimentStructure.dFperCndFBS{1,i};
    yResponseMean = experimentStructure.dFperCndMeanFBS{1,i};
    
    errorBars = experimentStructure.dFperCndSTDFBS{1,i};
    
    
    yMean = mean(yData,1);
    preferredStimulus = find(yMean(1:(end-1)) == max(yMean(1:(end-1))));
    
    
    responseThreshold = blankResponseMean+2*blackResponseStd; % The average response at the preferred stimulus must be 2 standard deviations above the blank condition mean
    IsRespSignificant = yMean(preferredStimulus)>responseThreshold;
    
    if IsRespSignificant ==1
        sigText = 'Significant Response';
    else
        sigText = 'Non-signficant Response';
    end
    
    yResponsePreferred = yResponse{1, preferredStimulus};
    yResponseMeanPreferred = yResponseMean(:,preferredStimulus);
    
    
    % Compute stats for preferred response
    timeFrame = (1: experimentStructure.meanFrameLength) * experimentStructure.framePeriod;
    
    % Get preferred color
    [prefOrientation, prefColor] = ind2sub([orientationNo colorNo],preferredStimulus);
%     prefColor = floor(preferredStimulus/orientationNo)+1;
%     prefOrientation = preferredStimulus- ((prefColor-1)*orientationNo);
%     
    [~, colorKey] = PTBOrientationColorValuesMonkeyV2;
    colorKey = colorKey(2:end);
    colorText = colorKey{prefColor};
   
    % Show response timcourse for preferred response
    subplot(1,2,1);
    plot(timeFrame,yResponseMeanPreferred,'-r','lineWidth',3);
    hold on;
    plot(timeFrame,yResponsePreferred,'--k','Color',0.25*[1,0,0]);
    hline(responseThreshold, '--b');
    legend({'Average response','Trial responses', 'Response threshold'},'Location','northwest');
    xlim([min(timeFrame) max(timeFrame)]);
    set(gca,'Box','off');
    xticks([0 5, 10]);
    title(sprintf('Preferred response at %d%s Color: %s for cell %d: %s',angles(prefOrientation),char(176),colorText,i, sigText));
    ylabel('\DeltaF/F')
    xlabel('Time (seconds)')
    axis square;
    
     lineCol =distinguishable_colors(length(colorKey), 'w');
     
     
     % get max and min data for limiting axes
     maxData = yResponseMean + errorBars;
     maxData = max(maxData(:));
     
      minData = yResponseMean - errorBars;
     minData = min(minData(:));
     
    % Show tuning curve
    
    hold on
    prevColor = 0;
    for x =1:size(experimentStructure.dFperCndMeanFBS{1,i},2)
        lengthOfData = experimentStructure.meanFrameLength;
        
        currentColor = (x/orientationNo);
        if floor(currentColor)~=currentColor
            currentColor = ceil(currentColor);
        end
        
        if currentColor< 2
            spacing = 5;
            xlocations(x,:) = ((lengthOfData +lengthOfData* (x-1))- (lengthOfData-1) :lengthOfData + lengthOfData* (x-1)) + spacing*(x-1);
            xlocationMid(x) = xlocations(x,round(lengthOfData/2));
        else
            currentOrientation =  x- ((currentColor-1)*orientationNo);
            xlocations(x,:) = xlocations(currentOrientation,:);
        end
        
        if currentColor > prevColor
            subFighandle = subplot(colorNo,2,currentColor*2);
            xticks(xlocationMid);
            xticklabels([angles]);
            ylabel('\DeltaF/F')
            xlabel(sprintf('Stimulus direction (%s)', char(176)));
            ylim([minData maxData]);
            title(colorKey{currentColor});
            
        end
        
        if useSTDorSEM == 1
            errorBarsPlot = errorBars (:,x);
        elseif useSTDorSEM ==2
            errorBarsPlot = errorBars (:,x)/ (sqrt(experimentStructure.cndTotal(x)));
        end
        
        curentLineCol = lineCol(currentColor,:);
        shadedErrorBar(xlocations(x,:), yResponseMean(:,x)', errorBarsPlot, 'lineprops' , {'color',[curentLineCol]});
        prevColor = currentColor;
    end
    
%     legend( colorKey);
%     axis square;
    figHandle = gcf;
%     tightfig;
    
    if useSTDorSEM == 1
        if ~exist([experimentStructure.savePath 'STDs\'], 'dir')
            mkdir([experimentStructure.savePath 'STDs\']);
        end
        saveas(figHandle, [experimentStructure.savePath 'STDs\Orientation Tuning Cell ' num2str(i) '.tif']);
        saveas(figHandle, [experimentStructure.savePath 'STDs\Orientation Tuning Cell ' num2str(i) '.svg']);
    elseif useSTDorSEM == 2
        if ~exist([experimentStructure.savePath 'SEMs\'], 'dir')
            mkdir([experimentStructure.savePath 'SEMs\']);
        end
        saveas(figHandle, [experimentStructure.savePath 'SEMs\Orientation Tuning Cell ' num2str(i) '.tif']);
        saveas(figHandle, [experimentStructure.savePath 'SEMs\Orientation Tuning Cell ' num2str(i) '.svg']);
    end
    close;
end

end