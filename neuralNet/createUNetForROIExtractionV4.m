function createUNetForROIExtractionV4
% master script for creating and training neural net for cell ROI
% extraction

dataDir = 'D:\Data\2P_Data\Processed\Mouse\neuralNetTestv3'; % data directory
maskLocation = 'D:\Data\2P_Data\Processed\Mouse\neuralNetTestv3\masks'; % ROI mask directory
saveLoc = 'D:\Data\2P_Data\Processed\Mouse\neuralNetTestv3\Nets'; % save directory for neural nets


%% RUN OPTIONS
createMasks = 0; % flag for creating masks (already done)
trainNet = 1; % train net flag (1 == train net, 0 == load trained net)



%% load data
imageData = imageDatastore(dataDir);
imageData.ReadSize = 1;
% imageDataTransformed = transform(imageData, @preproccessAverageImagesNeuralNet);

exampleImage = readimage(imageData,15);
% exampleImage = preview(imageDataTransformed);
% montage(preview(imageDataTransformed)','Size',[4 2]);

%% creates ROI masks
if createMasks == 1
    % create image ROI masks
    intializeMIJ;
    RM = ij.plugin.frame.RoiManager();
    RC = RM.getInstance();
    
    roiFiles = dir([dataDir '\*.zip']);
    
    for i = 1:length(roiFiles)
        RC.runCommand('Open', [roiFiles(i).folder '\' roiFiles(i).name]); % opens zip file
        ROIobjects = RC.getRoisAsArray;
        labeledROI(:,:,i) = createLabeledROIFromImageJPixels([size(exampleImage)] ,ROIobjects);
        RC.runCommand('Delete'); % resets ROIs if you select clear all
    end
    
    % binarize to 8bit
    labeledROI(labeledROI>0) = 255;
    
    % copy ROIS to be the same size as the image array
    repOFLabeledROI = length(imageData.Files)/size(labeledROI,3);
    labeledROIRep = repmat(labeledROI,[ 1, 1, 3] );
    
    % convert into 8bit
    labeledROIRep = uint8(labeledROIRep);
    
    
    % save masks to then use as datastore
    for x = 1:size(labeledROIRep, 3)
        saveastiff(labeledROIRep(:,:,x), [maskLocation '\Mask_' sprintf( '%03d' ,x) '.tif' ]);
    end
end

%% get the ROI masks
labeledROIDataStore = pixelLabelDatastore(maskLocation, {'Background', 'Cell'}, [0 255]);
% labeledROIDataStore = pixelLabelDatastore(maskLocation, {'Cell'}, [255]);


% extract 'patches' gets the data into the right format for processing

% augmenter = imageDataAugmenter('RandRotation',[0 90],'RandXReflection',true, 'RandYReflection',true);
% dsTrain = pixelLabelImageDatastore(imageData, labeledROIDataStore, 'DataAugmentation',augmenter);
 dsTrain = randomPatchExtractionDatastore(imageData, labeledROIDataStore, 256 ,'PatchesPerImage', 20);
dsTrain.MiniBatchSize = 10;

% subset for validation ( I know this is double dipping)
num2Validate = 100;
dsValidate = partition(dsTrain,num2Validate,1);

%examine dsTrain
testImages = 0;
if testImages == 1
    minibatch = preview(dsTrain);
    inputs = minibatch.inputImage;
    responses = minibatch.pixelLabelImage;
    test = cat(2,inputs,responses);
    C = labeloverlay(mat2gray(test{8,1}),test{8,2},'Transparency',0.8);
    imshow(C);
end

%% build neural net

if trainNet == 1
    inputTileSize = [256 256];
    numClasses = 2;
    lgraph = unetLayersV2(inputTileSize, numClasses, 'EncoderDepth', 5);
    
    
    % taken from example 3D segementation MRI
    outputLayer = dicePixelClassificationLayer('Name','Dice Layer Output');
    lgraph = replaceLayer(lgraph,'Segmentation-Layer',outputLayer);
    
    disp(lgraph.Layers)
    
    
    % train options
    initialLearningRate = 0.001;
    maxEpochs = 150;
    minibatchSize = 8;
    l2reg = 0.001;
    
    options = trainingOptions('rmsprop',...
        'InitialLearnRate',initialLearningRate, ...
        'L2Regularization',l2reg,...
        'MaxEpochs',maxEpochs,...
        'MiniBatchSize',minibatchSize,...
        'ValidationData',dsValidate, ...
        'ValidationFrequency',30, ...
        'LearnRateSchedule','piecewise',...
        'Shuffle','every-epoch',...
        'GradientThresholdMethod','l2norm',...
        'GradientThreshold',0.05, ...
        'Plots','training-progress', ...
        'VerboseFrequency',20);
    
    
    %% run the net
    modelDateTime = datestr(now,'dd-mmm-yyyy-HH-MM-SS');
    [net,info] = trainNetwork(dsTrain,lgraph,options);
    save([saveLoc '\2P_ROINet_Patch256-' modelDateTime '-Epoch-' num2str(maxEpochs) '.mat'],'net','options');
    
elseif trainNet == 0
    %% load the trained net
    nets = dir([saveLoc '\*.mat']);
    
    net = load([nets(end).folder '\' nets(end).name], 'net');
    net = net.net;
end
%% test the net

% get example cell image
cellNo = 450;
exampleImage = readimage(imageData,cellNo);

% segement based on trained network
patch_seg = semanticseg(exampleImage, net, 'outputtype', 'uint8');
patch_segCat = semanticseg(exampleImage, net, 'outputtype', 'categorical');

% add filter to remove noise
segmentedImage = medfilt2(patch_seg,[3,3]);
segmentedImageCat = categorical(segmentedImage,[1 2], {'Background', 'Cell'});

% overlay net results onto example image 
B = labeloverlay(exampleImage,segmentedImage,'Transparency',0.8);
imshow(B)

%  B = labeloverlay(exampleImage,patch_seg,'Transparency',0.8);
%  imshow(B)

% load and display mask for example cell
masks = readimage(labeledROIDataStore, cellNo);
numLookup = [0 255];
maskConvert = numLookup(masks);

figure;
imshow(maskConvert);

DiceAccuracy = dice(masks,segmentedImageCat)


%% get average Dice accuracy

for i = 1:length(imageData.Files)
cellNo = i;
exampleImage = readimage(imageData,cellNo);

% segement based on trained network
patch_seg = semanticseg(exampleImage, net, 'outputtype', 'uint8');

segmentedImage = medfilt2(patch_seg,[3,3]);
segmentedImageCat = categorical(segmentedImage,[1 2], {'Background', 'Cell'});

% load and display mask for example cell
masks = readimage(labeledROIDataStore, cellNo);


DiceAccuracy(:,i) = dice(masks,segmentedImageCat);
end

DiceAccAverage = mean(DiceAccuracy,2);


end