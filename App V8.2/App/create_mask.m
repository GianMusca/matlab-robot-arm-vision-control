function [BW,maskedRGBImage] = create_mask(im, r_low, r_high, g_low, g_high, b_low, b_high)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = create_red_mask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder app. The colorspace and
%  range for each channel of the colorspace were set within the app. The
%  segmentation mask is returned in BW, and a composite of the mask and
%  original RGB images is returned in maskedRGBImage.

% Auto-generated by colorThresholder app on 09-Jan-2023
%------------------------------------------------------


% Convert RGB image to chosen color space
I = im;

% Define thresholds for channel 1 based on histogram settings
channel1Min = r_low;
channel1Max = r_high;

% Define thresholds for channel 2 based on histogram settings
channel2Min = g_low;
channel2Max = g_high;

% Define thresholds for channel 3 based on histogram settings
channel3Min = b_low;
channel3Max = b_high;

% Create mask based on chosen histogram thresholds
sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

% Initialize output masked image based on input image.
maskedRGBImage = im;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end