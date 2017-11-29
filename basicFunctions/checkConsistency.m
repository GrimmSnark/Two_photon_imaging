dataFilepathPrairie = 'C:\PostDoc Docs\Ca Imaging Project\Praire\contrast1\Contrast-000_Cycle00001_VoltageRecording_001.csv';
dataFilepathPTB = 'C:\PostDoc Docs\Ca Imaging Project\PTB_Timing_Files\ContrstOrient_20171128151040.mat';

eventArray = readEventFilePrairie(dataFilepathPrairie, []);
load(dataFilepathPTB);

PTBevents = cellfun(@str2double,stimCmpEvents(2:end,:));

eventCodes = eventArray(:,2);
PTBcodes = PTBevents(:,2);

if length(eventCodes) == length(PTBcodes)
   disp('Success, events are the same size!!!') 
   
   if isequal(eventCodes, PTBcodes)
      
       disp('Awesome, the event codes are exactly the same!!!')
   else
       [val, indx] = find(eventCodes(eventCodes~=PTBcodes));
       
   end
    
else
    disp('Failure, events are NOT the same size!!!')
    
end