function processPixels(roiChosen, padSize, MIJImageROI, registeredVolMIJI, experimentStructure)

close all
pixelLineAnalysis =[];
pixelCoordinates=[];
brightnessPerPixel = [];
zProfilesPerPixel =[];

RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();

%% choose ROI or pixel to examine
roiObjects = RC.getRoisAsArray;
%   roiChosen = 77;

pixelCoordinatesObjs = roiObjects(roiChosen).getContainedPoints();
pixelCoordinates(:,1)= arrayfun(@getX,pixelCoordinatesObjs);
pixelCoordinates(:,2)= arrayfun(@getY,pixelCoordinatesObjs);

%get processor for std avaerage image
processorObject = MIJImageROI.getProcessor();

% get the brightnesses for each pixel in ROI
for i =1:length(pixelCoordinates)
    brightnessPerPixel(i) = processorObject.getf(pixelCoordinates(i,1),pixelCoordinates(i,2));
end

%sort the pixels by brightness and cutoff 1/2
[sortedPixelValues, sortedPixelValueIndxs] = sort(brightnessPerPixel);
% cutoff = ceil(length(sortedPixelValueIndxs)/2);
cutoff = length(sortedPixelValueIndxs);

pixelCoordinatesSorted = pixelCoordinates(sortedPixelValueIndxs,:);
pixelCoordinatesSortedCutoff = pixelCoordinatesSorted(cutoff:end,:);
sortedPixelValuesCutoff = sortedPixelValues(cutoff:end);

%get pixels in horzonytal line with brightest with ROI
pixelInLine = pixelCoordinates(pixelCoordinates(:,2)== pixelCoordinatesSortedCutoff(1,2),:);

% pad 2 pixels either side
padStart = pixelInLine(1, 1) - padSize;
padEnd = pixelInLine(end,1) + padSize;

pixelLineAnalysis = padStart: padEnd;
pixelLineAnalysis = [pixelLineAnalysis' ones(length(pixelLineAnalysis),1)*pixelInLine(1,2)];


% Get ROI key image
roiImage = experimentStructure.labeledCellROI + experimentStructure.labeledNeuropilROI(1:experimentStructure.pixelsPerLine, 1:experimentStructure.pixelsPerLine);
roiImage(roiImage>0) =1;

% work out colormap
cmap = jet(length(pixelLineAnalysis)+3);
%cmap = colormap(jet);
cmap(1,:) = [0,0,0];
cmap(2,:) = [1,1,1];
cmap = [0,0,0;1,1,1;cmap];
%  colormap(cmap);

%get brightness across line
for x=1:length(pixelLineAnalysis)
    linePixelBrightness(x) = processorObject.getPixelValue(pixelLineAnalysis(x,1), pixelLineAnalysis(x,2));
end

[rankedLineBrightness, rankedLineBrightnessIndx] = sort(linePixelBrightness);

for q =1:length(pixelLineAnalysis)
    roiImage(pixelLineAnalysis(rankedLineBrightnessIndx(q),2),pixelLineAnalysis(rankedLineBrightnessIndx(q),1)) = q+4;
end

% Get z profiles for specified pixels
for v=1:length(pixelLineAnalysis)
    registeredVolMIJI.setRoi(pixelLineAnalysis(v,1), pixelLineAnalysis(v,2),1,1);
    
    plotF = ij.plugin.ZAxisProfiler.getPlot(registeredVolMIJI);
    RT(:,1) = plotF.getXValues();
    RT(:,2) = plotF.getYValues();
    zProfilesPerPixel(v,:)= RT(:,2);
end

% split out traces into means per cnd

for p = 1:size(zProfilesPerPixel,1) % for each pixel
    for  x =1:length(experimentStructure.cndTotal) % for each condition
        if any(experimentStructure.cndTotal(x)) % checks if there are any trials of that type
            for y =1:length(experimentStructure.cndTrials{x}) % for each trial of that type
                
                currentTrial = experimentStructure.cndTrials{x}(y); % gets current trial number for that cnd
                
                preStimWindowF{p}{y,x} = zProfilesPerPixel(p,experimentStructure.EventFrameIndx.PRESTIM_ON(currentTrial):experimentStructure.EventFrameIndx.PRESTIM_OFF(currentTrial));
                
                preStimWindowAverageF{p}(y,x) = mean(preStimWindowF{p}{y,x});
                
                % stim response and average response per cell x cnd x trial
                
                stimWindowF{p}{y,x} = zProfilesPerPixel(p,experimentStructure.EventFrameIndx.STIM_ON(currentTrial):experimentStructure.EventFrameIndx.STIM_OFF(currentTrial));
                stimWindowAverageF{p}(y,x) = mean(stimWindowF{p}{y,x});
                
            end
        end
    end
end

for d =1:length(stimWindowAverageF)
    preStimeWindowMeanF(:,d) = mean(preStimWindowAverageF{d},1);
    stimWindowMeanF(:,d) = mean(stimWindowAverageF{d},1);
end

%% start plotting stuff
H.im = handle(imagesc(roiImage)); % plots image and gets handle
H.ax = handle(gca); % gets axis handle
H.fig = handle(gcf); % gets figure handle

colormap(cmap);

set(H.ax,...
    'xlimmode','manual',...
    'ylimmode','manual',...
    'zlimmode','manual',...
    'alimmode','manual',...
    'XGrid','off',...
    'YGrid','off',...
    'Visible','off',...
    'Clipping','on',...
    'YDir','reverse',...
    'Units','normalized',...
    'DataAspectRatio',[1 1 1]);

if (experimentStructure.xPos(roiChosen)-10) < (pixelLineAnalysis(1,1) -3) || (experimentStructure.xPos(roiChosen)+10) > (pixelLineAnalysis(end,1) +3)
    
    H.ax.YLim = [(experimentStructure.yPos(roiChosen)-10) (experimentStructure.yPos(roiChosen)+10)]
    H.ax.XLim = [(experimentStructure.xPos(roiChosen)-10) (experimentStructure.xPos(roiChosen)+10)]
else
    newBoundary = (pixelLineAnalysis(end,1) +3)- experimentStructure.xPos(roiChosen);
    H.ax.YLim = [(experimentStructure.yPos(roiChosen)-newBoundary) (experimentStructure.yPos(roiChosen)+newBoundary)]
    H.ax.XLim = [(experimentStructure.xPos(roiChosen)-newBoundary) (experimentStructure.xPos(roiChosen)+newBoundary)]
    
end


%% Set up new axis for trace plotting

% sets subplot percentage coverages
sz = get(0,'ScreenSize');
hp = .30;
vp = .5625;

% creates subplot for trace
hFig = H.fig;
if sz(4) > sz(3) % (vertical)
    H.ax.Position = [0 0 1 vp];
else				% (horizontal)
    H.ax.Position = [0 0 hp 1];
end

if sz(4) > sz(3) % (vertical)
    p = vp+.005;
    hAx = handle(axes('Position',[.02, p, .98, .995-p],'Parent',hFig));
else				% (horizontal)
    p = hp;
    hAx = handle(axes('Position',[p+0.02, .03, .975-p, .96],'Parent',hFig));  % (left, bottom, right, top)
end

set(hAx, 'color', 'k'); % sets background to black

hLine =[];
for i =1:size(zProfilesPerPixel,1) % for each pixel
    
    hLine(numel(hLine)+1) = handle(line(1:size(stimWindowMeanF,1),stimWindowMeanF(:,rankedLineBrightnessIndx(i)) ...
        ,'Color',cmap(i+5, :), 'Parent',hAx,'LineWidth',1));
    
    %             legendText = [legendText {['Condition ' num2str(i)]}];
end

xticklabels(0:45:315);

end
