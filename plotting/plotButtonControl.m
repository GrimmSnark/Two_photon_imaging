function plotButtonControl(experimentStructure,src,evnt,cmap)
% Callback function for create2PFigure which deals with key presses
% Inputs: experimentStructure - data structure from runMijiROIBasedAnalysis
%         src - Image source from ButtonDownFcn
%         evnt - click event info: left, right, location etc
%         cmap - color map for display purposes
%
% Controls: left arrow - iterates down through traces
%           right arrow - iterates up through traces
%           up arrow - increases cell image ROI magnification
%           down arrow - decreases cell image ROI magnfication
%           space bar - opens up dialog box for choosing specific cell
%           numbers

%% Set and inherit global variables
% I know this is bad practice but it is the easiest way to keep data
% across multiple runs of the call back function...

global hAx
persistent hFig
persistent roiAx
global  hTx
global hLine
global H

persistent zoomfactor

if isempty(zoomfactor)
    zoomfactor =4;
end

global zoomlevel

%% Set up new axis for trace plotting

% sets subplot percentage coverages
sz = get(0,'ScreenSize');
hp = .30;
vp = .5625;

% creates subplot for trace
if isempty(hFig) || ~isvalid(hFig)
    hFig = src;
    roiAx = src.Children(end);
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
        hAx = handle(axes('Position',[p+0.02, .03, .975-p, .96],'Parent',hFig));  % (left, bottom, right, top)
    end
end

set(hAx, 'color', 'k'); % sets background to black
%% Get last cell number selected
figData = get(src.Children(end), 'UserData');
if  ~isfield(figData, 'hTx')
    cellNum = 1;
else
    cellNum = str2double(figData.hTx(end).String);
    
end
%% Handle key presses

switch evnt.Key
    case 'space' % CHOOSE TRACES TO PLOT
        
        % Sets up dialog box
        prompt = {'Enter desired trace numbers:'};
        dlg_title = 'Trace No. Inputs';
        num_lines = 1;
        defaultans = {'1'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        answer = str2num(answer{1,1});
        cellNum = answer;
        
        % deals with input answer
        if length(cellNum)==1 % if single trace
            multiclickFlag =0;
            
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
            
            set(hFig, 'HandleVisibility', 'callback')
            
            % trys to clear previous cell number on image
            try
                delete(hTx)
                hTx = [];
            catch me
                delete(findobj(roiAx, 'type', 'text'))
                hTx = [];
            end
            hTx = handle(text(...
                'String', sprintf('%i',cellNum),...
                'FontWeight','bold',...
                'BackgroundColor',[.1 .1 .1 .3],...
                'Margin',1,...
                'Position', round([experimentStructure.yPos(cellNum) experimentStructure.xPos(cellNum)]) - [0 5],...
                'Parent', src.Parent,...
                'Color',cmap(cellNum+1, :)));
            
            % if the magnifcation factor is greater than 1, then shifts cell
            % image view to centralize current cell
            if zoomlevel >1
                shiftCellImageView(obj(cellNum), patchFigAx);
            end
            
        elseif size(cellNum)>1 % if more than one cell selected
            
            for x = 1:length(cellNum) % runs through each cell
                
                set(hAx, 'NextPlot','add')
                hLine(numel(hLine)+1) = handle(line(1:length(experimentStructure.dF(cellNum,:)), ...
                    experimentStructure.dF(cellNum,:),'Color',cmap(cellNum+1, :), 'Parent',hAx,'LineWidth',1));
                
                
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
            end
        end
        
    case 'leftarrow' % CYCLE DOWN THROUGH TRACES
        
        cellNum=cellNum-1; % iterates down one cell
        
        if cellNum<1 % unless cell is 1
            cellNum= 1;
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
        
        set(hFig, 'HandleVisibility', 'callback')
        
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
            'Parent', src.Children(end),...
            'Color',cmap(cellNum+1, :)));
        
        % if the magnifcation factor is greater than 1, then shifts cell
        % image view to centralize current cell
        if zoomlevel >1
            shiftCellImageView([experimentStructure.yPos(cellNum) experimentStructure.xPos(cellNum)], H.ax);
        end
        
        % sets figure user data for next time around
        figData = get(H.ax, 'UserData');
        figData.hTx = hTx;
        figData.cellNum = cellNum;
        set(H.ax,'UserData', figData);
        
        
    case 'rightarrow' %CYCLE UP THROUGH TRACES
        
        cellNum=cellNum+1; % iterates up one cell
        
        if cellNum>=size(experimentStructure.dF,1) % unless at max cell num
            cellNum= size(experimentStructure.dF,1);
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
        
        set(hFig, 'HandleVisibility', 'callback')
        
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
            'Parent', src.Children(end),...
            'Color',cmap(cellNum+1, :)));
        
        % if the magnifcation factor is greater than 1, then shifts cell
        % image view to centralize current cell
        if zoomlevel >1
            shiftCellImageView([experimentStructure.yPos(cellNum) experimentStructure.xPos(cellNum)], H.ax);
        end
        
        % sets figure user data for next time around
        figData = get(H.ax, 'UserData');
        figData.hTx = hTx;
        figData.cellNum = cellNum;
        set(H.ax,'UserData', figData);
        
    case 'uparrow' %INCREASE IMAGE ZOOM
        
        zoomlevel = 2;
        % magnifys cell image view
        magnifyCellPic([experimentStructure.xPos(cellNum) experimentStructure.yPos(cellNum)], zoomfactor, zoomlevel, H.ax, experimentStructure);
        
    case 'downarrow' % DECREASE IMAGE ZOOM
        
        zoomlevel = 1;
        % demagnifys cell image view
        magnifyCellPic([experimentStructure.xPos(cellNum) experimentStructure.yPos(cellNum)], zoomfactor, zoomlevel, H.ax, experimentStructure);
        
end

end