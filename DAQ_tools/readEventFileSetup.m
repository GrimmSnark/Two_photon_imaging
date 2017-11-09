function readEventFileSetup()

minimumPeakNum =255;

voltageRange = [0 4.096]; % voltage range of output in V
outputVoltLevels = linspace(voltageRange(1), voltageRange(2), 256)'; % voltage output

% filepath = 'C:\PostDoc Docs\Ca Imaging Project\Voltage Recording Test 1\Voltage Recording Test 3-007\Voltage Recording Test 3-007_Cycle00001_VoltageRecording_001.csv';
% filepath = 'C:\PostDoc Docs\Ca Imaging Project\Voltage Recording Test 1\Voltage Recording Test 2-006\Voltage Recording Test 2-006_Cycle00001_VoltageRecording_001.csv';
%
filepath = 'C:\PostDoc Docs\Ca Imaging Project\Voltage Recording Test 3\Voltage Test 2ms-000\Voltage Test 2ms-000_Cycle00001_VoltageRecording_001.csv';
filepath = 'C:\PostDoc Docs\Ca Imaging Project\Voltage Recording Test 3\Voltage Test 2ms-001\Voltage Test 2ms-001_Cycle00001_VoltageRecording_001.csv';
xmlpath = [filepath(1:end-3) 'xml'];

metaData = xml2struct(xmlpath);
Fs = str2num(metaData.VRecSessionEntry.Experiment.Rate.Text);

data = readVoltageFile(filepath);

filepath = 'C:\PostDoc Docs\Ca Imaging Project\Voltage Recording Test 3\Voltage Test 2ms-002\Voltage Test 2ms-002_Cycle00001_VoltageRecording_001.csv';
data2 = readVoltageFile(filepath);

rawEventData = vertcat(data.Voltage, data2.Voltage);


% rawEventData = data.Voltage;

% find first and last peak of every burst...

% all peaks
[peaks, ~]= findpeaks(rawEventData(:,2), 'MinPeakHeight', 0.01 );
incrementAll = peaks(2:end)-peaks(1:end-1);
incrementAll(incrementAll < 0.001) = NaN;
incrementAll(incrementAll == 0) = NaN;
increment = mean(incrementAll, 'omitnan');

%first
removeMaximums = rawEventData(:,2) >= round(increment,2)-0.00015;
rawEventDataFirsts = rawEventData;
rawEventDataFirsts(removeMaximums,2) = 0;
[firstPeaks, firstLocs]= findpeaks(rawEventDataFirsts(:,2), 'MinPeakHeight', 0.0175 , 'MinPeakDistance', 25000);


% last
removeMaximums = rawEventData(:,2) > 4.110001;
rawEventDataLasts = rawEventData;
rawEventDataLasts(removeMaximums,2) = 0;
[lastPeaks, lastLocs]= findpeaks(rawEventData(:,2), 'MinPeakHeight', max(rawEventDataLasts(:,2))-increment, 'MinPeakDistance', 1000 );


% plot(1:length(rawEventData(:,2)), rawEventData(:,2))
% hold on
% scatter(firstLocs, firstPeaks, 'v');
% scatter(lastLocs, lastPeaks, 'v', 'r');
% plot(1:length(rawEventData(:,2)), rawEventDataFirsts(:,2));



% segement out peak bursts

% chunkedData = zeros(35000,100);


for i =1:length(lastLocs)
    
    chunkedData(1:length(rawEventData(firstLocs(i)-100: lastLocs(i)+50 ,2)),i) = rawEventData(firstLocs(i)-100: lastLocs(i)+50 ,2);
    
end

% chunkPeaks = zeros(300,size(chunkedData,2));


for i = 1: length(nonzeros(chunkedData(1,:)))
    
    % find peaks normal
%     [tempPeaks, tempLocs]= findpeaks(chunkedData(:,i), 'MinPeakHeight', 0.014 , 'MinPeakDistance', 60);
%     
%     chunkPeaks(1:length(tempPeaks),i) = tempPeaks;
%     chunkLocs(1:length(tempLocs),i) = tempLocs;
%     
    % find peaks derivative
    chunkDirvative = gradient(chunkedData(:,i));
    
    [~, tempLocsDir]= findpeaks(chunkDirvative, 'MinPeakHeight', 0.001 , 'MinPeakDistance', 60);
    
    chunkPeaksDir(1:length(chunkedData(tempLocsDir+1,i)),i) = chunkedData(tempLocsDir+1,i);
    chunkLocsDir(1:length(tempLocsDir),i) = tempLocsDir;
    
end

count =1;
for i=1:size(chunkPeaksDir,2)
    if length(nonzeros(chunkPeaksDir(:,i)))==minimumPeakNum
    
        peakDir(:,count)=chunkPeaksDir(:,i);
        LocsDir(:,count)= chunkLocsDir(:,i);
        count =count+1;
    end
end



% x = 94;
% plot(1:length(chunkedData(:,x)),chunkedData(:,x));
% 
% hold on
% scatter(chunkLocsDir(:,x), chunkedData(chunkLocsDir(:,x)+1,x), 'v', 'r');

meanPeaks = mean(peakDir,2);
stdPeaks = std(peakDir');

errorbar(meanPeaks, stdPeaks, 'o');

Prairie.VoltageLevels = horzcat((1:1:255)' , meanPeaks);
Prairie.std = mean(stdPeaks);

save('C:\PostDoc Docs\code\matlab\DAQ_tools\PrairieVoltageInfo.mat', 'Prairie');

end


