function savePath = createSavePath(dataDir, matlabOrMIJI, doNOTmakeDir)
% creates save path folder and fullfile based on the data folder path for
% matlab or MIJI (matlabOrMIJI ==1 for matlab or ==2 for MIJI
% inlcuded doNOTmakeDir (==1) if you just want to create the string for the
% directory but not make it

if nargin < 3
    doNOTmakeDir = 0;
end

if matlabOrMIJI == 1
    delimeter = '\';
    delimeterEnd = '\';
elseif matlabOrMIJI == 2
    delimeter = '\\\';
    delimeterEnd = '\\';
end
pathParts = split(dataDir, '\');
pathParts = pathParts(~cellfun('isempty',pathParts)) ;
strcmp(pathParts, 'Raw');
pathParts{ans} = 'Processed';
pathParts{end+1} = datestr(now,'yyyymmddHHMMSS');
savePath = strjoin(pathParts, delimeter);
savePath= strcat(savePath, delimeterEnd);

if doNOTmakeDir ==0
    if ~exist(savePath)
        mkdir(savePath);
    end
end

end