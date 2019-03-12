function experimentStructure = extractFISSA_results(experimentStructure)
% Extracts information from FISSA results back into experimentStructure


% load in FISSA structure
FISSAStruct = load([experimentStructure.savePath 'FISSA\matlab.mat']);

% break out FISSA struct
for cellNo =1:length(fieldnames(FISSAStruct.raw))
    
    experimentStructure.extractedF_FISSA(cellNo,:) = eval(['FISSAStruct.result.cell' num2str(cellNo-1) '.trial0(1,:)']);
    
    %     experimentStructure.rawF_FISSA(cellNo,:) = eval(['FISSAStruct.raw.cell' num2str(cellNo-1) '.trial0(1,:)']);
    %     experimentStructure.rawDF_FISSA(cellNo,:) = eval(['FISSAStruct.df_raw.cell' num2str(cellNo-1) '.trial0(1,:)']);
    %     experimentStructure.rawBaseline_FISSA(cellNo,:) = eval(['FISSAStruct.rawBaseline.cell' num2str(cellNo-1) '.trial0(1,:)']);
    %     experimentStructure.extractedDF_FISSA(cellNo,:) = eval(['FISSAStruct.df_result.cell' num2str(cellNo-1) '.trial0(1,:)']);
    %     experimentStructure.extractedBaseline_FISSA(cellNo,:) = eval(['FISSAStruct.resultBaseline.cell' num2str(cellNo-1) '.trial0(1,:)']);
    %
end
end