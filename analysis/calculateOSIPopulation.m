function calculateOSIPopulation(experimentStructure, orientationNo, colorNo)

OSI = nan(experimentStructure.cellCount,1);
% orientationNo = 6;
% colorNo = 4;

for i = 1:experimentStructure.cellCount
    
    if experimentStructure.responsiveCellFlag(i) ==1
        %% OSI
        data= mean(cell2mat(experimentStructure.dFstimWindowAverageFBS{1,i}));
        
        [~ ,preferredStimulus] = max(data);
        [prefOrientation, prefColor] = ind2sub([orientationNo colorNo],preferredStimulus);
        
        orientationVals = data((orientationNo*prefColor)-orientationNo+1:orientationNo*prefColor);
        OSI(i) = calculateOSI(max(orientationVals), min(orientationVals));   
    end
end

figure;
histogram(OSI,50);
title('OSI')

experimentStructure.OSI = OSI;

save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure');

end