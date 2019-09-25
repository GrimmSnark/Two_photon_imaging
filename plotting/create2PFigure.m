function create2PFigure(experimentStructure, channel2Use)
% Creates interactive calcium trace plot viewer for quick look at the
% recording data
% Input:  experimentStructure - either experimentStructure structure or data folder path
%                which contains experimentStructure.mat
%         channel2Use - Channel to use for multichannel recording
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

% set the channel to use if left blank
if nargin<2 || isempty(channel2Use)
    channel2Use = 2;
end

%% get data to plot

% check if dataDir is an actual experiment structure and load in
% appropriately

if ~isstruct(experimentStructure)
    try
        load(experimentStructure);
    catch
        load([experimentStructure 'experimentStructure.mat']);
    end
end

% load in average image
try
    displayIm = read_Tiffs([experimentStructure.savePath 'STD_Stim_Sum.tif']);
catch
    displayIm = read_Tiffs([experimentStructure.savePath 'STD_Stim_Sum_Ch' num2str(channel2Use) '.tif']);
end

%% Start plot set up
[H.im, H.ax, cmap] = createPatchFig(experimentStructure.labeledCellROI, displayIm);
% H.im = handle(imagesc(experimentStructure.labeledCellROI)); % plots image and gets handle
%  H.ax = handle(gca); % gets axis handle
H.fig = handle(gcf); % gets figure handle


% sets a variety of figure display properties
set(H.ax,...
    'xlimmode','manual',...
    'ylimmode','manual',...
    'zlimmode','manual',...
    'alimmode','manual',...
    'XGrid','off',...
    'YGrid','off',...
    'Visible','on',...
    'Clipping','off',...
    'YDir','reverse',...
    'Units','normalized',...
    'DataAspectRatio',[1 1 1]);

% sets callback functions
H.ax.ButtonDownFcn = @(src,evnt)plotMouseClick(experimentStructure,src,evnt,cmap);
H.fig.KeyPressFcn = @(src,evnt)plotButtonControl(experimentStructure,src,evnt,cmap);

% default choice for plotting
figData.plotChoice = 'mean Cnd dF/F_FBS';
figData.experimentStructure = experimentStructure;
figData.cmap = cmap;
set(H.fig,'UserData', figData);

traceMenu = uimenu('Text', 'Type of Trace Plotted');

H.traceButtonHandles(1) = uimenu(traceMenu, 'Text', 'rawF', 'callback', @(src,evnt)tracePlotChoice(src,evnt));
H.traceButtonHandles(2) = uimenu(traceMenu, 'Text', 'dF/F', 'callback', @(src,evnt)tracePlotChoice(src,evnt));
H.traceButtonHandles(3) = uimenu(traceMenu, 'Text', 'mean Cnd dF/F', 'callback', @(src,evnt)tracePlotChoice(src, evnt));
H.traceButtonHandles(4) = uimenu(traceMenu, 'Text', 'mean dF/F', 'callback', @(src,evnt)tracePlotChoice(src, evnt));

H.traceButtonHandles(5) = uimenu(traceMenu, 'Text', 'mean Cnd dF/F_FBS', 'Checked', 'on', 'callback', @(src,evnt)tracePlotChoice(src, evnt));


end