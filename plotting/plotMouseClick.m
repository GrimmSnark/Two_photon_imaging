function plotMouseClick(experimentStructure,src,evnt, cmap)
% Callback function for create2PFigure which deals with mouse clicks
% Inputs: experimentStructure - data structure from runMijiROIBasedAnalysis
%         src - Image source from ButtonDownFcn
%         evnt - click event info: left, right, location etc
%         cmap - color map for display purposes
%
% Controls:  left click on ROI - brings up trace
%            middle click - resets trace view
%            right click - mulitiple clicks displays multi-ROI traces


%% Set and inherit global variables
% I know this is bad practice but it is the easiest way to keep data
% across multiple runs of the call back function...

global hAx
global H
persistent hFig
persistent roiAx
global hTx
global hLine

persistent zoomfactor

if isempty(zoomfactor)
    zoomfactor =4;
end

global zoomlevel


%% RETRIEVE CLICK LOCATION AND DATA TYPE
cp = fliplr(evnt.IntersectionPoint(1:2));
clickPoint = floor(cp);

figData = get(src.Parent,'UserData');
% disp(figData.plotChoice);

%% Set up new axis for trace plotting

% sets subplot percentage coverages
sz = get(0,'ScreenSize');
hp = .30;
vp = .5625;

% creates subplot for trace
if isempty(hFig) || ~isvalid(hFig)
    hFig = src.Parent.Parent;
    roiAx = src.Parent;
    if sz(4) > sz(3) % (vertical)
        roiAx.Position = [0 0 1 vp];
    else				% (horizontal)
        roiAx.Position = [0 0 hp 1];
    end
end

if isempty(hAx) || ~isvalid(hAx)
    if sz(4) > sz(3) % (vertical)
        p = vp+.005;
        hAx = handle(axes('Position',[.02, p, .98, .995-p],'Parent',hFig));
    else				% (horizontal)
        p = hp;
        hAx = handle(axes('Position',[p+0.02, .03, .975-p, .96],'Parent',hFig)); % (left, bottom, right, top)
    end
end

set(hAx, 'color', 'k'); % sets background to black
%% Handle click events

switch evnt.Button
    
    case 1 % Left Button PLOT SINGLE TRACE
        
        % figure out which cell the click was on
        indxClick = sub2ind([experimentStructure.pixelsPerLine experimentStructure.linesPerFrame], clickPoint(1), clickPoint(2));
        cellNum = experimentStructure.labeledCellROI(indxClick);
        
        % if on background then sets to first cell
        if cellNum == 0
            cellNum =1;
        end
        
        % trys to clear previous trace if exists
        if ~isempty(hLine)
            try
                delete(hLine)
                hLine = [];
            catch me
                hLine = [];
            end
        end
        
        % plots new traces
        plotCaTraces(cellNum, experimentStructure, figData, cmap);
        
        % Need to modify above to show in seconds....
        
        %         hLine = handle(line((1:numel(obj(k).Trace))./fps, obj(k).Trace,...
        %             'Color',cmap(cellNum+1), 'Parent',hAx,'LineWidth',1));
        %
        set(hFig, 'HandleVisibility', 'callback');
        
        % trys to clear previous cell number on image
        try
            delete(hTx)
            hTx = [];
        catch me
            delete(findobj(roiAx, 'type', 'text'))
            hTx = [];
        end
        
        % plots new cell number
        hTx = handle(text(...
            'String', sprintf('%i',cellNum),...
            'FontWeight','bold',...
            'BackgroundColor',[.1 .1 .1 .3],...
            'Margin',1,...
            'Position', round([experimentStructure.yPos(cellNum) experimentStructure.xPos(cellNum)]) - [0 5],...
            'Parent', src.Parent,...
            'Color',cmap(cellNum+1, :)));
        
        % sets figure user data for next time around
         figData = get(H.ax, 'UserData');
        figData.hTx = hTx;
        figData.cellNum = cellNum;
        set(H.ax,'UserData', figData);
        
        % if the magnifcation factor is greater than 1, then shifts cell
        % image view to centralize current cell
        if zoomlevel >1
            shiftCellImageView([experimentStructure.yPos(cellNum) experimentStructure.xPos(cellNum)], H.ax);
        end
        
    case 2 % Middle button RESET PLOTS
        
        % Remove Plot
        if ~isempty(hAx) && isvalid(hAx)
            cla(hAx);
        end
        hLine = [];
        % Remove Text
        try
            delete(hTx)
            hTx = [];
        catch me
            delete(findobj(roiAx, 'type', 'text'))
            hTx = [];
        end
        
    case 3 % Right Button MULTI-TRACE
        
        % figure out which cell the click was on
        indxClick = sub2ind([experimentStructure.pixelsPerLine experimentStructure.linesPerFrame], clickPoint(1), clickPoint(2));
        cellNum = experimentStructure.labeledCellROI(indxClick);
        
        % if on background then sets to first cell
        if cellNum == 0
            cellNum =1;
        end
        
        % plots new traces
        set(hAx, 'NextPlot','add')
        hLine(numel(hLine)+1) = handle(line(1:length(data2plot(cellNum,:)), ...
            data2plot(cellNum,:),'Color',cmap(cellNum+1, :), 'Parent',hAx,'LineWidth',1));
        
        
        % Need to modify above to show in seconds....
        
        %         hLine = handle(line((1:numel(obj(k).Trace))./fps, obj(k).Trace,...
        %             'Color',cmap(cellNum+1), 'Parent',hAx,'LineWidth',1));
        %
        set(hFig, 'HandleVisibility', 'callback');
        
        % Add Text
        hTx(numel(hTx)+1) = handle(text(...
            'String', sprintf('%i',cellNum),...
            'FontWeight','bold',...
            'BackgroundColor',[.1 .1 .1 .3],...
            'Margin',1,...
            'Position', round([experimentStructure.yPos(cellNum) experimentStructure.xPos(cellNum)]) - [0 5],...
            'Parent', src.Parent,...
            'Color',cmap(cellNum+1, :)));
        % sets figure user data for next time around
         figData = get(H.ax, 'UserData');
        figData.hTx = hTx;
        figData.cellNum = cellNum;
        set(H.ax,'UserData', figData);
        
end

end