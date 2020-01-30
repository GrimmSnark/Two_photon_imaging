function readEventFileSetupV2(filepathData)
% This function analyses the output from testDAQOutSignal.m and produces a
% look up table file (PrairieVoltageInfo.mat) for actual voltage levels to
% correspond to event numbers used in experiments. This should only need to
% be run at the installation of the toolbox.
% filepathData is the fullfile string of the voltage recording .csv OR cell
% string s x 1 for multiple .csv  voltage files from multiple runs of
% testDAQOutSignal.m
% This function should output to the save location for the look up table
% (should be saved in the basicfunctions folder as PrairieVoltageInfo.mat)

%% hard codes from inital writing
% filepathData = 'C:\PostDoc Docs\Ca Imaging Project\Voltage Recording Test 3\Voltage Test 2ms-001\Voltage Test 2ms-001_Cycle00001_VoltageRecording_001.csv';
%  
% filepathData{1,1}= 'C:\PostDoc Docs\Ca Imaging Project\Voltage Recording Test 3\Voltage Test 2ms-001\Voltage Test 2ms-001_Cycle00001_VoltageRecording_001.csv';
% filepathData{2,1}= 'C:\PostDoc Docs\Ca Imaging Project\Voltage Recording Test 3\Voltage Test 2ms-002\Voltage Test 2ms-002_Cycle00001_VoltageRecording_001.csv';
% % 
 %filepathData = 'C:\PostDoc Docs\Ca Imaging Project\Voltage Recording Test 4\TSeries-09262018-1149-015\TSeries-09262018-1149-015_Cycle00001_VoltageRecording_001.csv';
 
 % 20200130
 filepathData = 'D:\Data\2P_Data\Raw\Calibration\TTL_test\20200130\TSeries-01302020-0806-000\TSeries-01302020-0806-000_Cycle00001_VoltageRecording_001.csv';

%% basic setup info

% work out savefile location
functionPath = mfilename('fullpath');
out=regexp(functionPath,'\','split');

filepathSave =[];
for i =1:length(out)-1
   filepathSave =  [filepathSave '\' out{1,i}];
end
filepathSave = [filepathSave(2:end) '\PrairieVoltageInfo.mat'];

minimumPeakNum =255; % number of voltage levels to find (255 + 0V level =256, ie 8 bit)

if ischar(filepathData) % if there is a single file
    data = readVoltageFile(filepathData);
elseif iscell(filepathData) % if there are multiple files, concatenate voltages
   data.Voltage  =[];
    for i = 1:length(filepathData)
        tempData = readVoltageFile(filepathData{i,1});
        data.Voltage = vertcat(data.Voltage, tempData.Voltage); 
    end
    data.headers = tempData.headers;
end

 rawEventData = data.Voltage;
 
 rawEventData = rawEventData(1:length(rawEventData)/2,:);
 
  %% do the peak detection
% find all peaks...

gradRawData = rawEventData;
gradRawData(:,2) = gradient(gradRawData(:,2));
gradRawDataPos = gradRawData;
gradRawDataPos(gradRawDataPos<0) = 0;

[peaks, peaksLoc] = findpeaks(gradRawDataPos(:,2), 'MinPeakHeight', 0.007);


% plot(1:length(gradRawDataPos(:,2)), gradRawDataPos(:,2))
% hold on
% scatter(peaksLoc, peaks, 'v');

% plot(1:length(rawEventData(:,2)), rawEventData(:,2))
% hold on
% scatter(peaksLoc+1, rawEventData(peaksLoc+1,2), 'v');

realPeakVals = rawEventData(peaksLoc+1,:);

% find large time gaps between ramp repeats
timeDiffs = realPeakVals(2:end,1) - realPeakVals(1:end-1,1);

clusterIndx = kmeans(timeDiffs,2);
gapIndexs = find(clusterIndx == 2); % finds end of ramps

% get values for start and end of ramps
endRampValues = [realPeakVals(gapIndexs,:) ;realPeakVals(end,:)];
startRampValues = [realPeakVals(1, :) ;realPeakVals(gapIndexs+1,:)];

% get start and end indexes
startRampIndexs = [1 ; gapIndexs+1];
endRampIndex = [gapIndexs ; length(realPeakVals)];

% plot(rawEventData(:,1), rawEventData(:,2))
% hold on
% scatter(endRampValues(:,1), endRampValues(:,2), 'v', 'r');
% scatter(startRampValues(:,1), startRampValues(:,2), 'o', 'g');

%% chunk up repeats
counter = 0;
for i = 1:length(startRampIndexs)
    chunk2Add = realPeakVals(startRampIndexs(i): endRampIndex(i),2);
    if length(chunk2Add) == 255
        counter = counter+1;
        chunkedPeaks(counter,:) =  chunk2Add;
    end
end

meanPeaks = mean(chunkedPeaks);
stdPeaks = std(chunkedPeaks);

% plots the means and stds
% errorbar(meanPeaks, stdPeaks, 'o');

%% wrap up
% preps structure for saving
Prairie.VoltageLevels = horzcat((1:1:255)' , meanPeaks');
Prairie.std = mean(stdPeaks);

% save structure
save(filepathSave, 'Prairie');


end