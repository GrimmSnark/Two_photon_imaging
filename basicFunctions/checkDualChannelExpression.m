function checkDualChannelExpression(recordingDir, channel2Check)



try
    MIJ.closeAllWindows;
catch
    
end

% load in pointers to ROI manager
try
    RM = ij.plugin.frame.RoiManager();
    RC = RM.getInstance();
catch
    intializeMIJ;
    RM = ij.plugin.frame.RoiManager();
    RC = RM.getInstance();
end

% load in ROI file
if exist([recordingDir 'ROIcells.zip'], 'file') % if zip file actually exists
    RC.runCommand('Open', [recordingDir 'ROIcells.zip']); % opens zip file
    ROInumber = RC.getCount();
    disp(['You have selected ' num2str(ROInumber) ' ROIs, moving onto analysis']);
    
    recordingDirProcessed = recordingDir;
    
else%if does not exist
    
    firstSubFolder = returnSubFolderList(recordingDir);
    
    recordingDirProcessed = [firstSubFolder(end).folder '\' firstSubFolder(end).name '\']; % gets analysis subfolder
    
    RC.runCommand('Open', [recordingDirProcessed 'ROIcells.zip']); % opens zip file
    ROInumber = RC.getCount();
    disp(['You have selected ' num2str(ROInumber) ' ROIs, moving onto analysis']);
end

% load experimentStructure
load([recordingDirProcessed 'experimentStructure.mat']);


% get image to check for coexpression
image = read_Tiffs([experimentStructure.savePath 'Average_Ch' num2str(channel2Check) '.tif']);

imageMean = mean(image(:));
imageStd = std(imageMean);

threshold = imageMean + imageStd;

% transfers to FIJI
channel2CheckFIJI = MIJ.createImage( 'Channel to Check', image,true);

% create neuropil ROIs
generateNeuropilROIs(RC.getRoisAsArray,(experimentStructure.averageROIRadius*3)); % generates neuropil surround ROIs

% get pixel values for cells and neuropil
for x = 1:experimentStructure.cellCount
    % Select cell ROI in ImageJ
    fprintf('Processing Cell %d\n',x)
    
    % Get cell ROI name and parse out (X,Y) coordinates
    currentROI = RC.getRoi(x-1);
    pointsROI = currentROI.getContainedPoints;
    
    
    for isNeuropilROI = 0:1
        
        pointsROI = currentROI.getContainedPoints;
        pixelValues = [];
        for cc = 1:length(pointsROI)
            pixelValues(cc,:) = channel2CheckFIJI.getPixel(pointsROI(cc).x, pointsROI(cc).y) ;
        end
        
        pixelValues = pixelValues(:,1);
        
        if isNeuropilROI
            neuropilPixels{x} = pixelValues;
            neuropilPixelsMean(x) = mean(pixelValues);
            neuropilPixelsStd(x) = std(pixelValues);
        else
            cellPixels{x} = pixelValues;
            cellPixelsMean(x) = mean(pixelValues);
            currentROI = RC.getRoi(x-1 +experimentStructure.cellCount ); % Now select the associated neuropil ROI
        end
    end
end


% for each cell/neuropil pair check if signficantly different
cellIdent = zeros(size(cellPixelsMean));
for d = 1:experimentStructure.cellCount
%     if cellPixelsMean(d) > (neuropilPixelsMean(d) + 2*neuropilPixelsStd(d))
    if cellPixelsMean(d) > 2*neuropilPixelsMean(d) - neuropilPixelsStd(d)
        cellIdent(d) = 1;
    end
    %     prob(d) = ranksum(cellPixels{d},neuropilPixels{d});
end

cellIdent = cellIdent';

experimentStructure.PVCellIndent = cellIdent;

MIJ.closeAllWindows;

%% Save the updated experimentStructure
save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure');

end