function prepSyncScreenData()
% wrapper script for reading all the experiment and imaging meta data

experimentStructure =[];
% dataFilepathPrairie = 'C:\PostDoc Docs\Ca Imaging Project\Praire\contrast1\Contrast-000_Cycle00001_VoltageRecording_001.csv';
% checkFile =0;
% dataFilepathPTB =[];
% isRFmap =0;

data = syncScreenData();

for i = 4:length(data)
    experimentStructure = prepNONTrialData(experimentStructure, data(i).dataFilepathPrairie, data(i).checkFile, data(i).dataFilepathPTB);
    
    [experimentStructure, vol]= prepImagingData(experimentStructure, experimentStructure.prairiePath, data(i).Z_or_TStack);
    
    for x=1:size(vol, 3)
        imageMean(x)= mean(mean(vol(:,:,x)));
        
    end
    
    onTimes = experimentStructure.eventArray(experimentStructure.eventArray(:,2)==60);
    offTimes = experimentStructure.eventArray(experimentStructure.eventArray(:,2)==215);
    
    plot(experimentStructure.relativeFrameTimes,imageMean)
    xlim(gca ,[0 experimentStructure.relativeFrameTimes(end)]);
    hold on
    vline(onTimes, 'g' );
    vline(offTimes, 'r');
    
    %StackSlider(vol); % will display the stack of images, need to click
    %greyscale button
    
end

end




