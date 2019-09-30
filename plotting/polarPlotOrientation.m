function polarPlotOrientation(experimentStructure, cellNo, angleMax, noOfAngles, colors)
% Creates and saves polar plots for orientation experiments, can process
% both orientation and combined orientation and color/SF experiments
%
% Inputs:   experimentStucture- experiment processed data from
%                               experimentStrucure.mat
%           cellNo- number or vector of numbers for cells to plot
%           angleMax - maximum angle used, either 180 or 360
%           noOfAngles - number of angles 4/6/8 etc
%           RGB triplet for colors for each of the different orientation
%           types ie for each color OPTIONAL, will use black for single
%           orientation or default to four colors




% set colors for plotting
if nargin < 5 || isempty(colors)
    % colors for monkey orientation colors
    colors = [1 0 0; 0 0.5 0; 1 0.5 0; 0 0 0.5];
end

% get data into useful form
meanData = cellfun(@mean,cellfun(@cell2mat,experimentStructure.dFstimWindowAverageFBS, 'Un', 0), 'Un', 0);
meanDataRearranged = cellfun(@(X) reshape(X,noOfAngles,[]), meanData, 'Un', 0);


% get angles as rad
polarAngles = deg2rad(linspace(0, angleMax, noOfAngles +1));

% for the cells listed
for x = cellNo
    
    % if there are multiple repeats of orientations, ie for every color
    if size(meanDataRearranged{1,x},2)> 1
        for i = 1:size(meanDataRearranged{1,x},2)
            polarplot(polarAngles, [meanDataRearranged{1,x}(:,i) ; meanDataRearranged{1,x}(1,i)], 'color', colors(i,:), 'LineWidth', 2);
            hold on
        end
    else
        polarplot(polarAngles, [meanDataRearranged{1,x} ; meanDataRearranged{1,x}(1)], 'color', 'k', 'LineWidth', 2);
    end
    
    % format the plot properly
    polarPl = gca;
    polarPl.ThetaZeroLocation = 'bottom';
    polarPl.ThetaDir = 'clockwise';
    thetalim([0 angleMax]);
    
    if ~exist([experimentStructure.savePath 'polarPlots\'], 'dir')
        mkdir([experimentStructure.savePath 'polarPlots\']);
    end
    
    % saves
    saveas(gcf, [experimentStructure.savePath 'polarPlots\Polar Plot Cell ' num2str(x) '.tif']);
    saveas(gcf, [experimentStructure.savePath 'polarPlots\Polar Plot Cell ' num2str(x) '.svg']);
    close;
end


end