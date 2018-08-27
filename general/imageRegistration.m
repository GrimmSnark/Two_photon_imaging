function [tifStack,xyShifts] = imageRegistration(tifStack,imageRegistrationMethod,spatialResolution,filterCutoff,templateImage)
% [tifStack,xyShifts] = imageRegistration(tifStack,imageRegistrationMethod,spatialResolution,filterCutoff,templateImage)
% Registers imaging stack to a template image using either a DFT-based subpixel method ('subMicronMethod') or a
% rigid-body transform ('downsampleReg'). The template image can be directly specified, or the
% the first 100 images are used. If the filter cutoff is empty, then no spatial filtering is done to the images.
%
% by David Whitney (david.whitney@mpfi.org), Max Planck Florida Institute, 2017.


if(nargin<2) || isempty(imageRegistrationMethod), imageRegistrationMethod = 'subMicronMethod'; end % can be either subMicronMethod or downsampleReg
if(nargin<3) || isempty(spatialResolution), spatialResolution = 1.3650; end % in microns per pixel
if(nargin<4) || isempty(filterCutoff), filterCutOff  = [30,200];   end % [lowpass cutoff, highpass cutoff] in units of microns
if(nargin<5), templateImage = [];         end % templateImage is ignored when empty
imgsForTemplate     = [1:100];                % how many images to use for the template
useSpatialFiltering = ~isempty(filterCutOff); % spatially filters the images in an attempt to reduce noise that may impair registration
t0=tic;

% Generate a spatially filtered template
if(isempty(templateImage))
    templateImg = uint16(mean(tifStack(:,:,imgsForTemplate),3));
else
    templateImg = templateImage;
end

if(useSpatialFiltering)
    templateImg = real(bandpassFermiFilter(templateImg,-1,filterCutOff(2),spatialResolution));        % Lowpass filtering step
    templateImg = imfilter(templateImg,fspecial('average',round(filterCutOff(1)/spatialResolution))); % Highpass filtering step
end

% Register each image to the template
numberOfImages = size(tifStack,3);
xyShifts       = zeros(2,numberOfImages);
parfor_progress(numberOfImages);
disp('Starting to calculate frame shifts');

parfor(ii = 1:numberOfImages)
   parfor_progress; % get progress in parfor loop
   
    % Get current image to register to the template image and pre-process the current frame.
    sourceImg = tifStack(:,:,ii);
    if(useSpatialFiltering)
        sourceImg = real(bandpassFermiFilter(sourceImg,-1,filterCutOff(2),spatialResolution));        % Lowpass filtering step
        sourceImg = imfilter(sourceImg,fspecial('average',round(filterCutOff(1)/spatialResolution))); % Highpass filtering step
    end
	
    % Determine offsets to shift image
    switch imageRegistrationMethod
        case 'subMicronMethod'
            [~,output]=subMicronInPlaneAlignment(templateImg,sourceImg);
            xyShifts(:,ii) = output(3:4);
        case 'downsampleReg'
            [xyShifts(:,ii)] = downsampleReg_singleImage(sourceImg,templateImg);
    end
end
parfor_progress(0)

disp('Finished calculating frame shifts');
disp('Starting to apply frame shifts');

tifStack = shiftImageStack(tifStack,xyShifts([2 1],:)'); % Apply actual shifts to tif stack

timeElapsed = toc(t0);
sprintf('Finished registering imaging data - Time elapsed is %4.2f seconds',timeElapsed);