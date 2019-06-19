function plotOrientationColorTuningPerCellCndAverages(experimentStructure, cellNo, useSTDorSEM, hardYLim)
% plots overlayed color orientation tuning averages for cells responses for
% each condition. Written for ORIENTATION/COLOR stimulus, used to create
% figures for papers/presentation 
%
% Inputs:   experimentStucture- experiment processed data from
%                               experimentStrucure.mat
%           cellNo- number or vector of numbers for cells to plot
%           useSTDorSEM- 1= STD errrobars, 2 = SEM errorbars
%           hardYLim - two number vector for setting Y axis limits for all
%                      cells in cellNo (matches axes)

useSTDorSEM = 2;

% experimentStructure.savePath = 'D:\Data\CristinaR21\PVCre\old\PV_cre_ChR2_Old_M4\5off_5on_6\TSeries-03082019-1001-005\20190315115604\';

for i =cellNo %[2 38 69 86] %1:cellNumber
    figure('units','normalized','outerposition',[0 0 1 1])
    % Compute summary stats for responses
   angles     = linspace(0,315,length(experimentStructure.cndTotal));
    % Show tuning curve
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
        
        if size(experimentStructure.dFperCndMeanFBS{1,i},2) < 9
            lineCol ='k';
        end
        
        if useSTDorSEM == 1
            errorBars = experimentStructure.dFperCndSTDFBS{1,i}(:,x);
        elseif useSTDorSEM ==2
            errorBars = experimentStructure.dFperCndSTDFBS{1,i}(1:end,x)/ (sqrt(experimentStructure.cndTotal(x)));
        end
        
        shadedErrorBar(xlocations(x,:), experimentStructure.dFperCndMeanFBS{1,i}(1:end,x), errorBars, 'lineprops' , lineCol);
    end
    
    xticks(xlocationMid);
    xticklabels(angles);
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
        saveas(figHandle, [experimentStructure.savePath ' Orientation Tuning Cell ' num2str(i) '.tif']);
        saveas(figHandle, [experimentStructure.savePath ' Orientation Tuning Cell ' num2str(i) '.svg']);
    elseif useSTDorSEM == 2
        if ~exist([experimentStructure.savePath 'SEMs_tuning\'], 'dir')
            mkdir([experimentStructure.savePath 'SEMs_tuning\']);
        end
        saveas(figHandle, [experimentStructure.savePath 'SEMs_tuning\Orientation Tuning Cell ' num2str(i) '.tif']);
        saveas(figHandle, [experimentStructure.savePath 'SEMs_tuning\Orientation Tuning Cell ' num2str(i) '.svg']);
    end
  close;  
end

end