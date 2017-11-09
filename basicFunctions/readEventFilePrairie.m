function eventArray = readEventFilePrairie(dataFilepath, keyFilepath)
% reads prairie event file and decodes analogue signal into descreet levels
% of stimcode. Inputs are the filepath of excel file and .mat file
% containing the voltage level key calculated in previous work, should not
% need to change file.

% dataFilepath = 'C:\PostDoc Docs\Ca Imaging Project\Voltage Recording Test 3\Voltage Test 2ms-002\Voltage Test 2ms-002_Cycle00001_VoltageRecording_001.csv';
% dataFilepath = 'C:\PostDoc Docs\Ca Imaging Project\Voltage Recording Test 3\Voltage Test 2ms-002\Voltage Test 2ms-002_Cycle00001_VoltageRecording_001.csv';
% keyFilepath='C:\PostDoc Docs\code\matlab\DAQ_tools\PrairieVoltageInfo.mat';

%load keyfile
load(keyFilepath);

% get sampling rate from xml file
xmlpath = [dataFilepath(1:end-3) 'xml'];
metaData = xml2struct(xmlpath);
Fs = str2num(metaData.VRecSessionEntry.Experiment.Rate.Text);

%read out voltage data
data = readVoltageFile(dataFilepath);
% rawEventData = data.Voltage(10000:50000,:);
rawEventData = data.Voltage;

%get the peaks for square wave signals
eventDataDirvative = gradient(rawEventData(:,2));
[~, eventDataLoc]= findpeaks(eventDataDirvative, 'MinPeakHeight', 0.002 , 'MinPeakDistance', 60);

eventArrayVoltage = [rawEventData(eventDataLoc+1,1) rawEventData(eventDataLoc+1,2)];

% plot(rawEventData(:,1),rawEventData(:,2));
% hold on
% scatter(eventArrayVoltage(:,1), eventArrayVoltage(:,2), 'r');

% prep Event array with the timepoints
eventArray(:,1) = eventArrayVoltage(:,1);

% set signal error factor
errorLimit = Prairie.std*20;

%convert voltages to event numbers
for i=1:length(eventArrayVoltage)
    
    tempLevel = 0;
    tempLevel=Prairie.VoltageLevels((eventArrayVoltage(i,2)>= Prairie.VoltageLevels(:,2)-errorLimit &  eventArrayVoltage(i,2) <=Prairie.VoltageLevels(:,2)+errorLimit),1);
    eventArray(i,2)= tempLevel;
    
end

% Plot voltage trace and decoded event number ident

% plot(rawEventData(:,1),rawEventData(:,2));
% hold on
% text(eventArray(:,1), eventArrayVoltage(:,2), num2str(eventArray(:,2)));
% 

end