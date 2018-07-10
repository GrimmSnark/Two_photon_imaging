function prepSyncScreenData(saveFlag)
% wrapper script for reading all the experiment and imaging meta data

experimentStructure =[];
dataDir = 'C:\Users\msavage1\Dropbox\2P\Update Meeting 20180327';

data = syncScreenData();

for i = 4:length(data) % modified for just one session
    experimentStructure = prepNONTrialData(experimentStructure, data(i).dataFilepathPrairie, data(i).checkFile, data(i).dataFilepathPTB);
    
    [experimentStructure, vol]= prepImagingData(experimentStructure, experimentStructure.prairiePath, data(i).Z_or_TStack, 1);
    
    for x=1:size(vol, 3)
        imageMean(x)= mean(mean(vol(:,:,x)));
    end
    
    onTimes = experimentStructure.eventArray(experimentStructure.eventArray(:,2)==60);
    offTimes = experimentStructure.eventArray(experimentStructure.eventArray(:,2)==215);
    
    plot(experimentStructure.relativeFrameTimes,imageMean, 'color', 'k');
    xlim(gca ,[0 experimentStructure.relativeFrameTimes(end)]);
    hold on
    vline(onTimes, 'g' );
    vline(offTimes, 'r');
    
    endTime = round((experimentStructure.relativeFrameTimes(end)/1000));
    
    xticks(0:10000:experimentStructure.relativeFrameTimes(end));
    xticklabels(0:10: endTime);
    xlabel( 'Time in Seconds');
    
    yticks(linspace(0,max(imageMean), 6));
    yticklabels(0:0.2:1);
    ylabel('Relative Intensity');
    
    %StackSlider(vol); % will display the stack of images, need to click
    %greyscale button
   
    set(gcf, 'Position' ,[1 41 2560 1.3273e+03]);
    tightfig;
    
    if saveFlag
       fileName = split(experimentStructure.prairiePath, '\');
       fileName = fileName{end-1};
       saveas(gcf,[dataDir '\' fileName '.eps'], 'epsc');
       saveas(gcf,[dataDir '\' fileName '.png'], 'png');
    end
end

end




