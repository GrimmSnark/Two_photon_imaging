function correctedEventArray = alignPTB2PrairieFiles(eventArray, dataFilepathPTB)



load(dataPTB);

PTBevents = cellfun(@str2double,stimCmpEvents(2:end,:));
