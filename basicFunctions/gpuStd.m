function stdArray = gpuStd(a, num_bins, dim)

[bin_counts, bin_values] = imhist(a, num_bins);


% compute standard deviation
total_pixels = numel(a);

sum_of_pixels = sum(bin_counts .* bin_values);
mean_pixel = sum_of_pixels / total_pixels;

bin_value_offsets      = bin_values - mean_pixel;
bin_value_offsets_sqrd = bin_value_offsets .^ 2;

offset_summation = sum( bin_counts .* bin_value_offsets_sqrd);
stdArray = sqrt(offset_summation / total_pixels);

end