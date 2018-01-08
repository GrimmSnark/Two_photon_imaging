experimentStructure =[];
dataFilepathPrairie = 'C:\PostDoc Docs\Ca Imaging Project\Praire\contrast1\Contrast-000_Cycle00001_VoltageRecording_001.csv';
checkFile =0;
dataFilepathPTB =[];
isRFmap =0;

experimentStructure = prepTrialData(experimentStructure, dataFilepathPrairie, checkFile, dataFilepathPTB, isRFmap);
experimentStructure = prepImagingMetaData(experimentStructure, experimentStructure.prairiePath);

