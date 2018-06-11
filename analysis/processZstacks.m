function processZstacks(path2ImagingFolder, analysisChannel)
% loads in z stacks and registers them before completing background
% subtraction and xy average and z average

experimentStructure =[];
% path2ImagingFolder= 'D:\Data\2P_Data\Raw\Mouse\Structural\cfos_gfp\ZSeries-04122018-0926-000\';
% analysisChannel = 2;
saveDir = createSavePath(path2ImagingFolder, 2);
Z_or_TStack = 1;
loadMetaData = 1;

%% initalizes Fiji/ImageJ
% intializeMIJ; % This is now done in wrapper

%% reads in image stack
try
    [experimentStructure, vol]= prepImagingData(experimentStructure, path2ImagingFolder, Z_or_TStack, loadMetaData,  analysisChannel);
catch ME % if the channel requested is not present
    switch analysisChannel % trys to read in the other channel
        case 1
            [experimentStructure, vol]= prepImagingData(experimentStructure, path2ImagingFolder, Z_or_TStack, 2);
        case 2
            [experimentStructure, vol]= prepImagingData(experimentStructure, path2ImagingFolder, Z_or_TStack, 1);
    end
end

MIJImgStack = MIJ.createImage('Imaging data',vol,true);

%% Do the various processing steps and save images
MIJ.selectWindow("Imaging data");
MIJ.run("StackReg ", "transformation=Translation");
MIJ.run("Subtract Background...", "rolling=10 stack");
MIJ.run("Z Project...", "projection=[Average Intensity]");
MIJ.selectWindow("AVG_Imaging data");
ij.IJ.saveAs("Tiff", [saveDir  'XY_Average.tif' ]);
MIJ.selectWindow("XY_Average.tif");
ij.IJ.saveAs("PNG", [saveDir  'XY_Average.png' ]);
MIJ.run('Close');

MIJ.selectWindow("Imaging data");
MIJ.run("Reslice [/]...", "output=1.000 start=Top avoid");
MIJ.selectWindow("Reslice of Imaging");
MIJ.run("Z Project...", "projection=[Average Intensity]");
MIJ.selectWindow("AVG_Reslice of Imaging");
ij.IJ.saveAs("Tiff", [saveDir  'Z_Average.tif' ]);
MIJ.selectWindow("Z_Average.tif");
ij.IJ.saveAs("PNG", [saveDir  'Z_Average.png' ]);
MIJ.run('Close');


MIJ.selectWindow("Imaging data");
ij.IJ.saveAs("Tiff", [saveDir  'Registered_stack.tif' ]);

MIJ.closeAllWindows;

save([saveDir 'experimentStructure.mat'], 'experimentStructure');


end


