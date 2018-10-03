function createRegisteredStack(recordingDir)
% Creates .avi file from raw prairie recording directory. Requires that
% folder has already undergone the prepData stage
%
% Inputs - recordingDir (folder location which contains the T series folder
%                       imaging runs, can be processed or raw folder)
%          registerMovie  (0/1 flag for registering movie 0 == not
%                         registered)
%          frameRate (optional variable to specify frame rate, otherwise
%          saves at original recording rate)


if contains(recordingDir, 'Raw') % if you specfy the raw folder then it finds the appropriate processed folder
    recordingDirRAW = recordingDir; % sets raw data path
    
    % sets processed data path
    recordingDirProcessed = createSavePath(recordingDir, 1, 1);
    recordingDirProcessed = recordingDirProcessed(1: find(recordingDirProcessed =='\', 2, 'last'));
    
elseif  contains(recordingDir, 'Processed')
    recordingDirProcessed = recordingDir; % sets processed data path
    recordingDirRAW = createRawFromSavePath(recordingDir); % sets raw data path
end


% load experimentStructure
load([recordingDirProcessed 'experimentStructure.mat']);

% read in tiff file

vol = read_Tiffs(experimentStructure.fullfile,1);
if ndims(vol) ~=3
    vol = readMultipageTifFiles(experimentStructure.prairiePath);
end

    % apply imageregistration shifts
    vol = shiftImageStack(vol,experimentStructure.xyShifts([2 1],:)'); % Apply actual shifts to tif stack
    saveastiff(vol, [experimentStructure.savePath 'registered.tif']);
    
end