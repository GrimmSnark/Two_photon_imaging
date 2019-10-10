function [OSI_list, DSI_list] = population_OSI_DSI(filepath, FBSorFISSA, zScoreLimit)


OSI_list =[];
DSI_list =[];

filepathList = dir([filepath '\**\*experimentStructure.mat']);


for i = 1:length(filepathList)
    load([filepathList(i).folder '\experimentStructure.mat']);
    
    if FBSorFISSA == 1
        OSI_list = [OSI_list; experimentStructure.OSI_FBS(experimentStructure.ZScore_FBS>zScoreLimit)];
        DSI_list = [DSI_list; experimentStructure.DSI_FBS(experimentStructure.ZScore_FBS>zScoreLimit)];
    elseif FBSorFISSA ==2    
        OSI_list = [OSI_list; experimentStructure.OSI_FISSA(experimentStructure.ZScore_FISSA>zScoreLimit)];
        DSI_list = [DSI_list; experimentStructure.DSI_FISSA(experimentStructure.ZScore_FISSA>zScoreLimit)];
    end
        
end