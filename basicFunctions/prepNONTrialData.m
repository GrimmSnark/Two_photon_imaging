function experimentStructure = prepNONTrialData(experimentStructure, dataFilepathPrairie, checkFile, dataFilepathPTB)
% loads and preprocesses the prairie event data into the experiment
% structure, for NON trial data will all check consistency between the
% prairie file and the PTB event file
% Filepaths are self explanatory, only include PTB path if the checkFile
% flag is set to 1
% code outputs experiment structure with all the data in it

%% initalise
check =[];

%% read in events

eventArray = readEventFilePrairie(dataFilepathPrairie, []);

%% if flag is set check consistency between set and recorded events
if checkFile ==1
    check = checkConsistency(eventArray, dataFilepathPTB);
end

%% if any exceptions found end script
if ~isempty(check)
    disp('Check the praire event file and PTB consistency!!');
    return
end
%% Otherwise load into experiment struct


experimentStructure.eventArray = eventArray;
experimentStructure.prairiePath = dataFilepathPrairie(1:find(dataFilepathPrairie=='\',1,'last'));
experimentStructure.prairieEventPath = dataFilepathPrairie;



end