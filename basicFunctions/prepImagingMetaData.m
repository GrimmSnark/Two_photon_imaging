function experimentStructure = prepImagingMetaData(experimentStructure, filepath)
% loads and preprocesses the prairie imaging frame data into the experiment
% structure
% Filepath can be folder of data or fullfile to xml experiment file
% code outputs experiment structure with all the data in it


% folderFilepathPrairie = dataFilepathPrairie(1:find(dataFilepathPrairie=='\',1,'last'));
% folderFilepathPrairie = experimentStructure.prairiePath

if exist(filepath) ==7
    fileList = dir([filepath '*.xml']);
    
    for i =1:length(fileList)
        dataFilepathPrairie = [filepath fileList(i).name];
        if isfield(experimentStructure, 'prairieEventPath')
            if strcmp(dataFilepathPrairie(1:end-3), experimentStructure.prairieEventPath(1:end-3)) == 0
                dataFilepathPrairie = dataFilepathPrairie;
                break
            end
        else
            break
        end
    end
else
    dataFilepathPrairie = filepath;
    experimentStructure.prairiePath = dataFilepathPrairie(1:find(dataFilepathPrairie=='\',1,'last'));
end

imagingStructRAW = xml2struct(dataFilepathPrairie);

experimentStructure.date = extractFromStruct(imagingStructRAW, 0, [], 'PVScan', 'Attributes', 'date');


experimentStructure.absoluteFrameTimes = extractFromStruct(imagingStructRAW, 1, 3, 'PVScan', 'Sequence', 'Frame', 'Attributes', 'absoluteTime');
experimentStructure.absoluteFrameTimes = experimentStructure.absoluteFrameTimes * 1000; % converts the relative times to ms
experimentStructure.relativeFrameTimes = extractFromStruct(imagingStructRAW, 1, 3, 'PVScan', 'Sequence', 'Frame', 'Attributes', 'relativeTime');
experimentStructure.relativeFrameTimes = experimentStructure.relativeFrameTimes * 1000; % converts the relative times to ms
%experimentStructure.voltageFileAbsoluteTime = extractFromStruct(imagingStructRAW, 1, [], 'PVScan', 'Sequence', 'VoltageRecording', 'Attributes', 'absoluteTime');
experimentStructure.filenamesFrame = extractFromStruct(imagingStructRAW, 0, 3, 'PVScan', 'Sequence', 'Frame', 'File', 'Attributes', 'filename');


% imagingData = bfopen([folderFilepathPrairie experimentStructureImaging.filenames{1}]);
%
% experimentStructureImaging.imageFullFile = imagingData{1,1}(:,2)';
% experimentStructureImaging.imageData = imagingData{1,1}(:,1);

end
