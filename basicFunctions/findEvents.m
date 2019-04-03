function [eventIndx, eventLocation]= findEvents(event, eventArray, codes)
% find event indices within eventArray, event can be numeric or string,
% codes is the cell array which is produced from running prairieCodes()

if isnumeric(event)
    level = event;
else
    % find voltage level equal to string event
    level = find(strcmp(event, codes), 1);
end

eventIndx = eventArray(:,2) == level;
eventLocation = find(eventIndx);
end