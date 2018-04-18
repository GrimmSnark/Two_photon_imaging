function savePath = createSavePath(dataDir, matlabOrMIJI)
% creates save path folder and fullfile based on the data folder path for
% matlab or MIJI (matlabOrMIJI ==1 for matlab or ==2 for MIJI


if matlabOrMIJI == 1
    delimeter = '\';
    delimeterEnd = '\';
elseif matlabOrMIJI == 2
    delimeter = '\\\';
    delimeterEnd = '\\';
end
pathParts = split(dataDir, '\');
strcmp(pathParts, 'Raw');
pathParts{ans} = 'Processed';
pathParts{end} = datestr(now,'yyyymmddHHMMSS');
savePath = strjoin(pathParts, delimeter);
savePath= strcat(savePath, delimeterEnd);

if ~exist(savePath)
    mkdir(savePath);
end

end