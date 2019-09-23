function plotCellOrienationPref(experimentStructure, orientationNo, colorNo, orientationRange, dataType)
% Creates a RGB image of maximal response for orientation pref for every
% cell based on the DF/F FISSA or DF/F FBS
% Inputs:   experimentStructure - experimentStructure of analysised data
%           orientationNo - No of orientations tested
%           colorNo - No of colors or SF tested
%           orientationRange - range of orientations, ie [0 360] or [0 180]
%           dataType - OPTIONAL, either 'FBS' or 'FISSA'
%

if nargin <5
    dataType = 'FBS';
end


cellROIs = experimentStructure.labeledCellROI;
cellMap = zeros(experimentStructure.pixelsPerLine);
nonResponsiveMap = cellMap;

orientations = linspace(orientationRange(1), orientationRange(2), orientationNo+1);
orientations = orientations(1:end-1);
cmap = ggb1;

orientationColLevels = round(linspace(1, 256, length(orientations)));


cndNo = length(orientations) * colorNo;

switch dataType
    case 'FBS'
        data = experimentStructure.dFstimWindowAverageFBS;
         responseFlagText = 'responsiveCellFlag';
        textTag = [];
    case 'FISSA'
        data = experimentStructure.dFstimWindowAverage;
            responseFlagText = 'responsiveCellFlagFISSA';
        textTag = '_FISSA';
end

dataMean = cellfun(@mean,(cellfun(@cell2mat,data, 'Un', false)), 'Un', false);

if cndNo~= length(experimentStructure.cndTotal)
   disp('Input wrong number of conditions, please fix!!');
   return
end


    for i = 1:experimentStructure.cellCount
        [~,prefCnd(i)] = max(dataMean{i});
        [prefOrientationNo(i), prefColor(i)] = ind2sub([orientationNo colorNo],prefCnd(i));
    end

    for i = 1:experimentStructure.cellCount
        if eval(['experimentStructure.' responseFlagText '(' num2str(i) ') ~=0'])
            cellMapPrefOri(cellROIs ==i) = prefOrientationNo(i);
            cellMap(cellROIs ==i) = orientationColLevels(prefOrientationNo(i));
        else
            nonResponsiveMap(cellROIs ==i) = 255;
        end
    end
    
    cellMap(cellMap==0) = NaN;
cellMapRGB = ind2rgb(cellMap,cmap);

for x = 1:size(cellMap,1)
    for c = 1:size(cellMap,2)
       
        if isnan(cellMap(x,c))
           cellMapRGB(x,c,:) = 1; 
        end
    end 
end

figure
nonResponsCont = im2bw(nonResponsiveMap);
nonResponsCont = ~nonResponsCont;
nonResponsCont = cat(3, nonResponsCont, nonResponsCont, nonResponsCont);
cellMapRGB(nonResponsCont == 0) = 0.5;

colormap(ggb1);
figMap = imshow(cellMapRGB);
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
colorBar = colorbar ;
axis on
set(gca,'xtick',[]);
set(gca,'ytick',[])
% colorBar.Limits = [0 round(max(map),1)];
 colorBar.Ticks =  [linspace(0,1,orientationNo)];
colorBar.TickLabels = orientations;

saveas(figMap, [experimentStructure.savePath  'orientation_Pref' textTag '.tif']);
imwrite(cellMapRGB, [experimentStructure.savePath 'orientation_Pref_native' textTag '.tif']);
close();
end