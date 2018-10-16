function plotOrientationTuningPerCell(experimentStructure, cellNo)

figure('units','normalized','outerposition',[0 0 1 1])
for i =cellNo %[2 38 69 86] %1:cellNumber
    % Compute summary stats for responses
    cndRepitions     = round(mean(experimentStructure.cndTotal(:)));
    angles     = linspace(0,315,length(experimentStructure.cndTotal));
    yData     = cell2mat(experimentStructure.extractedDFstimWindowAverageFISSA{1,i});
    yMean = mean(yData,1);
    yStd  = std(yData,[],1);
    ySEM  = yStd/sqrt(cndRepitions);
    preferredStimulus = find(yMean(1:(end-1)) == max(yMean(1:(end-1))));
    
    % get mean of prestim response (blank screen)
    %     blankResponseMean = mean(mean(cell2mat(experimentStructure.extractedDFpreStimWindowAverageFISSA{1,i})));
    %     blackResponseStd = mean(std(cell2mat(experimentStructure.extractedDFpreStimWindowAverageFISSA{1,i})));
    
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
    timeFrame = ([1: experimentStructure.meanFrameLength] - experimentStructure.stimOnFrames(1)) * experimentStructure.framePeriod;
    %     yResponse     = experimentStructure.extractedDFperCndFISSA{1,i}{1, preferredStimulus};
    %     yResponseMean = experimentStructure.extractedDFperCndMeanFISSA{1,i}(:,preferredStimulus);
    %     yResponseSTD  = experimentStructure.extractedDFperSTDMeanFISSA{1,i}(:,preferredStimulus);
    
    yResponse     = experimentStructure.dFperCndFBS{1,i}{1, preferredStimulus};
    yResponseMean = experimentStructure.dFperCndMeanFBS{1,i}(:,preferredStimulus);
    yResponseSTD  = experimentStructure.dFperCndSTDFBS{1,i}(:,preferredStimulus);
    
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
    title(sprintf('Preferred response at %d%s for cell %d: %s',angles(preferredStimulus),char(176),i, sigText));
    ylabel('\DeltaF/F')
    xlabel('Time (seconds)')
    axis square;
    
    
    % Show tuning curve
    subFighandle = subplot(1,2,2);
    %     plot(angles,yMean,'-ok');
    %     hold on;
    %     errorbar(angles(1:(end-1)),yMean(1:(end-1)),ySEM(1:(end-1)),'ok');
    %     for j = 1:length(angles), plot(angles(j),yData(:,j),'o','Color',0.5*[1,1,1]); end
    %     set(gca,'Box','off','XTick',0:45:315);
    %     xlim([0,315]);
    %     title('Tuning curve');
    %     ylabel('\DeltaF/F')
    %     xlabel(sprintf('Stimulus direction (%s)', char(176)))
    %     axis square;
    hold on
    for x =1:size(experimentStructure.dFperCndMeanFBS{1,i},2)
        lengthOfData = experimentStructure.meanFrameLength;
        if x >1
            spacing = 5;
            xlocations = ((lengthOfData +lengthOfData* (x-1))- (lengthOfData-1) :lengthOfData + lengthOfData* (x-1)) + spacing*(x-1);
            xlocationMid(x) = xlocations(lengthOfData/2);
        else
            spacing = 0;
            xlocations = 0:lengthOfData-1;
            xlocationMid(x) = xlocations(lengthOfData/2);
        end
        
%         errorbar(xlocations, experimentStructure.dFperCndMeanFBS{1,i}(:,x), experimentStructure.dFperCndSTDFBS{1,i}(:,x), 'Color' , 'k');
           shadedErrorBar(xlocations, experimentStructure.dFperCndMeanFBS{1,i}(:,x), experimentStructure.dFperCndSTDFBS{1,i}(:,x), 'lineprops' , 'k');
    end
    
    xticks(xlocationMid);
    xticklabeFBS(0:45:315);
    title('Tuning curve');
    ylabel('\DeltaF/F')
    xlabel(sprintf('Stimulus direction (%s)', char(176)));
    axis square;
    figHandle = gcf;
    tightfig;
    
    saveas(figHandle, [experimentStructure.savePath ' Orientation Tuning Cell ' num2str(i) '_v2.tif']);
    
end

end