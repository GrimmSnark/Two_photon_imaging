function getRandomROIFPerCnd(experimentStructure)


% load in pointers to ROI manager
RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();

ROInumber = RC.getCount();
disp(['You have selected ' num2str(ROInumber) ' ROIs, moving onto analysis']);

% load experimentStructure
% load(['experimentStructure.mat']);


vol = readMultipageTifFiles(experimentStructure.prairiePath);

% apply imageregistration shifts
registeredVol = shiftImageStack(vol,experimentStructure.xyShifts([2 1],:)'); % Apply actual shifts to tif stack
% transfers to FIJI
registeredVolMIJI = MIJ.createImage( 'Registered Volume', registeredVol,true);


for x = 1:ROInumber
    % Select cell ROI in ImageJ
    fprintf('Processing Cell %d\n',x)
    
    % Get cell ROI name and parse out (X,Y) coordinates
    RC.select(x-1); % Select current cell
    
    % Get the fluorescence timecourse for the cell and neuropol ROI by
    % using ImageJ's "z-axis profile" function. We can also rename the
    % ROIs for easier identification.1
    ij.IJ.getInstance().toFront();
    plotVal = ij.plugin.ZAxisProfiler.getPlot(registeredVolMIJI);
    RT(:,1) = plotVal.getXValues();
    RT(:,2) = plotVal.getYValues();
    
    %RC.setName(sprintf('Cell ROI %d',i));
    ex.rawF(x,:) = RT(:,2);
end





% works out what frame length to cut each trial into for further
% analysis
analysisFrameLength = ceil(mean(experimentStructure.EventFrameIndx.TRIAL_END - experimentStructure.EventFrameIndx.PRESTIM_ON));
stimOnFrames = [ceil(mean(experimentStructure.EventFrameIndx.STIM_ON - experimentStructure.EventFrameIndx.PRESTIM_ON))-1 ...
    ceil(mean(experimentStructure.EventFrameIndx.STIM_OFF - experimentStructure.EventFrameIndx.PRESTIM_ON))-1];

experimentStructure.meanFrameLength = analysisFrameLength; % saves the analysis frame length into structure, just FYI
experimentStructure.stimOnFrames = stimOnFrames; % saves the frame index for the trial at which stim on and off occured, ie [7 14] from prestim on

% chunks up dF into cell x cnd x trial
for p = 1:ROInumber % for each cell
    for  x =1:length(experimentStructure.cndTotal) % for each condition
        if any(experimentStructure.cndTotal(x)) % checks if there are any trials of that type
            for y =1:length(experimentStructure.cndTrials{x}) % for each trial of that type
                
                currentTrial = experimentStructure.cndTrials{x}(y); % gets current trial number for that cnd
                
                
                currentTrialFrameStart = experimentStructure.EventFrameIndx.PRESTIM_ON(currentTrial);
                
                %full trial prestimON-trialEND cell cnd trial
                ex.FperCnd{p}{x}(:,y) = ex.rawF(p,currentTrialFrameStart:currentTrialFrameStart+ (analysisFrameLength-1)); %chunks data and sorts into structure
                
                % prestim response and average response per cell x cnd x trial
                
                ex.FpreStimWindow{p}{y,x} = ex.rawF(p,currentTrialFrameStart:experimentStructure.EventFrameIndx.PRESTIM_OFF(currentTrial));
                
                ex.FpreStimWindowAverage{p}{y,x} = mean(ex.FpreStimWindow{p}{y,x});
                
                % stim response and average response per cell x cnd x trial
                
                ex.FstimWindow{p}{y,x} = ex.rawF(p,experimentStructure.EventFrameIndx.STIM_ON(currentTrial):experimentStructure.EventFrameIndx.STIM_OFF(currentTrial));
                ex.FstimWindowAverage{p}{y,x} = mean(ex.FstimWindow{p}{y,x});
            end
        end
    end
end


% sets up average traces per cnd and STDs
for i = 1:length(ex.FperCnd) % for each cell
    for x = 1:length(ex.FperCnd{i}) % for each condition
        ex.FperCndMean{i}(:,x) = mean(ex.FperCnd{i}{x}, 2); % means for each cell frame value x cnd
        ex.FperCndSTD{i}(:,x) = std(ex.FperCnd{i}{x}, 0, 2); % std for each cell frame value x cnd
    end
end


%% plotting

for cellNo = 1:ROInumber
    figure('units','normalized','outerposition',[0 0 1 1])
    ax1 = subplot(2,1,1);
    title(['Raw Fluoresecence']);
    hold on
    plot(ex.rawF(cellNo,:), 'k');
    
    xlim([0 length(ex.rawF(cellNo,:))]);
    ylim([-0.2 max(ex.rawF(cellNo,:))]);
    
    
    
    
    ax2 = subplot(2,1,2);
    data2plot = ex.FperCndMean{1,cellNo};
    
    for x =1:size(data2plot, 2)
        lengthOfData = experimentStructure.meanFrameLength;
        if x >1
            spacing = 5;
            xlocations = ((lengthOfData +lengthOfData* (x-1))- (lengthOfData-1) :lengthOfData + lengthOfData* (x-1)) + spacing*(x-1);
            xlocationMid(x) = xlocations(round(lengthOfData/2));
        else
            spacing = 0;
            xlocations = 0:lengthOfData-1;
            xlocationMid(x) = xlocations(round(lengthOfData/2));
        end
        
        lineCol = 'k';
        
        errorBars = ex.FperCndSTD{1,cellNo}(:,x);
        
        % plot data
        shadedErrorBar(xlocations, data2plot(:,x), errorBars, 'lineprops' , lineCol);
        
        
        
        yMaxVector(x) =  max(data2plot(:,x)+errorBars);
        yMinVector(x) =  min(data2plot(:,x)-errorBars);
    end
    
    xticks(xlocationMid);
    xticklabels([1:size(data2plot, 2)]);
    title('Tuning curve');
    xlabel(sprintf('Stimulus direction (%s)', char(176)));
    xLim = [1 xlocations(end)];
    
    % find y axis lims
    yLim = [min(yMinVector)-0.2 max(yMaxVector)+0.2];
    figHandle = gcf;
    tightfig;
    
    saveas(figHandle, [experimentStructure.savePath ' Cell Area ' num2str(cellNo) '.tif']);
    
    
    close;
    
    
    
end


end
