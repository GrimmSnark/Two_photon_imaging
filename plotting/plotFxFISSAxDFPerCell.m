function plotFxFISSAxDFPerCell(experimentStructure, cellNo)
% Plots a comparison trace for a single cell of the raw fluoresecence, the
% FISSA extracted fluoresecence against baseline, and the final DF/F to get
% an idea of what the behaviour is

figHandle= figure('units','normalized','outerposition',[0 0 0.5 1]);
ax1 = subplot(4,1,1);
title(['Raw Fluoresecence Cell No ' num2str(cellNo)]);
hold on
plot(experimentStructure.rawF(cellNo,:), 'k');

xlim([0 length(experimentStructure.dF(cellNo,:))]);
ylim([-0.2 max(experimentStructure.rawF(cellNo,:))]);
ylabel('Raw Fluoresecence');
xlabel('Frame No.');

ax2 = subplot(4,1,2);
title(['Extraced Fluoresecence and Baseline Cell No ' num2str(cellNo)]);
hold on
plot(experimentStructure.extractedF_FISSA(cellNo,:)+100, 'k');
plot(experimentStructure.baseline(cellNo,:), 'r');
ylabel('Raw Fluoresecence');
xlabel('Frame No.');


xlim([0 length(experimentStructure.dF(cellNo,:))]);
ylim([-0.2 max(experimentStructure.extractedF_FISSA(cellNo,:)+100)]);

ax3 = subplot(4,1,3);
hold on
title(['Delta F/F Cell No ' num2str(cellNo)]);
plot(experimentStructure.dF(cellNo,:),'k');

xlim([0 length(experimentStructure.dF(cellNo,:))]);
ylim([-0.2 max(experimentStructure.dF(cellNo,:))]);
ylabel('Delta F/F');
xlabel('Frame No.');


ax4 = subplot(4,1,4);
data2plot = experimentStructure.dFperCndMean{1,cellNo};

for x =1:size(data2plot, 2)
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
    
    errorBars = experimentStructure.dFperCndSTD{1,cellNo}(:,x);
    
    % plot data
    shadedErrorBar(xlocations, data2plot(:,x), errorBars, 'lineprops' , lineCol);
    
    
    
    yMaxVector(x) =  max(data2plot(:,x)+errorBars);
    yMinVector(x) =  min(data2plot(:,x)-errorBars);
end

xticks(xlocationMid);
xticklabels([1:size(data2plot, 2)]);
title('Tuning curve');
xlabel(sprintf('Stimulus direction (%s)', char(176)));
xLim = [1 xlocations(end)];


% find y axis lims
yLim = [min(yMinVector)-0.2 max(yMaxVector)+0.2];
ylabel('Delta F/F');

hline(0,'r','');
tightfig;

legend(ax2, 'Extracted FISSA F', 'Rolling Baseline');

saveas(figHandle, [experimentStructure.savePath ' Cell Summary Plot ' num2str(cellNo) '.jpeg']);
close;
end