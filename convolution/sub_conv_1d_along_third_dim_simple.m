% SUB_CONV_1D_ALONG_THIRD_DIM_SIMPLE Convolve and subsample along 3rd dim.
%
% Usage
%    x = sub_conv_1d_along_third_dim_simple(yf, filter, ds)
%
% Input
%    yf (numeric): The Fourier transform of the signal to be convolved.
%    filter (struct or numeric): The filter to apply. This can be a filter
%       struct, which must be of type `multires`, or the Fourier transform of
%       the filter.
%    ds (int): The downsampling factor as a power of 2 with respect to xf.
%
% Output
%    x: The z = ifft(yf, [], 3) convolved with filter and downsampled by 2^ds.
%
% See also
%    CONV_SUB_1D

function z_conv_filter = sub_conv_1d_along_third_dim_simple(zf, filter, ds)
	if (isstruct(filter))
		filter = filter.coefft{1};
	end
	filter_rs = repmat(reshape(filter,[1,1,numel(filter)]),...
		[size(zf,1),size(zf,2),1]);
	z_conv_filter = ifft(zf.* filter_rs,[],3);
	if (ds>0) % optimization
		z_conv_filter = 2^(ds/2)*z_conv_filter(:,:,1:2^ds:end);
	end
end
