function createFISSARunFile(experimentStructure)
% writes a python runfile for FISSA toolbox

ROIString = strrep([experimentStructure.savePath 'ROIcells.zip'],'\','/');
imagesLoc = strrep([experimentStructure.savePath 'FISSA'],'\','/');
folderString = imagesLoc;   
framRate = num2str(experimentStructure.rate);


fileID = fopen([experimentStructure.savePath 'FISSA\FISSA_run.py'],'w');

nbytes = fprintf(fileID ,['import fissa \n' , ...
    'if __name__ == ''__main__'':\n \n', ...
    '\t rois = ''%s'' \n', ...
    '\t images = ''%s'' \n \n', ...
    '\t folder = ''%s'' \n \n', ... 
    '\t experiment = fissa.Experiment(images, rois, folder) \n', ...
    '\t experiment.separate(redo_prep=True) \n', ...
    '\t experiment.calc_deltaf(freq = %s) \n', ...
    '\t experiment.save_to_matlab()'], ...
    ROIString, ...
    imagesLoc, ...
    folderString, ...
    framRate);


fclose(fileID);

end