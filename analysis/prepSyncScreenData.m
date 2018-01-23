% wrapper script for reading all the experiment and imaging meta data

experimentStructure =[];
% dataFilepathPrairie = 'C:\PostDoc Docs\Ca Imaging Project\Praire\contrast1\Contrast-000_Cycle00001_VoltageRecording_001.csv';
% checkFile =0;
% dataFilepathPTB =[];
% isRFmap =0;

data = syncScreenData();

for i = 1:length(data)
    experimentStructure = prepNONTrialData(experimentStructure, data(i).dataFilepathPrairie, data(i).checkFile, data(i).dataFilepathPTB);
    experimentStructure = prepImagingMetaData(experimentStructure, experimentStructure.prairiePath);
    
    frameFilepath = [experimentStructure.prairiePath experimentStructure.filenamesFrame{1,1}];
    frame = imread(frameFilepath);
    meta=imreadBFmeta(frameFilepath);
    vol = imreadBF(frameFilepath,1,1:length(experimentStructure.filenamesFrame),1);
    StackSlider(vol);
    
end




