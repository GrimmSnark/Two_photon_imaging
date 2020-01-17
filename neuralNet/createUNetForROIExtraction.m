function createUNetForROIExtraction
% master script for creating and training neural net for cell ROI
% extraction

dataDir = 'D:\Data\2P_Data\Processed\Mouse\neuralNetTestv2'; % data directory
maskLocation = 'D:\Data\2P_Data\Processed\Mouse\neuralNetTestv2\masks'; % ROI mask directory
saveLoc = 'D:\Data\2P_Data\Processed\Mouse\neuralNetTestv2\Nets'; % save directory for neural nets

createMasks = 0; % flag for creating masks (already done)


imageData = imageDatastore(dataDir);
imageData.ReadSize = length(imageData.Files);
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
    %     labeledROI(labeledROI>0) = 65536;
    labeledROI(labeledROI>0) = 255;
    
    % copy ROIS to be the same size as the image array
    repOFLabeledROI = length(imageData.Files)/size(labeledROI,3);
    labeledROIRep = repmat(labeledROI,[ 1, 1, 3] );
    
    % convert into 8bit
    %     labeledROIRep = uint16(labeledROIRep);
    labeledROIRep = uint8(labeledROIRep);
    
    
    % save masks to then use as datastore
    for x = 1:size(labeledROIRep, 3)
        saveastiff(labeledROIRep(:,:,x), [maskLocation '\Mask_' sprintf( '%02d' ,x) '.tif' ]);
    end
end

%% get the ROI masks
labeledROIDataStore = pixelLabelDatastore(maskLocation, {'Background', 'Cell'}, [0 255]);
% labeledROIDataStore = pixelLabelDatastore(maskLocation, {'Cell'}, [255]);


% extract 'patches' gets the data into the right format for processing

augmenter = imageDataAugmenter('RandRotation',[0 90],'RandXReflection',true, 'RandYReflection',true);
 dsTrain = randomPatchExtractionDatastore(imageData, labeledROIDataStore, 128 ,'PatchesPerImage', 4, 'DataAugmentation',augmenter);
%  dsTrain = combine(imageDataTransformed, labeledROIDataStore);

%% build neural net
inputTileSize = [128 128];
lgraph = createUnet2P(inputTileSize);

disp(lgraph.Layers)


% train options
initialLearningRate = 0.05;
maxEpochs = 150;
minibatchSize = 8;
l2reg = 0.0001;

options = trainingOptions('sgdm',...
    'InitialLearnRate',initialLearningRate, ...
    'Momentum',0.9,...
    'L2Regularization',l2reg,...
    'MaxEpochs',maxEpochs,...
    'MiniBatchSize',minibatchSize,...
    'LearnRateSchedule','piecewise',...
    'Shuffle','every-epoch',...
    'GradientThresholdMethod','l2norm',...
    'GradientThreshold',0.05, ...
    'Plots','training-progress', ...
    'VerboseFrequency',20);

%% run the net
modelDateTime = datestr(now,'dd-mmm-yyyy-HH-MM-SS');
[net,info] = trainNetwork(dsTrain,lgraph,options);
save([saveLoc '\2P_ROINet_v1-' modelDateTime '-Epoch-' num2str(maxEpochs) '.mat'],'net','options');

end