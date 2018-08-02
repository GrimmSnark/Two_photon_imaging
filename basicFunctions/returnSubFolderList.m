function recordingFolder = returnSubFolderList(recordingDir)

% Returns folder

recordingFolder = dir(recordingDir);
dirFlags = [recordingFolder.isdir]; % Gets flags for directories
recordingFolder = recordingFolder(dirFlags); % Extract only those that are directories
recordingFolder(ismember( {recordingFolder.name}, {'.', '..'})) = [];  % remove . and ..

end