function thresholdPixelOrientationMapBySelectivityMonkey(recordingDir, noColor, channel2Use)

magSize = 300; % magnification for image viewing

if nargin < 4|| isempty(channel2Use)
    channel2Use = 2; % sets up deafult channel to use for multi-channel images
end

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

%%% TO DO: Add in different channel handling

% % check number of channels in imaging stack
% channelIndxStart = strfind(experimentStructure.filenamesFrame{1}, '_Ch');
% for i =1:length(experimentStructure.filenamesFrame)
%     channelIdentity{i} = experimentStructure.filenamesFrame{i}(channelIndxStart:channelIndxStart+3);
% end
% channelNo = unique(channelIdentity);
%
%
% if length(channelNo)>1
%     channelIndentifer = channelNo{channel2Use};
%     data2Use = [data2Use channelIndentifer];
%     disp(['Using Channel '  num2str(channel2Use) ' for  calculation']);
% end


% open all the relevant images for ROI chosing
if exist([recordingDirProcessed 'STD_Stim_Sum.tif'], 'file')
    imageROI = read_Tiffs([recordingDirProcessed 'STD_Stim_Sum.tif'],1);
    
    for ee = 1:noColor
        pixelSelectivity(:,:,ee) = read_Tiffs([recordingDirProcessed 'Pixel Orientation Selectivity_native_Color_' num2str(ee) '.tif'],1);
        pixelPref(:,:,ee) = read_Tiffs([recordingDirProcessed 'Pixel Orientation Pref_native_Color_' num2str(ee) '.tif'],1);
    end
else
    
    firstSubFolder = returnSubFolderList(recordingDirProcessed);
    
    if isempty(preproFolder2Open) % if not otherwise specified chooses the latest preprocessing folder
        preproFolder2Open = length(firstSubFolder);
    end
    
    recordingDirProcessed = [firstSubFolder(preproFolder2Open).folder '\' firstSubFolder(preproFolder2Open).name '\']; % gets analysis subfolder
    
    try
        imageROI = read_Tiffs([recordingDirProcessed 'STD_Stim_Sum.tif'],1);
        
        for ee = 1:noColor
            pixelSelectivity(:,:,ee) = read_Tiffs([recordingDirProcessed 'Pixel Orientation Selectivity_native_Color_' num2str(ee) '.tif'],1);
            pixelPref(:,:,ee) = read_Tiffs([recordingDirProcessed 'Pixel Orientation Pref_native_Color_' num2str(ee) '.tif'],1);
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



for q = 1:noColor
    
    % get image to FIJI
    MIJImageROI = MIJ.createImage('ROI_image',imageROI,true); %#ok<NASGU> supressed warning as no need to worry about
    WaitSecs(0.2);
    ij.IJ.run('Set... ', ['zoom=' num2str(magSize) ' x=10 y=50']);
    
    % preference map
    Imp = ij.IJ.openImage([recordingDirProcessed 'Pixel Orientation Pref_native_Color_' num2str(q) '.tif']);
    Imp.show;
    WaitSecs(0.2);
    ij.IJ.run('Set... ', ['zoom=' num2str(magSize) ' x=1000 y=50']);
    
    % selectivity map
    ImpSelectivity = ij.IJ.openImage([recordingDirProcessed 'Pixel Orientation Selectivity_native_Color_' num2str(q) '.tif']);
    ImpSelectivity.show;
    WaitSecs(0.2);
    ij.IJ.run('Set... ', ['zoom=' num2str(magSize) ' x=1000 y=50']);
    
    
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
            
            %threshold blue image
            thresholdIndx = find(pixelSelectivity(:,:,q) < selectivityThreshold);
            [thresholdIndxSubsI, thresholdIndxSubsJ] = ind2sub(size(pixelSelectivity(:,:,q)),thresholdIndx);
            pixelPrefRGB = ind2rgb(pixelPref(:,:,q), ggb1);
            pixelPrefRGBThres = pixelPrefRGB;
            
            for i = 1:length(thresholdIndxSubsI)
                pixelPrefRGBThres(thresholdIndxSubsI(i),thresholdIndxSubsJ(i),:) = [1,1,1];
            end
            
            imwrite(pixelPrefRGBThres, [recordingDirProcessed ' Thresholded Orientation Pixel Map_Color_' num2str(q) '.tif']);
    end
    
    close all
    MIJ.closeAllWindows
    
end
end

