function prepDataMultifileRecording(recordingDir, experimentType, templateRecordingNum, templateImg)
% wrapper function for prepData which runs on on a full recording session,
% ie multiple movie files of the same cortical region (same cell ROIs) to
% do the preprocessing and produce an average image to run Fiji cell magic
% wand or other RIO extraction. 
%
% Input- recordingDir: image data directory containing multiple
%        subdirectories all with the same field of view
%
%        templateRecordingNum: folder number containing movie for use to
%        register rest of data (if ==[], defaults to middle movie)
%
%        templateImg: 2D image array which is used for registering instead
%        of using standard method, if used templateRecordingNumber must be
%        filled
%    

recordingFolders = returnSubFolderList(recordingDir);

if isempty(templateRecordingNum)
    templateRecordingNum = round(size(recordingFolders, 1)/2); % picks middle recording for alignment of other files
end

if isempty(templateImg)
    templateImg = prepData([recordingDir recordingFolders(templateRecordingNum).name], 1, 1, 0, experimentType, []);
end

numRecordings = length(recordingFolders);
folderNum = 1: numRecordings;
folderNum =folderNum(folderNum~=templateRecordingNum); % removes the template recording number from reanalysis

templateImgArray = zeros([size(templateImg) length(recordingFolders)]); % initalizes the array of average images per each recording
templateImgArray(:,:,templateRecordingNum) = templateImg; % fills the appropriate recording number along the 3rd D with the already calculated image

for i =folderNum
    templateImgArray(:,:,i) = prepData([recordingDir recordingFolders(i).name], 1, 1, 0, experimentType, []); % preps the rest of the imaging files
end

recordingTemplate = round(mean(templateImgArray,3)); % makes average of all the movie averages for ROI selection
recordingTemplate = uint16(recordingTemplate);

savePath = createSavePath(recordingDir, 1);
saveastiff(recordingTemplate, [savePath 'Recording_Average_ROI_Image.tif'])
end