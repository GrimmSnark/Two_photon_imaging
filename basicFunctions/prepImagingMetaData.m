function experimentStructure = prepImagingMetaData(experimentStructure, filepath)
% loads and preprocesses the prairie imaging frame data into the experiment
% structure
% Filepath can be folder of data or fullfile to xml experiment file
% code outputs experiment structure with all the data in it
% very messy code but it works....


% folderFilepathPrairie = dataFilepathPrairie(1:find(dataFilepathPrairie=='\',1,'last'));
% folderFilepathPrairie = experimentStructure.prairiePath

if exist(filepath) ==7
    fileList = dir([filepath '*.xml']);
    
    if isempty(fileList)
        error(['Please check filepath:' ...
        '\n%s'], filepath); 
    end
    
    
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
    %     experimentStructure.prairiePathXML = dataFilepathPrairie(1:find(dataFilepathPrairie=='\',1,'last'));
end

%% get all the folder and file paths
CSVList = dir([filepath '*.csv']);
if ~isempty(CSVList)
    prairiePathCSV = [filepath CSVList(1).name];
else
    prairiePathCSV = [];
end
experimentStructure.prairiePathVoltage = prairiePathCSV;
experimentStructure.prairiePathXML = dataFilepathPrairie;

parts = find(dataFilepathPrairie == '\');
experimentStructure.prairiePath = dataFilepathPrairie(1:parts(end));
%% Get the structure from the xml and date/scan type

imagingStructRAW = xml2struct(dataFilepathPrairie);

experimentStructure.date = extractFromStruct(imagingStructRAW, 0, [], 'PVScan', 'Attributes', 'date');
experimentStructure.scanType = extractFromStruct(imagingStructRAW, 0, [], 'PVScan', 'Sequence', 'Attributes', 'type');

%% get all the settings from the structure
for i =1:length(imagingStructRAW.PVScan.PVStateShard.PVStateValue)
    switch i
        case 1
            experimentStructure.scanMode = imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value;
        case 5
            experimentStructure.dwellTime = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
        case 6
            experimentStructure.framePeriod = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
        case 8
            experimentStructure.laserPower = [str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 1}.Attributes.value) ...
                str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 2}.Attributes.value)];
        case 9
            experimentStructure.waveLengthExcitation = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue.Attributes.value);
        case 10
            experimentStructure.linesPerFrame = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
        case 12
            experimentStructure.micronsPerPixel = [str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 1}.Attributes.value)  ...
                str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 2}.Attributes.value)  ...
                str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 3}.Attributes.value)] ;
        case 14
            experimentStructure.lensName = imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value;
        case 15
            experimentStructure.lensMag = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
        case 16
            experimentStructure.lensNA = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
        case 17
            experimentStructure.opticalZoom = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
        case 18
            experimentStructure.pixelsPerLine = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.Attributes.value);
        case 19
            experimentStructure.PMTGain = [str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 1}.Attributes.value)  ...
                str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue{1, 2}.Attributes.value)];
            
        case 20
            experimentStructure.currentPostion = [str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.SubindexedValues{1, 1}.SubindexedValue.Attributes.value)  ...
                str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.SubindexedValues{1, 2}.SubindexedValue.Attributes.value)  ...
                str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.SubindexedValues{1, 3}.SubindexedValue.Attributes.value)] ;
        case 26
            experimentStructure.twoPhotonLaserPower = str2num(imagingStructRAW.PVScan.PVStateShard.PVStateValue{1, i}.IndexedValue.Attributes.value);
    end
end

%% get frame times etc
experimentStructure.absoluteFrameTimes = extractFromStruct(imagingStructRAW, 1, 3, 'PVScan', 'Sequence', 'Frame', 'Attributes', 'absoluteTime');
experimentStructure.absoluteFrameTimes = experimentStructure.absoluteFrameTimes * 1000; % converts the relative times to ms
experimentStructure.relativeFrameTimes = extractFromStruct(imagingStructRAW, 1, 3, 'PVScan', 'Sequence', 'Frame', 'Attributes', 'relativeTime');
experimentStructure.relativeFrameTimes = experimentStructure.relativeFrameTimes * 1000; % converts the relative times to ms
%experimentStructure.voltageFileAbsoluteTime = extractFromStruct(imagingStructRAW, 1, [], 'PVScan', 'Sequence', 'VoltageRecording', 'Attributes', 'absoluteTime');




try
    experimentStructure.filenamesFrame = extractFromStruct(imagingStructRAW, 0, 3, 'PVScan', 'Sequence', 'Frame', 'File', 'Attributes', 'filename');
catch ME
    experimentStructure.filenamesFrame = extractFromStruct(imagingStructRAW, 0, [3 4] , 'PVScan', 'Sequence', 'Frame', 'File', 'Attributes', 'filename');
end

%TO ADD
% imagingStructRAW.PVScan.Sequence.Frame{1, 1}.PVStateShard.PVStateValue.SubindexedValues{1, 3}.SubindexedValue.Attributes.value
% experimentStructure.framePositions = extractFromStruct(imagingStructRAW, 0, [3 6] , 'PVScan', 'Sequence', 'Frame', 'PVStateShard', 'PVStateValue', 'SubindexedValues', 'SubindexedValue', 'Attributes', 'value' );

% imagingData = bfopen([folderFilepathPrairie experimentStructureImaging.filenames{1}]);
%
% experimentStructureImaging.imageFullFile = imagingData{1,1}(:,2)';
% experimentStructureImaging.imageData = imagingData{1,1}(:,1);

end
