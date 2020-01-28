function [OSI_list, DSI_list, OSI_CV_list, PV_list] = population_OSI_DSI(filepath, FBSorFISSA, zScoreLimit)

if nargin <3 || isempty(zScoreLimit)
    zScoreLimit = [];
end

OSI_list =[];
DSI_list =[];
PV_list =[];
OSI_CV_list =[];

filepathList = dir([filepath '\**\*experimentStructure.mat']);

for i = 2:2:length(filepathList)
    try
        load([filepathList(i).folder '\experimentStructure.mat']);
        
        if ~isempty(zScoreLimit)
            if FBSorFISSA == 1
                OSI_list = [OSI_list; experimentStructure.OSI_FBS(experimentStructure.ZScore_FBS>zScoreLimit)];
                DSI_list = [DSI_list; experimentStructure.DSI_FBS(experimentStructure.ZScore_FBS>zScoreLimit)];
                OSI_CV_list = [OSI_CV_list;experimentStructure.OSI_CV_FBS(experimentStructure.ZScore_FBS>zScoreLimit)];
            elseif FBSorFISSA ==2
                OSI_list = [OSI_list; experimentStructure.OSI_FISSA(experimentStructure.ZScore_FISSA>zScoreLimit)];
                DSI_list = [DSI_list; experimentStructure.DSI_FISSA(experimentStructure.ZScore_FISSA>zScoreLimit)];
                OSI_CV_list = [OSI_CV_list;experimentStructure.OSI_CV_FISSA(experimentStructure.ZScore_FBS>zScoreLimit)];
            end
            
        else
            if FBSorFISSA == 1
                OSI_list = [OSI_list; experimentStructure.OSI_FBS];
                DSI_list = [DSI_list; experimentStructure.DSI_FBS];
                OSI_CV_list = [OSI_CV_list;experimentStructure.OSI_CV_FBS];
                
            elseif FBSorFISSA ==2
                OSI_list = [OSI_list; experimentStructure.OSI_FISSA];
                DSI_list = [DSI_list; experimentStructure.DSI_FISSA'];
                OSI_CV_list = [OSI_CV_list;experimentStructure.OSI_CV_FISSA];
                
            end
        end
		
		if isfield(experimentStructure, 'PVCellIndent')
         PV_list = [PV_list;experimentStructure.PVCellIndent];
		end
    catch
    end
end
end