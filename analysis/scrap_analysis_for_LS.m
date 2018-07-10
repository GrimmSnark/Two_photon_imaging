RM = ij.plugin.frame.RoiManager();
RC = RM.getInstance();

vol = ij.IJ.getImage();

cellNumber = RC.getCount();
cells = [];
cells.rawF = [];
cells.rawF_neuropil = [];
cells.xPos = zeros(cellNumber,1);
cells.yPos = zeros(cellNumber,1);
for i = 1:cellNumber
    % Select cell ROI in ImageJ
    fprintf('Processing Cell %d\n',i)
    
    % Get cell ROI name and parse out (X,Y) coordinates
    RC.select(i-1); % Select current cell
    [tempLoc1,tempLoc2] = strtok(char(RC.getName(i-1)),'-');
    cells.xPos(i) =  str2double(tempLoc1);
    cells.yPos(i) = -str2double(tempLoc2);
    
    % Get the fluorescence timecourse for the cell and neuropol ROI by
    % using ImageJ's "z-axis profile" function. We can also rename the
    % ROIs for easier identification.
    for isNeuropilROI = 0:1
        ij.IJ.getInstance().toFront();
        MIJ.run('Plot Z-axis Profile'); % For each image, this outputs four summary metrics: number of pixels (in roi), mean ROI value, min ROI value, and max ROI value
        RT = MIJ.getResultsTable();
        MIJ.run('Clear Results');
        MIJ.run('Close','');
        if isNeuropilROI
            %RC.setName(sprintf('Neuropil ROI %d',i));
            cells.rawF_neuropil(i,:) = RT(:,2);
        else
            %RC.setName(sprintf('Cell ROI %d',i));
            cells.rawF(i,:) = RT(:,2);
            RC.select((i-1)+cellNumber); % Now select the associated neuropil ROI
        end
    end
end


colors = [ 'r'; 'b';'g'];
for x = 1:size(cells.rawF,1)
   plot(cells.rawF(x,:), 'color' ,colors(x,1) );
   hold on
end


imageVolMatrix = MIJ.getCurrentImage();
%%
for y = 2:size(imageVolMatrix,3)
    
   subtractedVol(:,:,y-1) =  imageVolMatrix(:,:,y) -   imageVolMatrix(:,:,y-1);
end

subtractedVolCopy = subtractedVol;
subtractedVolCopy(subtractedVolCopy(:)<0) = 0;
MIJImgStack = MIJ.createImage('Subtracted data',subtractedVolCopy,true);
%%

count =0;
for y = [1:295 297: size(imageVolMatrix,3)]
    count = count+1;
   subtractedSingleVol(:,:,count) =  imageVolMatrix(:,:,y) -   imageVolMatrix(:,:,296);
end



subtractedSingleVolCopy = subtractedSingleVol;
subtractedSingleVolCopy(subtractedSingleVolCopy(:)<0) = 0;
MIJImgStack = MIJ.createImage('Subtracted data',subtractedSingleVolCopy,true);