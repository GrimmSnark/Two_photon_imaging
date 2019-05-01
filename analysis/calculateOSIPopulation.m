function calculateOSIPopulation(experimentStructure, orientationNo, colorNo)
% Calculates OSIs for a recording and plots a histogram of the results
% Inputs:   experimentStructure
%           orientationNo- number of orientation conditions
%           colorNo- number of color conditions

% sets up blank OSI vector
OSI = nan(experimentStructure.cellCount,1);

data = experimentStructure.dFstimWindowAverageFBS;
% orientationNo = 6;
% colorNo = 4;

% checks if your inputs for condition numbers are correct
cndNo = orientationNo * colorNo;
if cndNo~= length(experimentStructure.cndTotal)
    disp('Input wrong number of conditions, please fix!!');
    return
end

% runs through each cell
for i = 1:experimentStructure.cellCount
    
    % only deals with responsive cells
    if experimentStructure.responsiveCellFlag(i) ==1
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
            OSI(i) = calculateOSI(max(orientationVals), min(orientationVals));
        else
            OSI(i) = calculateOSI(max(dataMean), min(dataMean));
        end
    end
end

% plots histogram of OSO
figHandle= histogram( OSI,50);
title('OSI')
set(figHandle, 'units','normalized','outerposition',[0 0 1 1]);

% adds OSI field to experimentStructure
experimentStructure.OSI = OSI;

% saves everything
saveas(figHandle, [experimentStructure.savePath 'OSI_hist.tif']);
save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure');

close;
end