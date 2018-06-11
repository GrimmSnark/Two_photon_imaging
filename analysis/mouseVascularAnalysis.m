function mouseVascularAnalysis()

dataDir = 'D:\Data\2P_Data\Raw\Mouse\Vascular\vasc_mouse1\';
analysisWindow = 9;
intializeMIJ;
regOrNot = 0;

folderList = dir(dataDir);
folderList = folderList(3:end);

for i=1:length(folderList)
    currentFolder = [folderList(i).folder '\' folderList(i).name '\'];
    
    saveDir = createSavePath(currentFolder, 2);
    
    [experimentStructure , volRegistered] =  prepData(currentFolder, regOrNot);
    analysisTimeWindowInFrames = round(analysisWindow * experimentStructure.framePeriod);
    
    for x =1:length(experimentStructure.cndTotal) % for each condition
        if any(experimentStructure.cndTotal(x)) % checks if there are any trials of that type
            for y =1:length(experimentStructure.cndTrials{x}) % for each trial of that type
                
                analysisWindowStart = experimentStructure.EventFrameIndx.STIM_OFF(experimentStructure.cndTrials{x}(y)) + 1; % gets start index for analysis ie stim end+1
                analysisWindowEnd = analysisWindowStart + analysisTimeWindowInFrames - 1 ; % gets end index for analysis ie + 5 frames
                
                %                 trialFrameAverage = mean(volRegistered(:,:, analysisWindowStart : analysisWindowEnd), 3 ); % gets these frames and averages
                %
                %                 MIJImgAverage = MIJ.createImage('Imaging data',trialFrameAverage,true); % imports to MIJI and saves
                %                 MIJ.selectWindow("Imaging data");
                %                 ij.IJ.saveAs("Tiff", [saveDir  'cnd' num2str(x-1) 'tr' num2str(y) '.tif' ]);
                %                 ij.IJ.saveAs("PNG", [saveDir  'cnd' num2str(x-1) 'tr' num2str(y) '.png' ]);
                %                 MIJ.run('Close');
                
                trialFrameAverage(:,:,:,y) =  volRegistered(:,:, analysisWindowStart : analysisWindowEnd);
                
            end % for each trial of that cnd
            
            trialFrameAverageMean = mean(reshape(trialFrameAverage, size(trialFrameAverage,1), size(trialFrameAverage,2),[]),3);
            MIJImgAverage = MIJ.createImage('Imaging data',trialFrameAverageMean,true); % imports to MIJI and saves
%             MIJ.selectWindow("Imaging data");
            ij.IJ.saveAs("Tiff", [saveDir  'cnd' num2str(x-1) '.tif' ]);
            ij.IJ.saveAs("PNG", [saveDir  'cnd' num2str(x-1) '.png' ]);
            MIJ.run('Close');
            MIJ.closeAllWindows;
        end % if any trials of that cnd
    end % each cnd
    
    experimentStructure.analysisWindow = analysisWindow;
    save([saveDir 'experimentStructure.mat'], 'experimentStructure');
    
end % for each folder

MIJ.exit

end