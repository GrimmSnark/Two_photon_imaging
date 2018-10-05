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
        hLine(numel(hLine)+1) = patch( 'vertices', patchVertices, 'faces', [1,2,3,4], 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.5);
        
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
        hLine(numel(hLine)+1) = patch( 'vertices', patchVertices, 'faces', [1,2,3,4], 'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.5);
        
        
end

% updates 'UserData'
figData.experimentStructure = experimentStructure;
figData.cellNum = cellNum;
figData.cmap = cmap;

set(H.ax,'UserData', figData);

end