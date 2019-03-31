function create2PFigure(experimentStructure,channel2Use)
% Creates interactive calcium trace plot viewer for quick look at the
% recording data
% Input - experiementStructure or grandStructure from
%         runMijiROIBasedAnalysis
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

% set the channel to use if left blank
if nargin<2 || isempty(channel2Use)
    channel2Use = 2;
end
%% set global variables
global H % figure handle
global zoomlevel % magnfication level for plot

zoomlevel =1; % resets level to standard for each instance of plot

%% Start plot set up

% load in average image
try
    STD_Stim_Sum = read_Tiffs([experimentStructure.savePath 'STD_Stim_Sum.tif']);
catch
    STD_Stim_Sum = read_Tiffs([experimentStructure.savePath 'STD_Stim_Sum_Ch' num2str(channel2Use) '.tif']);
end

figure
imshow(STD_Stim_Sum); % plots image and gets handle

hold on
imageROI =experimentStructure.labeledCellROI;

% get ROI image overlay
cmap = distinguishable_colors(experimentStructure.cellCount+1,'k');
imageROIRGB = ind2rgb(imageROI,cmap(2:end,:));
imageROIRGBHandle = imshow(imageROIRGB);

% set overlay alpha values
alphaVals = imageROI;
alphaVals(alphaVals>0) =0.3;
set(imageROIRGBHandle,'AlphaData',alphaVals);

H.im = imageROIRGBHandle;
H.ax = handle(gca); % gets axis handle
H.fig = handle(gcf); % gets figure handle

hold off


% H.im = handle(imagesc(experimentStructure.labeledCellROI)); 
% H.ax = handle(gca); % gets axis handle
% H.fig = handle(gcf); % gets figure handle
% 
% % sets color map for the cell ROIs
% cmap = distinguishable_colors(experimentStructure.cellCount+1,'k');
% cmap(1,:) = [0,0,0];
% colormap(H.ax,cmap)

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
H.im.ButtonDownFcn = @(src,evnt)plotMouseClick(experimentStructure,src,evnt,cmap);
H.fig.KeyPressFcn = @(src,evnt)plotButtonControl(experimentStructure,src,evnt,cmap);

figData.plotChoice = 'mean Cnd dF/F';
figData.experimentStructure = experimentStructure;
figData.cmap = cmap;
set(H.ax,'UserData', figData);

traceMenu = uimenu('Text', 'Type of Trace Plotted');

H.traceButtonHandles(1) = uimenu(traceMenu, 'Text', 'rawF', 'callback', @(src,evnt)tracePlotChoice(src,evnt));
H.traceButtonHandles(2) = uimenu(traceMenu, 'Text', 'dF/F', 'callback', @(src,evnt)tracePlotChoice(src,evnt));
H.traceButtonHandles(3) = uimenu(traceMenu, 'Text', 'mean Cnd dF/F', 'Checked', 'on', 'callback', @(src,evnt)tracePlotChoice(src, evnt));

H.traceButtonHandles(4) = uimenu(traceMenu, 'Text', 'mean Cnd dF/F_FBS', 'callback', @(src,evnt)tracePlotChoice(src, evnt));

% H.traceButtonHandles(4) = uimenu(traceMenu, 'Text', 'mean dF/F', 'callback', @(src,evnt)tracePlotChoice(src, evnt));
% H.traceButtonHandles(5) = uimenu(traceMenu, 'Text', 'rawF_FISSA', 'callback', @(src,evnt)tracePlotChoice(src,evnt));
% H.traceButtonHandles(6) = uimenu(traceMenu, 'Text', 'dF/F_FISSA', 'callback', @(src,evnt)tracePlotChoice(src,evnt));
% H.traceButtonHandles(7) = uimenu(traceMenu, 'Text', 'mean Cnd dF/F_FISSA', 'callback', @(src,evnt)tracePlotChoice(src, evnt));
% H.traceButtonHandles(8) = uimenu(traceMenu, 'Text', 'mean dF/F_FISSA', 'callback', @(src,evnt)tracePlotChoice(src, evnt));



 end