% CONV_SUB_2D Two-dimensional convolution and downsampling
%
% Usage
%    y_ds = CONV_SUB_2D(in, filter, ds, offset)
%
% Input 
%    in (numeric): The input signal to be convolved. WARNING: The expected
%       format varies depending on the filter type used. For
%       'fourier_multires', in = 2d fourier transform of input signal. For
%       'spatial_support', in = original input signal.
%    filter (struct): A filter structure, typically obtained with
%        a filter bank factory function such as MORLET_FILTER_BANK_2D or
%        MORLET_FILTER_BANK_2D_PYRAMID.
%    ds (int): The log2 of downsampling rate.
%    offset (2x1 int): Offset for grid of dowsampling, valid only for
%        filter of type 'spatial_support' (default [0,0]).
%
% Output
%    y_ds (numeric) : the filtered, downsampled signal, in the spatial domain.
%
% See also
%    MORLET_FILTER_BANK_2D, MORLET_FILTER_BANK_2D_PYRAMID, EXTRACT_BLOCK

function y_ds = conv_sub_2d(in, filter, ds, offset)
	if isnumeric(filter)
		sz = size(in);
		filter_j = filter;
		filter_j = [filter_j(1:sz(1)/2,:); ...
			filter_j(sz(1)/2+1,:)/2+filter_j(end-sz(1)/2+1,:)/2; ...
			filter_j(end-sz(1)/2+2:end,:)];
		filter_j = [filter_j(:,1:sz(2)/2) ...
			filter_j(:,sz(2)/2+1)/2+filter_j(:,end-sz(2)/2+1)/2 ...
			filter_j(:,end-sz(2)/2+2:end)];

		y_ds = ifft2(sum(extract_block(in .* filter_j, [2^ds 2^ds]), 3)) / 2^ds;
	else
		switch filter.type
			case 'fourier_multires'
				if (nargin >= 4)
				   error('offset is not a valid parameter for filters of type fourier_multires');
				end
				% compute the resolution of the input signal
				res = floor(log2(size(filter.coefft{1},1)/size(in,1)));
				% retrieves the coefficients of the filter for the resolution
				coefft = filter.coefft{res+1};
				% periodization followed by inverse Fourier transform is 
				% equivalent to inverse Fourier transform followed by
				% downsampling but is faster because the inverse Fourier
				% transform is performed at the coarse resolution
				y_ds = ifft2(sum(extract_block(in .* coefft, [2^ds, 2^ds]), 3)) / 2^ds;
				
			case 'spatial_support'
				if (nargin <4)
					offset = [0,0];
				end
				y = conv2(in, filter.coefft, 'same');
				y_ds = 2^ds * y(1+offset(1):2^ds:end, 1+offset(2):2^ds:end);
				
			otherwise
				error('Unsupported filter type!');
		end
	end	
end
