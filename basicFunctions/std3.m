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

% validate that our input is valid for the IMHIST optimization
fast_data_type = isa(a,'logical') || isa(a,'int8') || isa(a,'uint8') || ...
    isa(a,'uint16') || isa(a,'int16');

% only use IMHIST for images of sufficient size
big_enough = containers.Map( ...
    {'logical','int8','uint8','int16','uint16'}, ...
    numel(a) > [2e4 2e5 2e5 5e5 4e5]);

if fast_data_type && ~issparse(a) && big_enough(class(a))
    
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
    
else
    
    % use simple implementation
    if ~isa(a,'single')
        a = double(a);
    end
    s = std(a(:));
    
end
