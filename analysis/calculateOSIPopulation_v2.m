function calculateOSIPopulation_v2(experimentStructure, orientationNo, directionStimFlag, angleMax, colorNo, dataType)
% Calculates OSIs for a recording and plots a histogram of the results
% Inputs:   experimentStructure
%           orientationNo- number of orientation conditions
%           directionStimFlag - set to 1 if oreintation stim are directions
%           angleMax - maximum angle tested for orientation, eg 180 or 360
%           or 0 if stimulus moves both ways during a single presentation
%           colorNo- number of color conditions
%           dataType - 'FBS' or 'FISSA'

if nargin <6
    dataType = 'FBS';
end

% sets up blank OSI vector
OSI = nan(experimentStructure.cellCount,1);

switch dataType
    case 'FBS'
        data = experimentStructure.dFstimWindowAverageFBS;
        OSI_text = 'OSI_FBS';
        DSI_text = 'DSI_FBS';
        
    case 'FISSA'
        data = experimentStructure.dFstimWindowAverage;
        OSI_text = 'OSI_FISSA';
        DSI_text = 'DSI_FISSA';
end

% checks if your inputs for condition numbers are correct
cndNo = orientationNo * colorNo;
if cndNo~= length(experimentStructure.cndTotal)
    disp('Input wrong number of conditions, please fix!!');
    return
end

% get angle identities
angles = linspace(0, angleMax, orientationNo+1);
angles = angles(1:end-1);

% runs through each cell
for i = 1:experimentStructure.cellCount
    
        %% OSI
        % gets mean data per condition
        dataMean= mean(cell2mat(data{1,i})); 
        
        % finds preferred condition
        [~ ,preferredStimulus] = max(dataMean);
        
        % breaks down the preferred condition into preferred color and
        % orientation
        [prefOrientation, prefColor] = ind2sub([orientationNo colorNo],preferredStimulus);
        
        % only uses broken down values if there is more than one color
        % condition
        if colorNo>1
            orientationVals = dataMean((orientationNo*prefColor)-orientationNo+1:orientationNo*prefColor);
            OSI(i) = calculateOSI_V2(prefOrientation, orientationVals, angles, directionStimFlag);
            
            if directionStimFlag == 1
                DSI(i) = calculateDSI(prefOrientation, orientationVals, angles);
            end
            
        else
            OSI(i) = calculateOSI_V2(prefOrientation, dataMean, angles, directionStimFlag);
            
            if directionStimFlag == 1
                DSI(i) = calculateDSI(prefOrientation, dataMean, angles);
            end
        end
end

% plots histogram of OSO
figHandle= histogram( OSI,50);
title(OSI_text)
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

% adds OSI & DSI field to experimentStructure
eval(['experimentStructure.' OSI_text '= OSI;']);

if directionStimFlag == 1
    eval(['experimentStructure.' DSI_text '= DSI;']);
end

% saves everything
saveas(figHandle, [experimentStructure.savePath OSI_text '_hist.tif']);
save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure');

close;
end