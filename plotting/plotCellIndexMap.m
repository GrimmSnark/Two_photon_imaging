function plotCellIndexMap(experimentStructure, mapType)

cellROIs = experimentStructure.labeledCellROI;
cellMap = zeros(experimentStructure.pixelsPerLine);
nonResponsiveMap = cellMap;

if isfield(experimentStructure, mapType)
    map = eval(['experimentStructure.' mapType]);
    for i = 1:experimentStructure.cellCount
        
        if ~isnan(map(i))
            cellMap(cellROIs ==i) = map(i);
            
        else
            nonResponsiveMap(cellROIs ==i) = 255;
        end
    end
else
    disp('Attempting to plot non-existant field!!')
    return
end

cellMapRescale = cellMap/max(cellMap(:));
cellMapRescale = round(cellMapRescale*256);
cellMapRGB = ind2rgb(cellMapRescale,lcs);

figure
nonResponsCont = im2bw(nonResponsiveMap);
nonResponsCont = ~nonResponsCont;
nonResponsCont = cat(3, nonResponsCont, nonResponsCont, nonResponsCont);
cellMapRGB(nonResponsCont == 0) = 0.5;

colormap(lcs);
figMap = imshow(cellMapRGB);
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
colorBar = colorbar ;
axis on
set(gca,'xtick',[]);
set(gca,'ytick',[])
% colorBar.Limits = [0 round(max(map),1)];
% colorBar.Ticks =  [0. 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6];
colorBar.TickLabels = [linspace(0,round(max(map),1), 11)];

saveas(figMap, [experimentStructure.savePath mapType '.tif']);
imwrite(cellMapRGB, [experimentStructure.savePath mapType '_native.tif']);
close();
end