function disputes = checkConsistency(dataPrairie, dataPTB)
% checks the consistency between recorded prairie events and the events
% set in the PTB experimental file
% dataPrairie can be a filepath for .csv file OR preloaded eventArray
% dataPTB is a filepath for .mat PTB file


% dataFilepathPrairie = 'C:\PostDoc Docs\Ca Imaging Project\Praire\contrast1\Contrast-000_Cycle00001_VoltageRecording_001.csv';
% dataFilepathPTB = 'C:\PostDoc Docs\Ca Imaging Project\PTB_Timing_Files\ContrstOrient_20171128151040.mat';

disputes = [];

if ischar(dataPrairie)
    eventArray = readEventFilePrairie(dataPrairie, []);
else
    eventArray = dataPrairie;
end

load(dataPTB);

PTBevents = cellfun(@str2double,stimCmpEvents(2:end,:));

eventCodes = eventArray(:,2);
PTBcodes = PTBevents(:,2);

if length(eventCodes) == length(PTBcodes)
    disp('Success, events are the same size!!!')
    
    if isequal(eventCodes, PTBcodes)
        
        disp('Awesome, the event codes are exactly the same!!!')
    else
        indx = eventCodes ~= PTBcodes;
        disputes = [indx eventCodes(indx) PTBcodes(indx)];
        
        disp(['Oh no, there are ' num2str(sum(indx)) 'disputed codes, please review!!!'])
    end
    
else
    disp('Failure, events are NOT the same size!!!')
    
end

end