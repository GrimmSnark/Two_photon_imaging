function getGausFitSingle(recordingDir, noColor)

% load experimentStructure
load([recordingDir 'experimentStructure.mat']);
disp('Loaded in experimentStructure');


for cell = 1:experimentStructure.cellCount
    
    meanData = mean(cell2mat(experimentStructure.dFstimWindowAverageFBS{1, cell}));
    meanDataReshaped = reshape(meanData,[],noColor)';
    
    for i =1:noColor
        
        if ~any(isnan(meanDataReshaped(:)))
            x=interp1(meanDataReshaped(i,:),linspace(1,6,18));
            gausStruct = singleGaussianFit(x);
            
            grandSigma(i,cell) = gausStruct(3);
            grandR2(i,cell) = gausStruct(end);
            
            if gausStruct(end) > 0.5 % R2 value threshold for fit
                gausWidth(i,cell) =gausStruct(3);
            else
                gausWidth(i,cell) = NaN;
            end
            
        else
            gausWidth(i,cell) = NaN;
        end
    end
    
end

% gets cell ROI map
cellROIs = experimentStructure.labeledCellROI;
for i =1:noColor
    
    % sets up blank images
    cellMap = zeros(experimentStructure.pixelsPerLine);
    nonResponsive = zeros(size(cellROIs));
    
    for cell = 1:experimentStructure.cellCount
        if ~isnan(gausWidth(i,cell))
            cellMap(cellROIs ==cell) = gausWidth(i,cell);
        else
            cellMap(cellROIs ==cell) = 0;
            nonResponsive(cellROIs ==cell)=1;
        end
    end
    nonResponsivePerCol(:,:,i) = nonResponsive;
    grandMaps(:,:,i) = cellMap;
end

grandMapsNorm = grandMaps/max(grandMaps(:));
nonResponsivePerCol = logical(nonResponsivePerCol);

for i =1:noColor
    
    rgbMap = ind2rgb(round(grandMapsNorm(:,:,i)*256), MSHot);
    rgbMap(repmat(nonResponsivePerCol(:,:,i),1,1,3)) = 0.5;
    colormap(MSHot);
    figMap = imshow(rgbMap);
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
    colorBar = colorbar ;
    axis on
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    axis square
    tightfig;
    colorBar.Ticks = linspace(0,1, 5);
    colorBar.TickLabels = linspace(min(grandMaps(:)), max(grandMaps(:)), 5);
    
    saveas(gcf, [experimentStructure.savePath  'Gaus width _Color_' num2str(i) '.epsc']);
    imwrite(rgbMap, [experimentStructure.savePath  'Gaus width native_Color_' num2str(i) '.tif']);              
end


experimentStructure.dFstimWindowAverageFBSSigmaFit = grandSigma;
experimentStructure.dFstimWindowAverageFBSSigmaR2 = grandR2;

save([experimentStructure.savePath 'experimentStructure.mat'], 'experimentStructure');

end