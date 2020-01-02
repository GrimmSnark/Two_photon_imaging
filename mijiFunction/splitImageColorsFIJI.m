function splitImageColorsFIJI(folderpath)

files = dir([folderpath '\*.tif']);
intializeMIJ;

for i = 1:length(files)
    imageFilepath = [files(i).folder '\' files(i).name];
    imageMatFIJI =ij.IJ.openImage(imageFilepath);
    
    splitChannelImps = ij.plugin.ChannelSplitter.split(imageMatFIJI);
    
    for channels = 1:length(splitChannelImps)
        if ~exist([folderpath '\C' num2str(channels) ])
           mkdir( [folderpath '\C' num2str(channels) ]);
        end
        ij.process.ImageConverter(splitChannelImps(channels)).convertToGray16;
        ij.io.FileSaver(splitChannelImps(channels)).saveAsTiff([folderpath '\C' num2str(channels) '\' files(i).name ]);
    end
    
end

end

