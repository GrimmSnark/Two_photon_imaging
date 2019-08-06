function calcSigOri_ColorResponseF32(experimentStructure)

oriSigCellNo = 0;
cellList =[];

grandR2 = experimentStructure.dFstimWindowAverageFBSSigmaR2;
grandR2L = grandR2(1,:);

nonResponsive = grandR2L(grandR2L< 0.5);


% for cell = 1:experimentStructure.cellCount
%     cellData = cell2mat(experimentStructure.dFstimWindowAverageFBS{1, cell}(:,[1:12 19:24])); % exclude M+L stimuli
%     meanData = mean(cellData);
%     
%     % find pref Condition
%     [~, prefCnd] = max(meanData);
%     
%     % decompose into pref orientation and color
%     [prefOri, prefCol] = ind2sub([6 3], prefCnd);
%     
% %     % test if signifcant orientation tuning against ortho angle
% %     if prefOri < 4
% %         orthoOri = prefOri + 3;
% %     else
% %         orthoOri = prefOri - 3; 
% %     end
% %     
% %     % get ortho cnd
% %     orthoCnd = sub2ind([6 3], 1:6, prefCol);
% 
%     testingCndStart = sub2ind([6 3], 1, prefCol);
%     testingCndEnd = sub2ind([6 3], 6, prefCol);
%    [~, minResponse] = min(meanData(testingCndStart:testingCndEnd));
%    
%    minResponse = minResponse + 6* (prefCol-1);
%     
% %     [hy, p ] = ttest2(cellData(:,prefCnd), cellData(:,orthoCnd));
% 
% [hy, p ] = ttest2(cellData(:,prefCnd), cellData(:,minResponse));
% 
%     if p < 0.05
%         oriSigCellNo = oriSigCellNo +1;
%         cellList = [cellList cell];
%     end
%     
% end
end