function checkCellROICOContourOverlap(recordingDir, COImageFilepath)
% checks cell ROI overlay with CO contours and creates a binary CO
% patch field in experimentStructure

intializeMIJ;

% sets up ROI manager for this function
RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();

% load experimentStructure
load([recordingDir 'experimentStructure.mat']);


COImage = imread(COImageFilepath);
% transfers to FIJI
COImageMIJI = MIJ.createImage( 'CO_image_contours', COImage,true);

% get image in correct format, and getthe CO ROIs
ij.process.ImageConverter(COImageMIJI).convertRGBStackToRGB
ij.IJ.run('16-bit');
ij.IJ.setThreshold(COImageMIJI, 1, 65535);
ij.plugin.filter.Analyzer(COImageMIJI).setOption("BlackBackground", 0);
MIJ.run('Convert to Mask');
MIJ.run('Analyze Particles...', 'add');
COPatchROINum =  RC.getCount();


COPatchSaveDir = getParentDirFilePath(COImageFilepath);
 RC.runCommand('Save', [COPatchSaveDir '\ROICOPatches.zip']); % saves zip file

RC.runCommand('Open', [recordingDir 'ROIcells.zip']); % opens zip file
ROInumber = RC.getCount();


cellNoROIs = ROInumber-COPatchROINum;

ROIobjects = RC.getRoisAsArray;
COROIs = ROIobjects(1:COPatchROINum);
cellROIs = ROIobjects(COPatchROINum+1:end);


for q =1:COPatchROINum %for each CO ROI
    [labeledCO, XYLocsCO ] = createFilledMatlabROIFromFIJIROI(COROIs(q),experimentStructure);
    
    for x = 1:experimentStructure.cellCount % for each Cell
        [labeledCell, XYLocsCell ] = createFilledMatlabROIFromFIJIROI(cellROIs(x), experimentStructure);
        
        polyCO = polyshape(XYLocsCO);
        polyCell = polyshape(XYLocsCell);
        
        intersectPoly = intersect(polyCO, polyCell);
        
        if ~isempty(intersectPoly.Vertices)
            if size(intersectPoly.Vertices) == size(polyCell.Vertices)
                COFlag(q,x) = 1;
            else
                COFlag(q,x) = 2;
            end
        else
            COFlag(q,x) = 0; 
        end  
    end
end

experimentStructure.COIdent = sum(COFlag,1)';

 save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure');

end



