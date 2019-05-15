function createDiffImageStimVsPrestim(recordingDir)

if nargin<2
   channelIdentifier = []; 
end


% load experimentStructure
load([recordingDir 'experimentStructure.mat']);
disp('Loaded in experimentStructure');

%% Basic setup of tif stack
% read in tiff file

vol = read_Tiffs(experimentStructure.fullfile,1);
if ndims(vol) ~=3
    vol = readMultipageTifFiles(experimentStructure.prairiePath);
end

% apply imageregistration shifts
if isfield(experimentStructure, 'options_nonrigid') && ~isempty(experimentStructure.options_nonrigid) % if using non rigid correctionn
    registeredVol = apply_shifts(vol,experimentStructure.xyShifts,experimentStructure.options_nonrigid);
else
    registeredVol = shiftImageStack(vol,experimentStructure.xyShifts([2 1],:)'); % Apply actual shifts to tif stack
end


[diffSTDImageSum, diffMeanImageSum,experimentStructure] = createStimVSPrestimSTDDiffGPU(vol, experimentStructure);


%save images
saveastiff(diffSTDImageSum, [experimentStructure.savePath 'STD_Diff_Sum' channelIdentifier '.tif']);
saveastiff(diffMeanImageSum, [experimentStructure.savePath 'Mean_Diff_Sum ' channelIdentifier '.tif']);

% save experimentStructure
save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure');

end