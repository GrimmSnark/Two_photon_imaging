function create2PFigureV2(dataDir)
% Creates interactive calcium trace plot viewer for quick look at the
% recording data
% Input - experiementStructure or grandStructure from
%         runMijiROIBasedAnalysis
%
% Controls:  left click on ROI - brings up trace
%            middle click - resets trace view
%            right click - mulitiple clicks displays multi-ROI traces
%
%            left arrow - iterates down through traces            
%            right arrow - iterates up through traces
%            up arrow - increases cell image ROI magnification
%            down arrow - decreases cell image ROI magnfication
%            space bar - opens up dialog box for choosing specific cell
%            numbers


%% set global variables
global H % figure handle
global zoomlevel % magnfication level for plot

zoomlevel =1; % resets level to standard for each instance of plot

%% get data to plaot
load([dataDir 'experimentStructure.mat']);
displayIm = read_Tiffs([dataDir 'STD_Stim_Sum.tif']);

%% Start plot set up
[H.im, H.ax, cmap] = createPatchFig(experimentStructure.labeledCellROI, displayIm);
% H.im = handle(imagesc(experimentStructure.labeledCellROI)); % plots image and gets handle
% H.ax = handle(gca); % gets axis handle
H.fig = handle(gcf); % gets figure handle


% sets a variety of figure display properties
set(H.ax,...
    'xlimmode','manual',...
    'ylimmode','manual',...
    'zlimmode','manual',...
    'alimmode','manual',...
    'XGrid','off',...
    'YGrid','off',...
    'Visible','off',...
    'Clipping','off',...
    'YDir','reverse',...
    'Units','normalized',...
    'DataAspectRatio',[1 1 1]);

% sets callback functions
H.ax.ButtonDownFcn = @(src,evnt)plotMouseClick(experimentStructure,src,evnt,cmap);
H.fig.KeyPressFcn = @(src,evnt)plotButtonControl(experimentStructure,src,evnt,cmap);

figData.plotChoice = 'dF/F';
figData.experimentStructure = experimentStructure;
figData.cmap = cmap;
set(H.ax,'UserData', figData);

traceMenu = uimenu('Text', 'Type of Trace Plotted');

H.traceButtonHandles(1) = uimenu(traceMenu, 'Text', 'rawF', 'callback', @(src,evnt)tracePlotChoice(src,evnt));
H.traceButtonHandles(2) = uimenu(traceMenu, 'Text', 'dF/F', 'Checked', 'on', 'callback', @(src,evnt)tracePlotChoice(src,evnt));
H.traceButtonHandles(3) = uimenu(traceMenu, 'Text', 'mean Cnd dF/F', 'callback', @(src,evnt)tracePlotChoice(src, evnt));
H.traceButtonHandles(4) = uimenu(traceMenu, 'Text', 'mean dF/F', 'callback', @(src,evnt)tracePlotChoice(src, evnt));



 end