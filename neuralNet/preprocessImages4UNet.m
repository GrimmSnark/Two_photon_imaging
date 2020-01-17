function preprocessImages4UNet(imagesDir, maskDir)

imagesDir = 'D:\Data\2P_Data\Processed\Mouse\neuralNetTestv2\'; % data directory
maskDir = 'D:\Data\2P_Data\Processed\Mouse\neuralNetTestv2\masks\'; % ROI mask directory
saveDir = 'D:\Data\2P_Data\Processed\Mouse\neuralNetTestv3\';


% load in image stacks and transfer to gpu

images = readMultipageTifFiles(imagesDir);
masks = readMultipageTifFiles(maskDir, 'uint8');

imagesExpanded = images;
masksExpanded = masks;
% expand images by rotating 90, 180, 270
rotations = [90 180 270];

for i =1:length(rotations)
    
    rotatedImages = rot90(images,i);
    rotatedMasks = rot90(masks,i);
    
    imagesExpanded = cat(3,imagesExpanded,rotatedImages);
    masksExpanded = cat(3,masksExpanded,rotatedMasks);
    
end

% flip vertical and horizontal
imagesFlip1 = flip(imagesExpanded,1);
imagesFlip2 = flip(imagesExpanded,2);

masksFlip1 = flip(masksExpanded,1);
masksFlip2 = flip(masksExpanded,2);


imagesExpanded = cat(3,imagesExpanded,imagesFlip1, imagesFlip2);
masksExpanded = cat(3,masksExpanded,masksFlip1, masksFlip2);


% double those images by normalizing LUT values to 0-1 x 255
  normImages = uint16(round(mat2gray(imagesExpanded) * 65536));

imagesExpanded = cat(3,imagesExpanded,normImages);
masksExpanded = cat(3, masksExpanded, masksExpanded);


% save Images

for x = 1:size(imagesExpanded,3)
     saveastiff(imagesExpanded(:,:,x), [saveDir 'image_' sprintf( '%04d' ,x) '.tif' ]);
    saveastiff(masksExpanded(:,:,x), [saveDir '\masks\mask_' sprintf( '%04d' ,x) '.tif' ]); 
end
end