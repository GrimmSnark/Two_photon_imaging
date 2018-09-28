function s = std3(a, varargin)
%STD2 Standard deviation of matrix elements. Can include specfic dimension
%to work across
%   B = STD2(A) computes the standard deviation of the values in A.
%
%   Class Support
%   -------------
%   A can be numeric or logical. B is a scalar of class single if A is
%   single and double otherwise.
%
%   Example
%   -------
%       I = imread('liftingbody.png');
%       val = std2(I)
%
%   See also CORR2, MEAN2, MEAN, STD.

%   Copyright 1992-2016 The MathWorks, Inc.

if size(varargin, 1) == 1
    dim = varargin{1,1};
end

    
    % compute histogram
    if islogical(a)
        num_bins = 2;
    else
        data_type = class(a);
        num_bins = double(intmax(data_type)) - double(intmin(data_type)) + 1;
    end
    
    if nargin < 2
        [bin_counts, bin_values] = imhist(a, num_bins);
        
        % compute standard deviation
        total_pixels = numel(a);
        
        sum_of_pixels = sum(bin_counts .* bin_values);
        mean_pixel = sum_of_pixels / total_pixels;
        
        bin_value_offsets      = bin_values - mean_pixel;
        bin_value_offsets_sqrd = bin_value_offsets .^ 2;
        
        offset_summation = sum( bin_counts .* bin_value_offsets_sqrd);
        s = sqrt(offset_summation / total_pixels);
        
    elseif nargin < 3
        
        s = gpuStd(a, num_bins, dim);
        
    end
    
end
