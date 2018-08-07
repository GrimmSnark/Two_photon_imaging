function rawPath = createRawFromSavePath(dataDir)
% creates raw path folder and fullfile based on the processed data folder path

if nargin < 3
    doNOTmakeDir = 0;
end

    delimeter = '\';
    delimeterEnd = '\';

pathParts = split(dataDir, '\');
pathParts = pathParts(~cellfun('isempty',pathParts)) ;
strcmp(pathParts, 'Processed');
pathParts{ans} = 'Raw';
rawPath = strjoin(pathParts, delimeter);
rawPath= strcat(rawPath, delimeterEnd);

end