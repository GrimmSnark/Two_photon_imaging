function extractIntensities(path2ImagingFolder, IJ)
% function extract intensity measurements for microsphere z stack images
% and saves the data into a matlab structure which is written to file. 

experimentStructure =[];
%path2ImagingFolder= 'D:\Data\Stephenson\Dispersion Run-02.06.18\ZSeries-02062018-1351-181\';
Z_or_TStack = 1;

%% reads in image stack
[~, vol]= prepImagingData(experimentStructure, path2ImagingFolder, Z_or_TStack);

% initalizes Fiji/ImageJ
%intializeMIJ; % This is now done in wrapper

% runs the 3D volume segementation, ROI extraction, and instensity
% measurements, calls external Fiji macros because it is easier than
% battling through java code here
MIJImgStack = MIJ.createImage('Imaging data',vol,true);
IJ.runMacroFile("run3DSegment.ijm");
MIJ.selectWindow("Imaging data-3Dseg");

MIJ.setThreshold(1,255);
MIJ.run("Convert to Mask", "method=Default background=Default");

MIJ.run("Watershed", "stack");
MIJ.selectWindow("Imaging data-3Dseg");
IJ.runMacroFile("run3DAddImage.ijm", path2ImagingFolder);

MIJ.selectWindow("Imaging data-3Dseg");
MIJ.run("Close");

% while length(MIJ.getListImages) >1
%     MIJ.run("Close");
% end

MIJ.closeAllWindows

% Add in image summary functions....




%% open and read in horribly organised txt output from Fiji

% for the quantification file
fid = fopen([path2ImagingFolder 'Q_StackQuantif.txt']);
headerLine = fgetl(fid);
headers = strsplit(headerLine,'\t');
headers = strrep(headers,' ','');
headers = strrep(headers,'(','_');
headers = strrep(headers,')','_');

% hack to fix bug
headers{8}= 'CMz_pix_';

cols = [ '%d32' '%d32' '%d32' '%s' '%f64' '%f64' '%f64' '%f64' '%f64' '%f64'];
 
% reads in number data into cell
dataInCells = textscan(fid, cols, 'Delimiter','\t', 'CollectOutput' ,1);

%close file
fclose(fid);

i =1;
for x = 1:length(dataInCells)
    for b =1:length(dataInCells{1,x}(1,:))
        eval(['dataStruct.' headers{i} ' =  dataInCells{1,' num2str(x) '}(:,' num2str(b) ');'])
        i=i+1;
    end
end


% for the measure file
fid = fopen([path2ImagingFolder 'M_StackMeasure.txt']);
headerLine = fgetl(fid);
headers = strsplit(headerLine,'\t');
headers = strrep(headers,' ','');
headers = strrep(headers,'(','_');
headers = strrep(headers,')','_');

% hack to fix bug
headers{8}= 'CMz_pix_';

cols = [ '%d32' '%d32' '%d32' '%s' '%f64' '%f64' '%f64' '%f64' '%f64' '%f64' '%f64' '%f64' '%f64' '%f64' '%f64'];
 
% reads in number data into cell
dataInCells = textscan(fid, cols, 'Delimiter','\t', 'CollectOutput' ,1);

%close file
fclose(fid);

i =1;
for x = 1:length(dataInCells)
    for b =1:length(dataInCells{1,x}(1,:))
        eval(['dataStructMeasure.' headers{i} ' =  dataInCells{1,' num2str(x) '}(:,' num2str(b) ');'])
        i=i+1;
    end
end


dataStruct.Vol_unit_ = dataStructMeasure.Vol_unit_;

%saves output into nice structure
save([path2ImagingFolder 'quantitStructure.mat'], 'dataStruct');


% plot crosses on average diagrams... etc

end

