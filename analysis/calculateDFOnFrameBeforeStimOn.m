function experimentStructure = calculateDFOnFrameBeforeStimOn(experimentStructure)
% Calculates DF/F with the most simple approach possible, per trial takes
% the F value for the cells on frame just before stim onset and subtracts
% from entire trial to get DF. Calculates DF/F by dividing by the F value. 

analysisFrameLength = experimentStructure.meanFrameLength;

% chunks up dF into cell x cnd x trial
for p = 1:experimentStructure.cellCount % for each cell
    for  x =1:length(experimentStructure.cndTotal) % for each condition
        for y =1:length(experimentStructure.cndTrials{x}) % for each trial of that type
            currentTrial = experimentStructure.cndTrials{x}(y); % gets current trial number for that cnd
            
            currentTrialFrameStart = experimentStructure.EventFrameIndx.PRESTIM_ON(currentTrial);
            
            % splits rawF into conditions/trials
            experimentStructure.rawFperCnd{p}{x}(:,y) = experimentStructure.rawF(p,currentTrialFrameStart:currentTrialFrameStart+ (analysisFrameLength-1)); %chunks data and sorts into structure
            
            % calulates per trial DF/F
            experimentStructure.dFperCndFBS{p}{x}(:,y) = (experimentStructure.rawF(p,currentTrialFrameStart:currentTrialFrameStart+ (analysisFrameLength-1)) - experimentStructure.rawF(p,currentTrialFrameStart+experimentStructure.stimOnFrames(1)-2))/experimentStructure.rawF(p,currentTrialFrameStart+experimentStructure.stimOnFrames(1)-2); %chunks data and sorts into structure
            
            experimentStructure.dFpreStimWindowFBS{p}{y,x} =  experimentStructure.dFperCndFBS{p}{x}(1:experimentStructure.stimOnFrames(1)-1,y);
            experimentStructure.dFpreStimWindowAverageFBS{p}{y,x} = mean(experimentStructure.dFpreStimWindowFBS{p}{y,x});
            
            
            experimentStructure.dFstimWindowFBS{p}{y,x} =  experimentStructure.dFperCndFBS{p}{x}(experimentStructure.stimOnFrames(1):experimentStructure.stimOnFrames(2),y);
            experimentStructure.dFstimWindowAverageFBS{p}{y,x} = mean(experimentStructure.dFstimWindowFBS{p}{y,x});
        end
    end
end

% sets up average traces per cnd and STDs
for i = 1:length(experimentStructure.dFperCndFBS) % for each cell
    for x = 1:length(experimentStructure.dFperCndFBS{i}) % for each condition
        experimentStructure.dFperCndMeanFBS{i}(:,x) = mean(experimentStructure.dFperCndFBS{i}{x}, 2); % means for each cell frame value x cnd
        experimentStructure.dFperCndSTDFBS{i}(:,x) = std(experimentStructure.dFperCndFBS{i}{x}, 0, 2); % std for each cell frame value x cnd 
    end
end
end