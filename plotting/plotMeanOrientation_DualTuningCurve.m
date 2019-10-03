function plotMeanOrientation_DualTuningCurve(experimentStructure, cellNo, orientationNo, dataType)

% Inputs:   experimentStructure
%           cellNo- number or vector of numbers for cells to plot
%           orientationNo- number of orientation conditions
%           dataType - 'FBS' or 'FISSA'

if nargin <6
    dataType = 'FBS';
end

switch dataType
    case 'FBS'
        % get data into useful form
        meanData = cellfun(@mean,cellfun(@cell2mat,experimentStructure.dFstimWindowAverageFBS, 'Un', 0), 'Un', 0);
        stdData = cellfun(@std,cellfun(@cell2mat,experimentStructure.dFstimWindowAverageFBS, 'Un', 0), 'Un', 0);
    case 'FISSA'
        % get data into useful form
        meanData = cellfun(@mean,cellfun(@cell2mat,experimentStructure.dFstimWindowAverage, 'Un', 0), 'Un', 0);
        stdData = cellfun(@std,cellfun(@cell2mat,experimentStructure.dFstimWindowAverage, 'Un', 0), 'Un', 0);
        
end

angles = linspace(0,360,orientationNo+1);
angles = angles(1:end-1);
for cell = cellNo
    %prep data into correct format for dual guas function
    
    x=interp1(meanData{cell},linspace(1,orientationNo,36));
    gausStruct = dualGaussianFitMS(x);
    
    
    errorbar(angles,meanData{cell},stdData{cell}/experimentStructure.cndTotal(1), 'o' )
    hold on
    plot(gausStruct.modelTrace(1:max(angles)-1), 'r')
    
    if ~exist([experimentStructure.savePath 'tuningCurvePlots\'], 'dir')
        mkdir([experimentStructure.savePath 'tuningCurvePlots\']);
    end
    
    % saves
    saveas(gcf, [experimentStructure.savePath 'tuningCurvePlots\Tuning Curve Cell ' num2str(cell) '.tif']);
    saveas(gcf, [experimentStructure.savePath 'tuningCurvePlots\Tuning Curve Cell ' num2str(cell) '.svg']);
    close;
end
end