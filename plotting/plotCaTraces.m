function plotCaTraces(cellNum, experimentStructure, figData, cmap)
% plots the traces based on drop down trace choice
% Inputs- cellNum (integer of cell)
%         experimentStructure (data structure)
%         figData (figure 'UserData' collected from get(H.ax, 'UserData')
%         cmap (color map used in cell image)

%% get global variables
global H
global hAx
global hLine
persistent legendHandle

%% set up traces

% sets condition colours for the condition plot
conditionCols = distinguishable_colors(size(experimentStructure.dFperCndMean{1,cellNum}, 2), 'k');

% deals with plot type requested
switch figData.plotChoice
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% normal analysis plots %%%%%%%%%%%%%%%%%
    case 'rawF'
        data2plot = experimentStructure.rawF(cellNum,:);
        hLine = handle(line(1:length(data2plot),data2plot,...
            'Color',cmap(cellNum+1, :), 'Parent',hAx,'LineWidth',1));
        
        hAx.XLim = [0 length(data2plot)];
        hAx.XTick = [0:50:length(data2plot) ];
        hAx.YLim = [min(data2plot) max(data2plot)];
        
        if ~isempty(legendHandle) % checks if legend has been created previously, destroys if so
            try set(legendHandle,'visible','off');
                legendHandle =[];
                
            catch ME
                return
            end
        end
        
    case 'dF/F'
        data2plot = experimentStructure.dF(cellNum,:);
        hLine = handle(line(1:length(data2plot),data2plot,...
            'Color',cmap(cellNum+1, :), 'Parent',hAx,'LineWidth',1));
        
        hAx.XLim = [0 length(data2plot)];
        hAx.XTick = [0:50:length(data2plot) ];
        hAx.YLim = [min(data2plot) max(data2plot)];
        
        if ~isempty(legendHandle) % checks if legend has been created previously, destroys if so
            try set(legendHandle,'visible','off');
                legendHandle =[];
                
            catch ME
                return
            end
        end
        
    case 'mean Cnd dF/F'
        data2plot = experimentStructure.dFperCndMean{1,cellNum};
        legendText ={};
        
        % plots each condition at different color and builds legend text
        for i =1:size(experimentStructure.dFperCndMean{1,cellNum}, 2)
            
            hLine(numel(hLine)+1) = handle(line(1:size(data2plot,1),data2plot(:,i) ...
                ,'Color',conditionCols(i, :), 'Parent',hAx,'LineWidth',1));
            
            legendText = [legendText {['Condition ' num2str(i)]}];
        end
        hAx.YLim = [min(data2plot(:)) max(data2plot(:))];
        
        xLim = xlim;
        yLim = ylim;
        
        %         hLine(numel(hLine)+1) = handle(rectangle(hAx, 'Position', [experimentStructure.stimOnFrames(1) xLim(1) (experimentStructure.stimOnFrames(2)-experimentStructure.stimOnFrames(1)) yLim(2)], 'FaceColour', [0.5 0.5 0.5]));
        
        patchVertices = [experimentStructure.stimOnFrames(1), yLim(1); ...
            experimentStructure.stimOnFrames(1), yLim(2)+0.5; ...
            experimentStructure.stimOnFrames(2), yLim(2)+0.5; ...
            experimentStructure.stimOnFrames(2), yLim(1)];
        hLine(numel(hLine)+1) = patch( 'vertices', patchVertices, 'faces', [1,2,3,4], 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.5);
        
        % plots legend
        hAx.XLim = [1 size(data2plot,1)];
        hAx.XTickMode = 'auto';
        legendHandle = legend(hAx,legendText, 'Location', 'southwest', 'TextColor', 'w');
        
    case 'mean dF/F'
        data2plot = experimentStructure.dFperCndMean{1,cellNum};
        data2plot = mean(data2plot,2);
        
        hLine = handle(line(1:length(data2plot),data2plot,...
            'Color',cmap(cellNum+1, :), 'Parent',hAx,'LineWidth',1));
        
        hAx.XLim = [1 length(data2plot)];
        
        if ~isempty(legendHandle) % checks if legend has been created previously, destroys if so
            try set(legendHandle,'visible','off');
                legendHandle =[];
                
            catch ME
                return
            end
        end
        
        hAx.YLim = [min(data2plot) max(data2plot)];
        xLim = xlim;
        yLim = ylim;
        
        %         hLine(numel(hLine)+1) = handle(rectangle(hAx, 'Position', [experimentStructure.stimOnFrames(1) xLim(1) (experimentStructure.stimOnFrames(2)-experimentStructure.stimOnFrames(1)) yLim(2)]));
        
        patchVertices = [experimentStructure.stimOnFrames(1), yLim(1); ...
            experimentStructure.stimOnFrames(1), yLim(2)+0.5; ...
            experimentStructure.stimOnFrames(2), yLim(2)+0.5; ...
            experimentStructure.stimOnFrames(2), yLim(1)];
        hLine(numel(hLine)+1) = patch( 'vertices', patchVertices, 'faces', [1,2,3,4], 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.5);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%% FISSA Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    case 'rawF_FISSA'
        data2plot = experimentStructure.rawF_FISSA(cellNum,:);
        hLine = handle(line(1:length(data2plot),data2plot,...
            'Color',cmap(cellNum+1, :), 'Parent',hAx,'LineWidth',1));
        
        hAx.XLim = [0 length(data2plot)];
        hAx.XTick = [0:50:length(data2plot) ];
        hAx.YLim = [min(data2plot) max(data2plot)];
        
        if ~isempty(legendHandle) % checks if legend has been created previously, destroys if so
            try set(legendHandle,'visible','off');
                legendHandle =[];
                
            catch ME
                return
            end
        end
        
    case 'dF/F_FISSA'
        data2plot = experimentStructure.extractedDF_FISSA(cellNum,:);
        hLine = handle(line(1:length(data2plot),data2plot,...
            'Color',cmap(cellNum+1, :), 'Parent',hAx,'LineWidth',1));
        
        hAx.XLim = [0 length(data2plot)];
        hAx.XTick = [0:50:length(data2plot) ];
        hAx.YLim = [min(data2plot) max(data2plot)];
        
        if ~isempty(legendHandle) % checks if legend has been created previously, destroys if so
            try set(legendHandle,'visible','off');
                legendHandle =[];
                
            catch ME
                return
            end
        end
        
    case 'mean Cnd dF/F_FISSA'
        data2plot = experimentStructure.extractedDFperCndMeanFISSA{1,cellNum};
        legendText ={};
        
        % plots each condition at different color and builds legend text
        for i =1:size(experimentStructure.extractedDFperCndMeanFISSA{1,cellNum}, 2)
            
            hLine(numel(hLine)+1) = handle(line(1:size(data2plot,1),data2plot(:,i) ...
                ,'Color',conditionCols(i, :), 'Parent',hAx,'LineWidth',1));
            
            legendText = [legendText {['Condition ' num2str(i)]}];
        end
        hAx.YLim = [min(data2plot(:)) max(data2plot(:))];
        
        xLim = xlim;
        yLim = ylim;
        
        %         hLine(numel(hLine)+1) = handle(rectangle(hAx, 'Position', [experimentStructure.stimOnFrames(1) xLim(1) (experimentStructure.stimOnFrames(2)-experimentStructure.stimOnFrames(1)) yLim(2)], 'FaceColour', [0.5 0.5 0.5]));
        
        patchVertices = [experimentStructure.stimOnFrames(1), yLim(1); ...
            experimentStructure.stimOnFrames(1), yLim(2)+0.5; ...
            experimentStructure.stimOnFrames(2), yLim(2)+0.5; ...
            experimentStructure.stimOnFrames(2), yLim(1)];
        hLine(numel(hLine)+1) = patch( 'vertices', patchVertices, 'faces', [1,2,3,4], 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.5, 'Parent',hAx);
        
        % plots legend
        hAx.XLim = [1 size(data2plot,1)];
        hAx.XTickMode = 'auto';
        legendHandle = legend(hAx,legendText, 'Location', 'southwest', 'TextColor', 'w');
        
    case 'mean dF/F_FISSA'
        data2plot = experimentStructure.extractedDFperCndMeanFISSA{1,cellNum};
        data2plot = mean(data2plot,2);
        
        hLine = handle(line(1:length(data2plot),data2plot,...
            'Color',cmap(cellNum+1, :), 'Parent',hAx,'LineWidth',1));
        
        hAx.XLim = [1 length(data2plot)];
        
        if ~isempty(legendHandle) % checks if legend has been created previously, destroys if so
            try set(legendHandle,'visible','off');
                legendHandle =[];
                
            catch ME
                return
            end
        end
        
        hAx.YLim = [min(data2plot) max(data2plot)];
        xLim = xlim;
        yLim = ylim;
        
        %         hLine(numel(hLine)+1) = handle(rectangle(hAx, 'Position', [experimentStructure.stimOnFrames(1) xLim(1) (experimentStructure.stimOnFrames(2)-experimentStructure.stimOnFrames(1)) yLim(2)]));
        
        patchVertices = [experimentStructure.stimOnFrames(1), yLim(1); ...
            experimentStructure.stimOnFrames(1), yLim(2)+0.5; ...
            experimentStructure.stimOnFrames(2), yLim(2)+0.5; ...
            experimentStructure.stimOnFrames(2), yLim(1)];
        hLine(numel(hLine)+1) = patch( 'vertices', patchVertices, 'faces', [1,2,3,4], 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.5, 'Parent',hAx);
        
        
        
    case 'mean Cnd dF/F_FBS'
        
        %            if ~isempty(hAx.Children)
        %                delete(hAx.Children)
        %            end
        %
        data2plot = experimentStructure.dFperCndMeanFBS{1,cellNum};
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
            
            lineCol = cmap(cellNum+1, :);
            
            errorBars = experimentStructure.dFperCndSTDFBS{1,cellNum}(:,x);
            
            % plot data
            hLine(numel(hLine)+1) = handle(line(xlocations,data2plot(:,x) ...
                ,'Color',lineCol, 'Parent',hAx,'LineWidth',1));
            
            % plot error bars
            hLine(numel(hLine)+1) = handle(line(xlocations,(data2plot(:,x)+errorBars) ...
                ,'Color',lineCol, 'Parent',hAx, 'LineStyle','--'));
            hLine(numel(hLine)+1) = handle(line(xlocations,(data2plot(:,x)-errorBars) ...
                ,'Color',lineCol, 'Parent',hAx, 'LineStyle','--'));
            
            
            
            yMaxVector(x) =  max(data2plot(:,x)+errorBars);
            yMinVector(x) =  min(data2plot(:,x)-errorBars);
        end
        
        xticks(xlocationMid);
        xticklabels([0:45:315 0:45:315]);
        title('Tuning curve');
        ylabel('\DeltaF/F')
        xlabel(sprintf('Stimulus direction (%s)', char(176)));
        axis square;
        
        hAx.XLim = [1 xlocations(end)];
        
        % find y axis lims
        hAx.YLim = [min(yMinVector)-0.2 max(yMaxVector)+0.2];
        
end

% updates 'UserData'
figData.experimentStructure = experimentStructure;
figData.cellNum = cellNum;
figData.cmap = cmap;

set(H.ax,'UserData', figData);

end