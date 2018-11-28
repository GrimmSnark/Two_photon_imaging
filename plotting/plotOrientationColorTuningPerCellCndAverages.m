function plotOrientationColorTuningPerCellCndAverages(experimentStructure, cellNo, useSTDorSEM, hardYLim)
% plots overlayed color orientation tuning averages for cells

useSTDorSEM = 2;

for i =cellNo %[2 38 69 86] %1:cellNumber
    figure('units','normalized','outerposition',[0 0 1 1])
    % Compute summary stats for responses
    cndRepitions     = round(mean(experimentStructure.cndTotal(:)));
    angles     = linspace(0,315,length(experimentStructure.cndTotal)/2);
    angles    = [angles angles];
%     yData     = cell2mat(experimentStructure.dFstimWindowAverageFBS{1,i});
%     yMean = mean(yData,1);
%     yStd  = std(yData,[],1);
%     ySEM  = yStd/sqrt(cndRepitions);
    
    
    
    % Show tuning curve
    hold on
    for x =1:size(experimentStructure.dFperCndMeanFBS{1,i},2)
        lengthOfData = experimentStructure.meanFrameLength -6;
        if x >1 && x < 9
            spacing = 5;
            xlocations(x,:) = ((lengthOfData +lengthOfData* (x-1))- (lengthOfData-1) :lengthOfData + lengthOfData* (x-1)) + spacing*(x-1);
            xlocationMid(x) = xlocations(x,lengthOfData/2);
        elseif x == 1
            spacing = 0;
            xlocations(x,:) = 0:lengthOfData-1;
            xlocationMid(x) = xlocations(x,lengthOfData/2);
        elseif x > 8
            xlocations(x,:) = xlocations(x-8,:);
        end
        
        if x < 9
            lineCol = 'g';
        else
            lineCol ='k';
        end
        
        if size(experimentStructure.dFperCndMeanFBS{1,i},2) < 9
            lineCol ='k';
        end
        
        if useSTDorSEM == 1
            errorBars = experimentStructure.dFperCndSTDFBS{1,i}(:,x);
        elseif useSTDorSEM ==2
            errorBars = experimentStructure.dFperCndSTDFBS{1,i}(1:end-6,x)/ (sqrt(experimentStructure.cndTotal(x)));
        end
        
        shadedErrorBar(xlocations(x,:), experimentStructure.dFperCndMeanFBS{1,i}(1:end-6,x), errorBars, 'lineprops' , lineCol);
    end
    
    xticks(xlocationMid);
    xticklabels([0:45:315 0:45:315]);
    title('Tuning curve');
    ylabel('\DeltaF/F')
    
    if ~isempty(hardYLim)
        limsY = ylim;
        ylim([hardYLim(1) hardYLim(2)]);
    end
    
    xlabel(sprintf('Stimulus direction (%s)', char(176)));
    figHandle = gcf;
    tightfig;
    
    if useSTDorSEM == 1
        saveas(figHandle, [experimentStructure.savePath ' Orientation Tuning Cell ' num2str(i) '_v2.tif']);
        saveas(figHandle, [experimentStructure.savePath ' Orientation Tuning Cell ' num2str(i) '_v2.svg']);
    elseif useSTDorSEM == 2
        if ~exist([experimentStructure.savePath 'SEMs_tuning\'], 'dir')
            mkdir([experimentStructure.savePath 'SEMs_tuning\']);
        end
        saveas(figHandle, [experimentStructure.savePath 'SEMs_tuning\Orientation Tuning Cell ' num2str(i) '_v2.tif']);
        saveas(figHandle, [experimentStructure.savePath 'SEMs_tuning\Orientation Tuning Cell ' num2str(i) '_v2.svg']);
    end
  close;  
end

end