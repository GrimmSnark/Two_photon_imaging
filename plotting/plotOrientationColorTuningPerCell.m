function plotOrientationColorTuningPerCell(experimentStructure, cellNo, useSTDorSEM)
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
    angles     = linspace(0,315,length(experimentStructure.cndTotal)/2);
    yData     = cell2mat(experimentStructure.dFstimWindowAverageFBS{1,i});
    yMean = mean(yData,1);
    preferredStimulus = find(yMean(1:(end-1)) == max(yMean(1:(end-1))));
    
    % get mean of prestim response (blank screen)
 
    blankResponseMean = mean(mean(cell2mat(experimentStructure.dFpreStimWindowAverageFBS{1,i})));
    blackResponseStd = mean(std(cell2mat(experimentStructure.dFpreStimWindowAverageFBS{1,i})));
    
    
    
    responseThreshold = blankResponseMean+2*blackResponseStd; % The average response at the preferred stimulus must be 2 standard deviations above the blank condition mean
    IsRespSignificant = yMean(preferredStimulus)>responseThreshold;
    
    if IsRespSignificant ==1
        sigText = 'Significant Response';
    else
        sigText = 'Non-signficant Response';
    end
    
    % Compute stats for preferred response
    timeFrame = (1: experimentStructure.meanFrameLength - experimentStructure.stimOnFrames(1)) * experimentStructure.framePeriod;
    yResponse     = experimentStructure.dFperCndFBS{1,i}{1, preferredStimulus};
    yResponseMean = experimentStructure.dFperCndMeanFBS{1,i}(:,preferredStimulus);
    
    % Get preferred color
    
    if preferredStimulus <9
        colorText = 'Green';
        labelStim = preferredStimulus;
    else
        colorText = 'Blue';
        labelStim = preferredStimulus-8;
    end
    
    % Show response timcourse for preferred response
    subplot(1,2,1);
    plot(timeFrame,yResponseMean,'-r','lineWidth',3);
    hold on;
    plot(timeFrame,yResponse,'--k','Color',0.25*[1,0,0]);
    hline(responseThreshold, '--b');
    legend({'Average response','Trial responses', 'Response threshold'},'Location','northwest');
    xlim([min(timeFrame) max(timeFrame)]);
    set(gca,'Box','off');
    xticks([0 5, 10]);
    title(sprintf('Preferred response at %d%s %s for cell %d: %s',angles(labelStim),char(176),colorText,i, sigText));
    ylabel('\DeltaF/F')
    xlabel('Time (seconds)')
    axis square;
    
    
    % Show tuning curve
    subFighandle = subplot(1,2,2);
    hold on
    for x =1:size(experimentStructure.dFperCndMeanFBS{1,i},2)
        lengthOfData = experimentStructure.meanFrameLength;
        if x >1 && x < 9
            spacing = 5;
            xlocations(x,:) = ((lengthOfData +lengthOfData* (x-1))- (lengthOfData-1) :lengthOfData + lengthOfData* (x-1)) + spacing*(x-1);
            xlocationMid(x) = xlocations(x,round(lengthOfData/2));
        elseif x == 1
            spacing = 0;
            xlocations(x,:) = 0:lengthOfData-1;
            xlocationMid(x) = xlocations(x,round(lengthOfData/2));
        elseif x > 8
            xlocations(x,:) = xlocations(x-8,:);
        end
        
        if x < 9
            lineCol = 'g';
        else
            lineCol ='k';
        end
        
        if useSTDorSEM == 1
            errorBars = experimentStructure.dFperCndSTDFBS{1,i}(:,x);
        elseif useSTDorSEM ==2
            errorBars = experimentStructure.dFperCndSTDFBS{1,i}(:,x)/ (sqrt(experimentStructure.cndTotal(x)));
        end
        
        shadedErrorBar(xlocations, experimentStructure.dFperCndMeanFBS{1,i}(:,x), errorBars, 'lineprops' , lineCol);
    end
    
    xticks(xlocationMid);
    xticklabels([angles]);
    title('Tuning curve');
    ylabel('\DeltaF/F')
    xlabel(sprintf('Stimulus direction (%s)', char(176)));
    axis square;
    figHandle = gcf;
    tightfig;
    
    if useSTDorSEM == 1
        saveas(figHandle, [experimentStructure.savePath ' Orientation Tuning Cell ' num2str(i) '.tif']);
        saveas(figHandle, [experimentStructure.savePath ' Orientation Tuning Cell ' num2str(i) '.svg']);
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