function processPixelCndTrialAverage(pixelChosen, registeredVol, experimentStructure)

% pixelChosen = [356 411];

% get traces for the pixel per cnd per trial etc

for  x =1:length(experimentStructure.cndTotal) % for each condition
    if any(experimentStructure.cndTotal(x)) % checks if there are any trials of that type
        for y =1:length(experimentStructure.cndTrials{x}) % for each trial of that type
            
            currentTrial = experimentStructure.cndTrials{x}(y); % gets current trial number for that cnd
            
            pixelTrace{x,y} = registeredVol(pixelChosen(2),pixelChosen(1),experimentStructure.EventFrameIndx.PRESTIM_ON(currentTrial)-1:experimentStructure.EventFrameIndx.TRIAL_END(currentTrial));
            stimOnFrame(x,y) = experimentStructure.EventFrameIndx.STIM_ON(currentTrial) - experimentStructure.EventFrameIndx.PRESTIM_ON(currentTrial)-1;
        end
    end
end

% realign traces to account for any single frame differences
modeStimOn = mode(stimOnFrame(:));
modeTrialLength = mode(mode(cellfun('length',pixelTrace)));


for  x =1:size(pixelTrace,1) % for each condition
    for y =1:size(pixelTrace,2) % for each trial of that type
        
        if stimOnFrame(x,y) ~=modeStimOn
            diffInFrames = stimOnFrame(x,y)- modeStimOn;
            realignedTraces(:,x,y) = pixelTrace{x,y}( 1+diffInFrames:end);
        else
            if length(pixelTrace{x,y})> modeTrialLength
                diffInFrames = length(pixelTrace{x,y})- modeTrialLength;
                realignedTraces(:,x,y) = pixelTrace{x,y}(1:end-diffInFrames);
            else
                realignedTraces(:,x,y) = pixelTrace{x,y};
            end
        end
        
    end
end


realignedTracesMean = mean(realignedTraces,3);
cmap = distinguishable_colors(size(realignedTracesMean,2), 'w');

handleFig = figure;
hold on
for i =1:size(realignedTracesMean,2)
plot(realignedTracesMean(:,i), 'Color', cmap(i,:), 'LineWidth',2);
end

legendText = {'Cnd 1: 0','Cnd 2: 45' ,'Cnd 3: 90', 'Cnd 4: 135', 'Cnd 5: 180', 'Cnd 6: 225', 'Cnd 7: 270', 'Cnd 8: 315'};
legend(legendText);

ylabel('Raw Mean Intensity');
xlim([1 size(realignedTracesMean,1)]);
title(['Position X- '  num2str(pixelChosen(1)) ' Y- ' num2str(pixelChosen(2))]);


vline([experimentStructure.stimOnFrames - 1],{'r', 'r'}); 
tightfig
set(handleFig, 'Position',[1.743333333333333e+02,82.333333333333330,2.299333333333333e+03,1226], 'PaperPosition', [0,0,60.828494577246580,32.442673199461380]);
legend('Location', 'ne');
 saveas(handleFig, [experimentStructure.savePath 'Pixel Intensity x-' num2str(pixelChosen(1)) ' y- '  num2str(pixelChosen(2)) '.tif']);
 close(handleFig);
end