function chooseROIsForFIJI(recordingDir, overwriteROIFile, preproFolder2Open, channel2Use)
% Batch file for choosing all ROIs in multiple image stacks, is more user
% input efficient that old method
% Inputs: recordingDir- fullfile to folder containing TSeries Images
%
%         overwriteROIFile - 0/1 flag to write ROI file, if 0 tries to find
%         already created zip file containing ROIs
%
%         preproFolder2Open (usually leave blank unless you want to
%                             specify the preprocessed folder number 1,2
%                             etc to use)
%
%         channel2Use - OPTIONAL, indicates which channel to use for 
%                       choosing ROIs if mutiple exist  


magSize = 300; % magnification for image viewing

if nargin <4
    channel2Use = 2; % sets deafult channel to use if in mult
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

% open all the relevant images for ROI chosing
if ~isempty(dir([recordingDirProcessed 'STD_Stim_Sum*']))
    
    files = dir([recordingDirProcessed 'STD_Stim_Sum*']);
    
    if size(files,1) >1 % if multiple channel recording
        imageROI = read_Tiffs([recordingDirProcessed 'STD_Stim_Sum_Ch' num2str(channel2Use) '.tif'],1); % reads in average image
    else
        imageROI = read_Tiffs([recordingDirProcessed 'STD_Stim_Sum.tif'],1); % reads in average image
    end
    
    if exist([recordingDirProcessed 'Pixel Orientation Pref_native_Blue.tif'], 'file')
        pixelPrefBlue = read_Tiffs([recordingDirProcessed 'Pixel Orientation Pref_native_Blue.tif'],1);
    end
    if exist([recordingDirProcessed 'Pixel Orientation Pref_native_Green.tif'], 'file')
        pixelPrefGreen = read_Tiffs([recordingDirProcessed 'Pixel Orientation Pref_native_Green.tif'],1);
    end
    if exist([recordingDirProcessed 'Pixel Orientation Pref_native.tif'], 'file')
        pixelPref = read_Tiffs([recordingDirProcessed 'Pixel Orientation Pref_native.tif'],1);
    end
else
    
    firstSubFolder = returnSubFolderList(recordingDirProcessed);
    
    if isempty(preproFolder2Open) % if not otherwise specified chooses the latest preprocessing folder
        preproFolder2Open = length(firstSubFolder);
    end
    
    recordingDirProcessed = [firstSubFolder(preproFolder2Open).folder '\' firstSubFolder(preproFolder2Open).name '\']; % gets analysis subfolder
    
    try
        files = dir([recordingDirProcessed 'STD_Stim_Sum*']);
        
        if size(files,1) >1 % if multiple channel recording
            imageROI = read_Tiffs([recordingDirProcessed 'STD_Stim_Sum_Ch' num2str(channel2Use) '.tif'],1); % reads in average image
        else
            imageROI = read_Tiffs([recordingDirProcessed 'STD_Stim_Sum.tif'],1); % reads in average image
        end
        
        
        if exist([recordingDirProcessed 'Pixel Orientation Pref_native_Blue.tif'], 'file')
            pixelPrefBlue = read_Tiffs([recordingDirProcessed 'Pixel Orientation Pref_native_Blue.tif'],1);
        end
        if exist([recordingDirProcessed 'Pixel Orientation Pref_native_Green.tif'], 'file')
            pixelPrefGreen = read_Tiffs([recordingDirProcessed 'Pixel Orientation Pref_native_Green.tif'],1);
        end
        if exist([recordingDirProcessed 'Pixel Orientation Pref_native.tif'], 'file')
            pixelPref = read_Tiffs([recordingDirProcessed 'Pixel Orientation Pref_native.tif'],1);
        end
        
    catch
        disp('Average image not found, check filepath or run prepData.m  or prepDataMultiSingle.m on the recording folder')
        return
    end
end

% initalize MIJI and get ROI manager open
intializeMIJ;
RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();
RC.runCommand('Show All without labels');
MIJ.run("Cell Magic Wand Tool");


% get image to FIJI
MIJImageROI = MIJ.createImage('ROI_image',imageROI,true); %#ok<NASGU> supressed warning as no need to worry about
WaitSecs(0.2);
ij.IJ.run('Set... ', ['zoom=' num2str(magSize) ' x=10 y=50']);


%create stack for pixel pref stuff
if exist('pixelPrefGreen', 'var')
    
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
    
elseif exist('pixelPref', 'var')
    Imp = ij.IJ.openImage([recordingDirProcessed 'Pixel Orientation Pref_native.tif']);
    Imp.show;
    WaitSecs(0.2);
    ij.IJ.run('Set... ', ['zoom=' num2str(magSize) ' x=1000 y=50']);
end


if overwriteROIFile
    % Sets up diolg box to allow for user input to choose cell ROIs
    happy = 0;
    while ~happy % loops for a long as you need to if you do not exit or choose continue, ie reset number of ROIs
        response = MFquestdlg([0.5,1],sprintf(['Choose cell ROIs with magic wand tool and "t" to add to ROI manager \n' ...
            'If you are happy to move on with analysis click Continue \n' ...
            'If you want to clear all current ROIs click Clear All \n' ...
            'Or exit out of this window to exit script']), ...
            'Wait for user to do stuff', ...
            'Continue', ...
            'Clear All', ...
            'Continue');
        
        if isempty(response) || strcmp(response, 'Continue')
            happy =1; % kicks you out of loop if continue or exit
        else
            RC.runCommand('Delete'); % resets ROIs if you select clear all
        end
    end
    
    switch response
        
        case ''
            disp('Please restart script'); % if exit, ends script
            return
            
        case 'Continue' % if continue, goes on with analysis
            ROInumber = RC.getCount();
            disp(['You have selected ' num2str(ROInumber) ' ROIs, moving on...']);
    end
    
    RC.runCommand('Save', [recordingDirProcessed 'ROIcells.zip']); % saves zip file
else % if not overwrite, then tries to find already saved ROI file
    
    if exist([recordingDirProcessed 'ROIcells.zip'], 'file') % if zip file actually exists
        disp([recordingDirProcessed  ' contains a valid ROI file!']);
    else %if does not exist
        disp('ROI zip file not found, adjust overwriteROIFile flag and rerun')
        if~ exist('MIJImageROI','var')
            MIJImageROI = MIJ.createImage('ROI_image',imageROI,true); %#ok<NASGU> supressed warning as no need to worry about it
        end
        % Sets up diolg box to allow for user input to choose cell ROIs
        happy = 0;
        while ~happy % loops for a long as you need to if you do not exit or choose continue, ie reset number of ROIs
            response = MFquestdlg([0.5,1],sprintf(['Choose cell ROIs with magic wand tool and "t" to add to ROI manager \n' ...
                'If you are happy to move on with analysis click Continue \n' ...
                'If you want to clear all current ROIs click Clear All \n' ...
                'Or exit out of this window to exit script']), ...
                'Wait for user to do stuff', ...
                'Continue', ...
                'Clear All', ...
                'Continue');
            
            if isempty(response) || strcmp(response, 'Continue')
                happy =1; % kicks you out of loop if continue or exit
            else
                RC.runCommand('Delete'); % resets ROIs if you select clear all
            end
        end
        
        switch response
            
            case ''
                disp('Please restart script'); % if exit, ends script
                return
                
            case 'Continue' % if continue, goes on with analysis
                ROInumber = RC.getCount();
                disp(['You have selected ' num2str(ROInumber) ' ROIs, moving on...']);
        end
        
        RC.runCommand('Save', [recordingDirProcessed 'ROIcells.zip']); % saves zip file
    end
end


% Clean up windows
MIJ.closeAllWindows;

end
