function experimentStructure = prepDataSubFunction(vol, experimentStructure, saveRegMovie, experimentFlag, channelIdentifier)
% prepData workhouse function, written to make multiple calls for multi
% channel recordings easier. Completes tiff stack saving, stim STD and mean
% per condition averages, normal STD and average image calculations
% Input- vol: registered channel imaging stack, ie 512 x 512 x noOfFrames
%        experimentStructure: experiment structure
%        saveRegMovie: flag 0/1 to save registered movie file
%        experimentFlag flag 1/0 to create images which require experiment
%        events
%        channelIdentifier: OPTIONAL, string identifier for channel, ie '_Ch1'
%
% Output- experimentStructure: experimentStructure updated

if nargin<5
    channelIdentifier = [];
end

if saveRegMovie ==1
    %         savePath = createSavePath(dataDir, 1);
    disp('Saving registered image stack')
    saveastiff(vol, [experimentStructure.savePath 'registered' channelIdentifier '.tif']);
    disp('Finished saving registered image stack');
    %     saveImagingData(vol,savePath,1,size(vol,3));
end

GPU_used = gpuDevice();
if experimentFlag == 1
    if GPU_used.TotalMemory > 6e+9 % uses GPU to do calc if large enough
        % Create and save STD sums
        [stimSTDSum, preStimSTDSum, stimMeanSum , preStimMeanSum ,experimentStructure] = createStimSTDAverageGPU(vol, experimentStructure, channelIdentifier);
        
        %save images
        saveastiff(stimSTDSum, [experimentStructure.savePath 'STD_Stim_Sum' channelIdentifier '.tif']);
        saveastiff(preStimSTDSum, [experimentStructure.savePath 'STD_Prestim_Sum ' channelIdentifier '.tif']);
        saveastiff(stimMeanSum, [experimentStructure.savePath 'Mean_Stim_Sum' channelIdentifier '.tif']);
        saveastiff(preStimMeanSum, [experimentStructure.savePath 'Mean_Prestim_Sum' channelIdentifier '.tif']);
        
    else  % otherwise uses CPU...
        
        % Create and save STD sums
        [stimSTDSum, preStimSTDSum,experimentStructure] = createStimSTDAverage(vol, experimentStructure, channelIdentifier);
        
        %save images
        saveastiff(stimSTDSum, [experimentStructure.savePath 'STD_Stim_Sum' channelIdentifier '.tif']);
        saveastiff(preStimSTDSum, [experimentStructure.savePath 'STD_Prestim_Sum ' channelIdentifier '.tif']);
    end
end

% Create STD average image and save

% deals with issues of stack size
stdVol = zeros(size(vol,1), size(vol,2));

if size(vol,3)< 2000
    stdVol = std(double(vol), [], 3);
    stdVol = uint16(stdVol);
else
    yyLim = size(vol,1);
    xxLim = size(vol,2);
    parfor yy = 1:yyLim
        for xx = 1:xxLim
            tempData = std2(vol(yy,xx,:));
            stdVol(yy,xx) = tempData;
        end
    end
    stdVol = uint16(stdVol);
end

saveastiff(stdVol, [experimentStructure.savePath 'STD_Average' channelIdentifier '.tif']);

%Create normal average image and save
volTall = tall(vol);
meanVolTall = mean(volTall,3);
meanVol = gather(meanVolTall);
meanVol = mean(vol,3);
meanVol = uint16(meanVol);

saveastiff(meanVol, [experimentStructure.savePath 'Average' channelIdentifier '.tif']);

end