% sets paths for miji information: will need to be personalised for your
% computer

% Set plot defaults
set(0,'defaultAxesTickDir','out')
set(0,'defaultAxesTickDirMode','manual')
set(0,'defaultAxesBox','off')
set(0,'DefaultFigureWindowStyle','normal') %docked or normal
set(0,'DefaultFigureColor','w')
warning('off','images:imshow:magnificationMustBeFitForDockedFigure');

currentJavaPath = javaclasspath( '-dynamic');

if ~any(contains(currentJavaPath, [matlabroot '\java\jar\mij.jar'])) % skip if MIJI has already been started
    % Add ImageJ to working directory
    javaaddpath([matlabroot '\java\jar\mij.jar']);
    javaaddpath([matlabroot '\java\jar\ij.jar']);
    
    % Add ImageJ plugins to the current path
    fijiPath = 'C:\PostDoc Docs\Fiji.app\';
    javaaddpath([fijiPath '\plugins'])
    javaaddpath([fijiPath '\macros'])
    javaaddpath([fijiPath 'plugins\BIJ_\bij.jar'])
    javaaddpath([fijiPath 'plugins\Cell_Magic_Wand_Tool.jar'])
    javaaddpath([fijiPath 'plugins\Image_Stabilizer\'])
    % javaaddpath([fijiPath 'plugins\bUnwarpJ_.jar']);
    addpath([fijiPath 'scripts\']);
    
    % Startup ImageJ
    mij = Miji;
end

clear currentJavaPath
% IJ =ij.IJ();