function runSuite2PwMiji(runExtraction)


addpath('C:\PostDoc Docs\code\matlab\Suite2P_constants') % add the path to your make_db file
make_db_MS;
ops0.ResultsSavePath        = 'D:\Data\Suite2PProcessed\'; % a folder structure is created inside


for i =1%:length(db)
    if runExtraction ==1
        runSuite2P(db1);
    end
    
%     load([ops0.ResultsSavePath db(i).mouse_name '\' date '\'     ]);
    initalizeMIJ;
end

end