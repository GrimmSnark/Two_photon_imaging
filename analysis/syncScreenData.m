function syncData = syncScreenData()

syncData(1).dataFilepathPrairie = 'C:\PostDoc Docs\Ca Imaging Project\SyncScreen\6s_on_off_with_voltage_2-002\6s_on_off_with_voltage_2-002_Cycle00001_VoltageRecording_001.csv';
syncData(1).checkFile =1;
syncData(1).dataFilepathPTB ='C:\PostDoc Docs\Ca Imaging Project\SyncScreen\ScreenSync_20180123093448.mat';
syncData(1).isRFmap =0;
syncData(1).Z_or_TStack =2;

%% to add to the database
syncData(end+1).dataFilepathPrairie = 'C:\PostDoc Docs\Ca Imaging Project\SyncScreenTest2\6 on 6 off-001\6 on 6 off-001_Cycle00001_VoltageRecording_001.csv';
syncData(end).checkFile =1;
syncData(end).dataFilepathPTB ='C:\PostDoc Docs\Ca Imaging Project\SyncScreenTest2\6 on 6 off-001\ScreenSync_20180124155830.mat';
syncData(end).isRFmap =0;
syncData(end).Z_or_TStack =2;

%% to add to the database
syncData(end+1).dataFilepathPrairie = 'C:\PostDoc Docs\Ca Imaging Project\SyncScreenTest 3\6 on 6 off-001\6 on 6 off-001_Cycle00001_VoltageRecording_001.csv';
syncData(end).checkFile =0;
syncData(end).dataFilepathPTB ='C:\PostDoc Docs\Ca Imaging Project\SyncScreenTest 3\6 on 6 off-001\ScreenSync_20180125091917.mat';
syncData(end).isRFmap =0;
syncData(end).Z_or_TStack =2;

%% to add to the database
syncData(end+1).dataFilepathPrairie = 'C:\PostDoc Docs\Ca Imaging Project\SyncScreenTest 3\6 on 6 off-000\6 on 6 off-000_Cycle00001_VoltageRecording_001.csv';
syncData(end).checkFile =0;
syncData(end).dataFilepathPTB ='C:\PostDoc Docs\Ca Imaging Project\SyncScreenTest 3\6 on 6 off-000\ScreenSync_20180125091330.mat';
syncData(end).isRFmap =0;
syncData(end).Z_or_TStack =2;

%% to add to the database
% syncData(end+1).dataFilepathPrairie = 'C:\PostDoc Docs\Ca Imaging Project\Praire\contrast1\Contrast-000_Cycle00001_VoltageRecording_001.csv';
% syncData(end).checkFile =1;
% syncData(end).dataFilepathPTB =[];
% syncData(end).isRFmap =0;
% syncData(end).Z_or_TStack =2;
%
end