function combinedExperimentStructure = combineExperimentStructure(grandStruct, experimentStructure)



% Import any fields not in grandStruct into it from experimentStruct
fields = fieldnames(experimentStructure);

if  isempty(grandStruct)
    grandStruct = experimentStructure;
    
else
    noOfTrials = length(grandStruct.validTrial);
    
    %create distructable copy of experimentStructure
    
    experimentStructureDistructable = experimentStructure;
    
    % run through the fields that need special attention
    experimentStructureDistructableFields = fieldnames(experimentStructureDistructable);
    for r = 1:length( experimentStructureDistructableFields)
        
        switch (experimentStructureDistructableFields{r})
            
            case 'absoluteFrameTimes'
                
                noOfFrames = length(grandStruct.absoluteFrameTimes);
                endAbsoluteTime = grandStruct.absoluteFrameTimes(end);
                modifiedabsoluteFrameTimes = experimentStructureDistructable.absoluteFrameTimes + endAbsoluteTime;
                grandStruct.absoluteFrameTimes = [grandStruct.absoluteFrameTimes modifiedabsoluteFrameTimes];
                experimentStructureDistructable =   rmfield(experimentStructureDistructable, experimentStructureDistructableFields{r});
                
            case 'relativeFrameTimes'
                
                endRelativeTime = grandStruct.relativeFrameTimes(end);
                modifiedrelativeFrameTimes = experimentStructureDistructable.relativeFrameTimes + endRelativeTime;
                grandStruct.relativeFrameTimes = [grandStruct.relativeFrameTimes modifiedrelativeFrameTimes];
                experimentStructureDistructable =   rmfield(experimentStructureDistructable, experimentStructureDistructableFields{r});
                
            case 'rawTrials'
                
                endTimeStamp = grandStruct.rawTrials{end}(end,1);
                modifiedTrials = cellfun(@(x) x + [endTimeStamp 0], experimentStructureDistructable.rawTrials, 'un', 0);
                grandStruct.rawTrials =  [grandStruct.rawTrials ;modifiedTrials];
                
                experimentStructureDistructable =   rmfield(experimentStructureDistructable, experimentStructureDistructableFields{r});
                
            case 'validTrial'
                
                grandStruct.validTrial = [grandStruct.validTrial ; experimentStructureDistructable.validTrial];
                
                experimentStructureDistructable =   rmfield(experimentStructureDistructable, experimentStructureDistructableFields{r});
                
                
            case 'cndTotal'
                
                grandStruct.cndTotal = grandStruct.cndTotal + experimentStructureDistructable.cndTotal;
                
                experimentStructureDistructable =   rmfield(experimentStructureDistructable, experimentStructureDistructableFields{r});
                
                
            case 'block'
                
                endBlock = [endTimeStamp grandStruct.block(end,2)];
                modifiedBlock = experimentStructureDistructable.block + endBlock;
                grandStruct.block = [grandStruct.block ;modifiedBlock];
                
                experimentStructureDistructable =   rmfield(experimentStructureDistructable, experimentStructureDistructableFields{r});
                
            case 'cnd'
                
                modifiedCnd = experimentStructureDistructable.cnd + [endTimeStamp 0];
                grandStruct.cnd = [grandStruct.cnd ;modifiedCnd];
                
                experimentStructureDistructable =   rmfield(experimentStructureDistructable, experimentStructureDistructableFields{r});
                
            case 'cndTrials'
                
                modifiedCndTrials = cellfun(@(x) x + noOfTrials, experimentStructureDistructable.cndTrials, 'un', 0);
                
                grandStruct.cndTrials = cellfun(@horzcat, grandStruct.cndTrials, modifiedCndTrials, 'un', 0);
                
                experimentStructureDistructable =   rmfield(experimentStructureDistructable, experimentStructureDistructableFields{r});
                
            case 'nonEssentialEvent'
                
                modifiedNonEssentialEvent = experimentStructureDistructable.nonEssentialEvent(1,:);
                for x = 1:size(experimentStructureDistructable.nonEssentialEvent, 2)
                    repmatSize = size(experimentStructureDistructable.nonEssentialEvent{2,x});
                    repmatSize = repmatSize - [0 1 0];
                    modifiedNonEssentialEvent = experimentStructureDistructable.nonEssentialEvent{2,x} + repmat([endTimeStamp 0], repmatSize);
                    grandStruct.nonEssentialEvent{2,x} = cat(3,grandStruct.nonEssentialEvent{2,x}, modifiedNonEssentialEvent);
                end
                
                experimentStructureDistructable =   rmfield(experimentStructureDistructable, experimentStructureDistructableFields{r});
                
            case 'EventFrameIndx'
                
                modifiedEventFrameIndx = structfun(@(x) x + noOfFrames, experimentStructureDistructable.EventFrameIndx, 'un', 0);
                
                subStructFields = fieldnames(experimentStructureDistructable.EventFrameIndx);
                for w =1:length(subStructFields)
                    grandStruct.EventFrameIndx.(subStructFields{w})= [grandStruct.EventFrameIndx.(subStructFields{w}) modifiedEventFrameIndx.(subStructFields{w})];
                end
                
                experimentStructureDistructable =   rmfield(experimentStructureDistructable, experimentStructureDistructableFields{r});
                
                
            case 'xyShifts'
                
                grandStruct.xyShifts = [grandStruct.xyShifts experimentStructureDistructable.xyShifts];
                
                experimentStructureDistructable =   rmfield(experimentStructureDistructable, experimentStructureDistructableFields{r});
                
            case 'rawF'
                
                grandStruct.rawF = [grandStruct.rawF experimentStructureDistructable.rawF];
                
                experimentStructureDistructable =   rmfield(experimentStructureDistructable, experimentStructureDistructableFields{r});
                
            case 'rawF_neuropil'
                
                grandStruct.rawF_neuropil = [grandStruct.rawF_neuropil experimentStructureDistructable.rawF_neuropil];
                
                experimentStructureDistructable =   rmfield(experimentStructureDistructable, experimentStructureDistructableFields{r});
                
            case 'correctedF'
                
                grandStruct.correctedF = [grandStruct.correctedF experimentStructureDistructable.correctedF];
                
                experimentStructureDistructable =   rmfield(experimentStructureDistructable, experimentStructureDistructableFields{r});
                
            case 'baseline'
                
                grandStruct.baseline = [grandStruct.baseline experimentStructureDistructable.baseline];
                
                experimentStructureDistructable =   rmfield(experimentStructureDistructable, experimentStructureDistructableFields{r});
                
            case 'dF'
                
                grandStruct.dF = [grandStruct.dF experimentStructureDistructable.dF];
                
                experimentStructureDistructable =   rmfield(experimentStructureDistructable, experimentStructureDistructableFields{r});
                
            case 'dFperCnd'
                
                for s=1:length(grandStruct.dFperCnd) % for each cell
                    for z=1:length(grandStruct.dFperCnd{s}) % for each cnd
                        grandStruct.dFperCnd{s}{z} = [grandStruct.dFperCnd{s}{z} experimentStructureDistructable.dFperCnd{s}{z}];
                    end
                end
                
                experimentStructureDistructable =   rmfield(experimentStructureDistructable, experimentStructureDistructableFields{r});
                
        end
    end
    
    % get non identical fields
    
    [~, ~, experimentStructureNotShared] = comp_struct(grandStruct,experimentStructureDistructable,0,0);
    
    if ~isempty(experimentStructureNotShared)
        experimentStructureNotShared = rmfield(experimentStructureNotShared, {'dFperCndMean', 'dFperCndSTD'});
        
        notSharedFields = fieldnames(experimentStructureNotShared);
        
        for i = 1:length(notSharedFields)
            if size(experimentStructureNotShared.(notSharedFields{i}),1)<2
                grandStruct.(notSharedFields{i}) = mat2cell(grandStruct.(notSharedFields{i}),size(grandStruct.(notSharedFields{i}),1));
                grandStruct.(notSharedFields{i}){end+1,1} = experimentStructureNotShared.(notSharedFields{i});
                
                experimentStructureNotShared = rmfield(experimentStructureNotShared, notSharedFields{i});
            end
        end
        
        % recalculate means and std
        
        for i = 1:length(grandStruct.dFperCnd) % for each cell
            for x = 1:length(grandStruct.dFperCnd{i}) % for each condition
                grandStruct.dFperCndMean{i}(:,x) = mean(grandStruct.dFperCnd{i}{x}, 2); % means for each cell frame value x cnd
                grandStruct.dFperCndSTD{i}(:,x) = std(grandStruct.dFperCnd{i}{x}, 0, 2); % std for each cell frame value x cnd
            end
        end
        
    end
end


combinedExperimentStructure =  grandStruct;
end