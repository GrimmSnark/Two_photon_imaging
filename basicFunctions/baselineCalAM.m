function experimentStructure = baselineCalAM(F,experimentStructure)
% Test function for CalAM version of DF/F calc...Not very well tested yet
% (5/17/19)


for i =1:experimentStructure.cellCount
    [~,cdf] = estimate_percentile_level(F(i,:),length(F),length(F));
    cdf_level = median(cdf);
    Fd = prctile(F(i,:),cdf_level,2);
%     F0(i,:) = repmat(prctile(B(i,:),cdf_level,2) + Fd,1,T);
    F0(i,:) = repmat(prctile(F(i,:),cdf_level,2) + Fd,1,length(F));

    F_dff(i,:) = (F(i,:) - Fd)./F0(i,:);
%     F_dff2(i,:) = (F(i,:) - Fd)./F02(i,:);
    
%     figure; plot(F_dff(i,:)); hold on; plot(F_dff2(i,:));
        
end

experimentStructure.dF2 = F_dff;
 

end