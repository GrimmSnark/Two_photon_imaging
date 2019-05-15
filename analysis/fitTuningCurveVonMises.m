function tuningCurveTrace = fitTuningCurveVonMises(experimentStructure, cellNo, orientationNo, orientationLimit)

directionsPlot = linspace(0,360,orientationNo+1);
directionsCalc = directionsPlot(1:end-1);

testCell = cell2mat(experimentStructure.dFstimWindowAverage{1,cellNo});
errorBars = std(testCell);

dirs = deg2rad(directionsCalc);
dirsPlot = deg2rad(directionsPlot);

plotdirs = deg2rad([0:10:orientationLimit]');

params = fitLS(dirs', testCell);
tuningCurveTrace = tuningCurve(params, plotdirs);

figHandle = figure;
figAx = gca;
hold on
errorbar(figAx, dirs, mean(testCell) , errorBars,'b.');
plot(figAx, plotdirs, tuningCurveTrace,'r');

xticks(gca, dirsPlot)
xticklabels(gca, directionsPlot);
xlim([0 max(plotdirs)]);
    
end