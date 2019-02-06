function plotOrientationTuningPerCell(experimentStructure, cellNo, useSTDorSEM )
% plots and saves figure for cells with preferred stimulus average (with
% individual trial and the average responses for each condition. Written
% for ORIENTATION stimulus
% Inputs:   experimentStucture- experiment processed data from
%                               experimentStrucure.mat
%           cellNo- number or vector of numbers for cells to plot
%           useSTDorSEM- 1= STD errrobars, 2 = SEM errorbars

for i =cellNo %[2 38 69 86] %1:cellNumber
    figure('units','normalized','outerposition',[0 0 1 1])
    % Compute summary stats for responses
%     cndRepitions     = round(mean(experimentStructure.cndTotal(:)));
    angles     = linspace(0,315,length(experimentStructure.cndTotal));
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
    timeFrame = [1:experimentStructure.meanFrameLength] * experimentStructure.framePeriod;
    
    yResponse     = experimentStructure.dFperCndFBS{1,i}{1, preferredStimulus};
    yResponseMean = experimentStructure.dFperCndMeanFBS{1,i}(:,preferredStimulus);
    
    
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
    hold on
    for x =1:size(experimentStructure.dFperCndMeanFBS{1,i},2)
        lengthOfData = experimentStructure.meanFrameLength;
        if x >1
            spacing = 5;
            xlocations = ((lengthOfData +lengthOfData* (x-1))- (lengthOfData-1) :lengthOfData + lengthOfData* (x-1)) + spacing*(x-1);
            xlocationMid(x) = xlocations(round(lengthOfData/2));
        else
            spacing = 0;
            xlocations = 0:lengthOfData-1;
            xlocationMid(x) = xlocations(round(lengthOfData/2));
        end
        
        lineCol = 'k';
        
          if useSTDorSEM == 1
            errorBars = experimentStructure.dFperCndSTDFBS{1,i}(:,x);
        elseif useSTDorSEM ==2
            errorBars = experimentStructure.dFperCndSTDFBS{1,i}(:,x)/ (sqrt(experimentStructure.cndTotal(x)));
          end
        
        shadedErrorBar(xlocations, experimentStructure.dFperCndMeanFBS{1,i}(:,x),errorBars, 'lineprops' , lineCol);
    end
    
    xticks(xlocationMid);
    xticklabels([0:45:315 0:45:315]);
    title('Tuning curve');
    ylabel('\DeltaF/F')
    xlabel(sprintf('Stimulus direction (%s)', char(176)));
    axis square;
    figHandle = gcf;
    tightfig;
    
    saveas(figHandle, [experimentStructure.savePath ' Orientation Tuning Cell ' num2str(i) '.tif']);
    close;
end

end