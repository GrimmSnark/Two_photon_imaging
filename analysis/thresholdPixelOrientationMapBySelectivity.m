function thresholdPixelOrientationMapBySelectivity(recordingDir)

magSize = 300; % magnification for image viewing
%% Deals with ROI zip file creation and loading and makes neuropil surround ROIs

if contains(recordingDir, 'Raw') % if you specfy the raw folder then it finds the appropriate processed folder
    recordingDirRAW = recordingDir; % sets raw data path
    
    % sets processed data path
    recordingDirProcessed = createSavePath(recordingDir, 1, 1);
    recordingDirProcessed = recordingDirProcessed(1: find(recordingDirProcessed =='\', 2, 'last'));
    
elseif  contains(recordingDir, 'Processed')
    recordingDirProcessed = recordingDir; % sets processed data path
    recordingDirRAW = createRawFromSavePath(recordingDir); % sets raw data path
end

% open all the relevant images for ROI chosing
if exist([recordingDirProcessed 'STD_Stim_Sum.tif'], 'file')
    imageROI = read_Tiffs([recordingDirProcessed 'STD_Stim_Sum.tif'],1);
    
    if exist([recordingDirProcessed 'Pixel Orientation Pref_native_Blue.tif'], 'file')
        pixelPrefBlue = read_Tiffs([recordingDirProcessed 'Pixel Orientation Pref_native_Blue.tif'],1);
    end
    
    if exist([recordingDirProcessed 'Pixel Orientation Selectivity_native_Blue.tif'], 'file')
        pixelSelectivityBlue = read_Tiffs([recordingDirProcessed 'Pixel Orientation Selectivity_native_Blue.tif'],1);
    end
    
    
    
    if exist([recordingDirProcessed 'Pixel Orientation Pref_native_Green.tif'], 'file')
        pixelPrefGreen = read_Tiffs([recordingDirProcessed 'Pixel Orientation Pref_native_Green.tif'],1);
    end
    
    if exist([recordingDirProcessed 'Pixel Orientation Selectivity_native_Green.tif'], 'file')
        pixelSelectivityGreen = read_Tiffs([recordingDirProcessed 'Pixel Orientation Selectivity_native_Green.tif'],1);
    end
    
    
    
    if exist([recordingDirProcessed 'Pixel Orientation Pref_native.tif'], 'file')
        pixelPref = read_Tiffs([recordingDirProcessed 'Pixel Orientation Pref_native.tif'],1);
    end
    
    if exist([recordingDirProcessed 'Pixel Orientation Selectivity_native.tif'], 'file')
        pixelSelectivity = read_Tiffs([recordingDirProcessed 'Pixel Orientation Selectivity_native.tif'],1);
    end
else
    
    firstSubFolder = returnSubFolderList(recordingDirProcessed);
    
    if isempty(preproFolder2Open) % if not otherwise specified chooses the latest preprocessing folder
        preproFolder2Open = length(firstSubFolder);
    end
    
    recordingDirProcessed = [firstSubFolder(preproFolder2Open).folder '\' firstSubFolder(preproFolder2Open).name '\']; % gets analysis subfolder
    
    try
        imageROI = read_Tiffs([recordingDirProcessed 'STD_Stim_Sum.tif'],1);
        
        if exist([recordingDirProcessed 'Pixel Orientation Pref_native_Blue.tif'], 'file')
            pixelPrefBlue = read_Tiffs([recordingDirProcessed 'Pixel Orientation Pref_native_Blue.tif'],1);
        end
        
        if exist([recordingDirProcessed 'Pixel Orientation Selectivity_native_Blue.tif'], 'file')
            pixelSelectivityBlue = read_Tiffs([recordingDirProcessed 'Pixel Orientation Selectivity_native_Blue.tif'],1);
        end
        
        
        
        if exist([recordingDirProcessed 'Pixel Orientation Pref_native_Green.tif'], 'file')
            pixelPrefGreen = read_Tiffs([recordingDirProcessed 'Pixel Orientation Pref_native_Green.tif'],1);
        end
        
        if exist([recordingDirProcessed 'Pixel Orientation Selectivity_native_Green.tif'], 'file')
            pixelSelectivityGreen = read_Tiffs([recordingDirProcessed 'Pixel Orientation Selectivity_native_Green.tif'],1);
        end
        
        
        
        if exist([recordingDirProcessed 'Pixel Orientation Pref_native.tif'], 'file')
            pixelPref = read_Tiffs([recordingDirProcessed 'Pixel Orientation Pref_native.tif'],1);
        end
        
        if exist([recordingDirProcessed 'Pixel Orientation Selectivity_native.tif'], 'file')
            pixelSelectivity = read_Tiffs([recordingDirProcessed 'Pixel Orientation Selectivity_native.tif'],1);
        end
        
    catch
        disp('Average image not found, check filepath or run prepData.m  or prepDataMultiSingle.m on the recording folder')
        return
    end
end


% initalize MIJI and get ROI manager open
intializeMIJ;
% RM = ij.plugin.frame.RoiManager();
% RC = RM.getInstance();
% RC.runCommand('Show All without labels');
% MIJ.run("Cell Magic Wand Tool");


% get image to FIJI
MIJImageROI = MIJ.createImage('ROI_image',imageROI,true); %#ok<NASGU> supressed warning as no need to worry about
WaitSecs(0.2);
ij.IJ.run('Set... ', ['zoom=' num2str(magSize) ' x=10 y=50']);


%create stack for pixel pref stuff
if exist('pixelPrefGreen', 'var')
    
    % orientation pref map stack
    greenImp = ij.IJ.openImage([recordingDirProcessed 'Pixel Orientation Pref_native_Green.tif']);
    greenImpProcess = greenImp.getProcessor();
    blueImp = ij.IJ.openImage([recordingDirProcessed 'Pixel Orientation Pref_native_Blue.tif']);
    blueImpProcess = blueImp.getProcessor();
    
    pixelPrefStack = ij.ImageStack(greenImp.getWidth, greenImp.getHeight);
    pixelPrefStack.addSlice(greenImp.getTitle, greenImpProcess);
    pixelPrefStack.addSlice(blueImp.getTitle, blueImpProcess);
    
    stackImagePlusObj = ij.ImagePlus('Pixel Orientation Stack.tif', pixelPrefStack);
    stackImagePlusObj.show;
    WaitSecs(0.2);
    ij.IJ.run('Set... ', ['zoom=' num2str(magSize) ' x=1000 y=50']);
    
    % selectivity map stack
    greenImpSelectivity = ij.IJ.openImage([recordingDirProcessed 'Pixel Orientation Selectivity_native_Green.tif']);
    greenImpSelectivityProcess = greenImpSelectivity.getProcessor();
    blueImpSelectivity = ij.IJ.openImage([recordingDirProcessed 'Pixel Orientation Selectivity_native_Blue.tif']);
    blueImpSelectivityProcess = blueImpSelectivity.getProcessor();
    
    pixelSelectivityStack = ij.ImageStack(greenImpSelectivity.getWidth, greenImpSelectivity.getHeight);
    pixelSelectivityStack.addSlice(greenImpSelectivity.getTitle, greenImpSelectivityProcess);
    pixelSelectivityStack.addSlice(blueImpSelectivity.getTitle, blueImpSelectivityProcess);
    
    stackImagePlusObjSelectivity = ij.ImagePlus('Pixel Orientation Stack.tif', pixelSelectivityStack);
    stackImagePlusObjSelectivity.show;
    WaitSecs(0.2);
    ij.IJ.run('Set... ', ['zoom=' num2str(magSize) ' x=1000 y=50']);
    
    
elseif exist('pixelPref', 'var')
    % preference map
    Imp = ij.IJ.openImage([recordingDirProcessed 'Pixel Orientation Pref_native.tif']);
    Imp.show;
    WaitSecs(0.2);
    ij.IJ.run('Set... ', ['zoom=' num2str(magSize) ' x=1000 y=50']);
    
    % selectivity map
    ImpSelectivity = ij.IJ.openImage([recordingDirProcessed 'Pixel Orientation Selectivity_native.tif']);
    ImpSelectivity.show;
    WaitSecs(0.2);
    ij.IJ.run('Set... ', ['zoom=' num2str(magSize) ' x=1000 y=50']);
    
end

happy = 0;
while ~happy % loops for a long as you need to if you do not exit or choose continue, ie reset ROI
    response = MFquestdlg([0.5,1],sprintf(['Choose ROI for background subtraction (low selectivity area) \n' ...
        'If you are happy to move on with processing click Continue \n' ...
        'If you want to rechoose another area click Clear All \n' ...
        'Or exit out of this window to exit script']), ...
        'Wait for user to do stuff', ...
        'Continue', ...
        'Clear All', ...
        'Continue');
    
    if isempty(response) || strcmp(response, 'Continue')
        happy =1; % kicks you out of loop if continue or exit
    else
        happy =0;
    end
end

switch response
    
    case ''
        disp('Please restart script'); % if exit, ends script
        return
        
    case 'Continue' % if continue, goes on with analysis
        MIJ.run("Set Measurements...", "area mean standard min redirect=None decimal=3");
        MIJ.run('Measure'); % For each image, this outputs four summary metrics: number of pixels (in roi), mean ROI value, min ROI value, and max ROI value
        RT = MIJ.getResultsTable();
        MIJ.run('Clear Results');
        MIJ.run('Close','');
        ROImean = RT(2);
        ROIstd = RT(3);
        
        % get threshold value
        selectivityThreshold = ROImean + 2*ROIstd;
        
        if exist('pixelPrefGreen', 'var')
            %threshold blue image
            thresholdIndxBlue = find(pixelSelectivityBlue < selectivityThreshold);
            [thresholdIndxBlueSubsI, thresholdIndxBlueSubsJ] = ind2sub(size(pixelSelectivityBlue),thresholdIndxBlue);
            pixelPrefBlueRGB = ind2rgb(pixelPrefBlue, ggb1);
            pixelPrefBlueRGBThres = pixelPrefBlueRGB;
            
            for i = 1:length(thresholdIndxBlueSubsI)
                pixelPrefBlueRGBThres(thresholdIndxBlueSubsI(i),thresholdIndxBlueSubsJ(i),:) = [1,1,1];
            end
            
            % threshold green image
            thresholdIndxGreen = find(pixelSelectivityGreen < selectivityThreshold);
            [thresholdIndxGreenSubsI, thresholdIndxGreenSubsJ] = ind2sub(size(pixelSelectivityGreen),thresholdIndxGreen);
            pixelPrefGreenRGB = ind2rgb(pixelPrefGreen, ggb1);
            pixelPrefGreenRGBThres = pixelPrefGreenRGB;
            
            for i = 1:length(thresholdIndxGreenSubsI)
                pixelPrefGreenRGBThres(thresholdIndxGreenSubsI(i),thresholdIndxGreenSubsJ(i),:) = [1,1,1];
            end
            
            imwrite(pixelPrefBlueRGBThres, [recordingDirProcessed ' Thresholded Orientation Pixel Map Blue.tif']);
            imwrite(pixelPrefGreenRGBThres, [recordingDirProcessed ' Thresholded Orientation Pixel Map Green.tif']);
        else
            %threshold blue image
            thresholdIndx = find(pixelSelectivity < selectivityThreshold);
            [thresholdIndxSubsI, thresholdIndxSubsJ] = ind2sub(size(pixelSelectivity),thresholdIndx);
            pixelPrefRGB = ind2rgb(pixelPref, ggb1);
            pixelPrefRGBThres = pixelPrefRGB;
            
            for i = 1:length(thresholdIndxSubsI)
                pixelPrefRGBThres(thresholdIndxSubsI(i),thresholdIndxSubsJ(i),:) = [1,1,1];
            end
            
             imwrite(pixelPrefRGBThres, [recordingDirProcessed ' Thresholded Orientation Pixel Map.tif']);
        end
end

close all
MIJ.closeAllWindows



end