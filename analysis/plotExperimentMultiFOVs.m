function plotExperimentMultiFOVs(experimentDir, folders2Include)


experimentDir = 'D:\Data\2P_Data\Processed\Mouse\gCamp6s\M3\';
folders2Include = 1:8;

subFolders = returnSubFolderList(experimentDir);
if isempty(folders2Include)
    folders = 1:length(subFolders);
else
    folders = folders2Include;
end

counter = 1;
for i = folders
    
    subSubFolders = dir([subFolders(i).folder '\' subFolders(i).name '\TSeries*']);
    resultsFolder = returnSubFolderList([subSubFolders(end).folder '\' subSubFolders(end).name '\']);
    resultsFolderPath = [resultsFolder.folder '\' resultsFolder.name '\'];
    
    [FOVs{counter}, centers{counter}, micronPerPixel{counter}, objectiveMag(counter)] = getFOVInfo(resultsFolderPath);   
    counter = counter +1;
end


for i = 1: length(FOVs)
   
    xShift = size(FOVs{i}, 2) * micronPerPixel{i}(1);
    yShift = size(FOVs{i}, 1) * micronPerPixel{i}(2);
    x = [ centers{i}(1)- xShift   centers{i}(1)+ xShift];
    y = [ centers{i}(2)- yShift   centers{i}(2)+ yShift];
    handle = imagesc('XData', x , 'YData', y , 'CData', FOVs{i});
    hold on
    axis square
    colormap(gray)
    pause
end

end