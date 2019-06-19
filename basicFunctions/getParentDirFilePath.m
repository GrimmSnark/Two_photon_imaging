function parentFullfile = getParentDirFilePath(fullfile)
% get the parent folder path from a file's fullfile path

try
    parts = strfind(fullfile, '\');
catch
    parts = strfind(fullfile, '/');
end
parentFullfile = fullfile(1:parts(end));
end