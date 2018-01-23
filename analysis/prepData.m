% wrapper script for reading all the experiment and imaging meta data

experimentStructure =[];
% dataFilepathPrairie = 'C:\PostDoc Docs\Ca Imaging Project\Praire\contrast1\Contrast-000_Cycle00001_VoltageRecording_001.csv';
% checkFile =0;
% dataFilepathPTB =[];
% isRFmap =0;

data = experimentData();

for i = 1:length(data)
    experimentStructure = prepTrialData(experimentStructure, data(i).dataFilepathPrairie, data(i).checkFile, data(i).dataFilepathPTB, data(i).isRFmap);
    experimentStructure = prepImagingMetaData(experimentStructure, experimentStructure.prairiePath);
    
end
