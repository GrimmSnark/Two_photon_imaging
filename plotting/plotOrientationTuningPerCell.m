function plotOrientationTuningPerCell(experimentStructure, cellNo, useSTDorSEM, data2Use )
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
    
     % get Data
    switch data2Use
        
        case 'FBS'
            
            % correct for errors in cell traces (empties)
            empties = cellfun('isempty',experimentStructure.dFstimWindowAverageFBS{1,i});
            
            experimentStructure.dFstimWindowAverageFBS{1,i}(empties) = {NaN};
            experimentStructure.dFpreStimWindowAverageFBS{1,i}(empties) = {NaN};
            experimentStructure.dFpreStimWindowAverageFBS{1,i}(empties) = {NaN};
            
            % get data
            yData     = cell2mat(experimentStructure.dFstimWindowAverageFBS{1,i});
            blankResponse = cell2mat(experimentStructure.dFpreStimWindowAverageFBS{1,i});
            
            
            yResponse     = experimentStructure.dFperCndFBS{1,i};
            yResponseMean = experimentStructure.dFperCndMeanFBS{1,i};
            
            errorBars = experimentStructure.dFperCndSTDFBS{1,i};
            
        case 'Neuro_corr'
            
              % correct for errors in cell traces (empties)
            empties = cellfun('isempty',experimentStructure.dFstimWindowAverage{1,i});
            
            experimentStructure.dFstimWindowAverage{1,i}(empties) = {NaN};
            experimentStructure.dFpreStimWindowAverage{1,i}(empties) = {NaN};
            experimentStructure.dFpreStimWindowAverage{1,i}(empties) = {NaN};
            
            % get data
            yData     = cell2mat(experimentStructure.dFstimWindowAverage{1,i});
            blankResponse = cell2mat(experimentStructure.dFpreStimWindowAverage{1,i});
            
            
            yResponse     = experimentStructure.dFperCnd{1,i};
            yResponseMean = experimentStructure.dFperCndMean{1,i};
            
            errorBars = experimentStructure.dFperCndSTD{1,i};
    end
            
    
     yMean = nanmean(yData,1);

    preferredStimulus = find(yMean(1:(end-1)) == max(yMean(1:(end-1))));

    prefResponses = yData(:,preferredStimulus);
    blankPrefResponses = blankResponse(:,preferredStimulus);
    
    [h, pVal] = ttest(prefResponses, blankPrefResponses);
    
    if pVal < 0.05
        sigText = 'Significant Response';
    else
        sigText = 'Non-signficant Response';
    end
     
     yResponsePreferred = yResponse{1, preferredStimulus};
    yResponseMeanPreferred = yResponseMean(:,preferredStimulus);
    
    % Compute stats for preferred response
    timeFrame = ((1: experimentStructure.meanFrameLength) * experimentStructure.framePeriod) - experimentStructure.stimOnFrames(1)*experimentStructure.framePeriod;
     
    % Show response timcourse for preferred response
    subplot(1,2,1);
    plot(timeFrame,yResponseMeanPreferred,'-r','lineWidth',3);
    hold on;
    plot(timeFrame,yResponsePreferred,'--k','Color',0.25*[1,0,0]);
    legend({'Average response','Trial responses'},'Location','northwest');
    xlim([min(timeFrame) max(timeFrame)]);
    set(gca,'Box','off');
    xticks([0 5, 10]);
    title(sprintf('Preferred response at %d%s for cell %d: %s (p= %0.5g)',angles(preferredStimulus),char(176),i, sigText, pVal));
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
             errorBarsPlot = errorBars (:,x);
        elseif useSTDorSEM ==2
           errorBarsPlot = errorBars (:,x)/ (sqrt(experimentStructure.cndTotal(x)));
          end
        
        shadedErrorBar(xlocations, yResponseMean(:,x)',errorBarsPlot, 'lineprops' , lineCol);
    end
    
    xticks(xlocationMid);
    xticklabels([0:45:315 0:45:315]);
    title('Tuning curve');
    ylabel('\DeltaF/F')
    xlabel(sprintf('Stimulus direction (%s)', char(176)));
    axis square;
    figHandle = gcf;
    tightfig;
    
    if strcmp(data2Use, 'FBS') % if FBS data
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
    else % if using Neuro_corr data
        if useSTDorSEM == 1
            if ~exist([experimentStructure.savePath 'STDs\Neuro_corr\'], 'dir')
                mkdir([experimentStructure.savePath 'STDs\Neuro_corr\']);
            end
            saveas(figHandle, [experimentStructure.savePath 'STDs\Neuro_corr\Orientation Tuning Cell ' num2str(i) '.tif']);
            saveas(figHandle, [experimentStructure.savePath 'STDs\Neuro_corr\Orientation Tuning Cell ' num2str(i) '.svg']);
        elseif useSTDorSEM == 2
            if ~exist([experimentStructure.savePath 'SEMs\Neuro_corr\'], 'dir')
                mkdir([experimentStructure.savePath 'SEMs\Neuro_corr\']);
            end
            saveas(figHandle, [experimentStructure.savePath 'SEMs\Neuro_corr\Orientation Tuning Cell ' num2str(i) '.tif']);
            saveas(figHandle, [experimentStructure.savePath 'SEMs\Neuro_corr\Orientation Tuning Cell ' num2str(i) '.svg']);
        end
    end
    close;
end

end