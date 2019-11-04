function [OSI_list, DSI_list] = population_OSI_DSI(filepath, FBSorFISSA, zScoreLimit)

if nargin <3 || isempty(zScoreLimit)
    zScoreLimit = [];
end

OSI_list =[];
DSI_list =[];

filepathList = dir([filepath '\**\*experimentStructure.mat']);

for i = 1:length(filepathList)
    try
        load([filepathList(i).folder '\experimentStructure.mat']);
        
        if ~isempty(zScoreLimit)
            if FBSorFISSA == 1
                OSI_list = [OSI_list; experimentStructure.OSI_FBS(experimentStructure.ZScore_FBS>zScoreLimit)];
                DSI_list = [DSI_list; experimentStructure.DSI_FBS(experimentStructure.ZScore_FBS>zScoreLimit)];
            elseif FBSorFISSA ==2
                OSI_list = [OSI_list; experimentStructure.OSI_FISSA(experimentStructure.ZScore_FISSA>zScoreLimit)];
                DSI_list = [DSI_list; experimentStructure.DSI_FISSA(experimentStructure.ZScore_FISSA>zScoreLimit)];
            end
            
        else
            if FBSorFISSA == 1
                OSI_list = [OSI_list; experimentStructure.OSI_FBS];
                DSI_list = [DSI_list; experimentStructure.DSI_FBS];
            elseif FBSorFISSA ==2
                OSI_list = [OSI_list; experimentStructure.OSI_FISSA];
                DSI_list = [DSI_list; experimentStructure.DSI_FISSA'];
            end
        end
    catch
    end
end