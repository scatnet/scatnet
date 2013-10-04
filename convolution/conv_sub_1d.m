% CONV_SUB_1D One-dimensional convolutive filtering and downsampling.
%
% Usage
%    y_ds = CONV_SUB_1D(xf, filter, ds)
%
% Input
%    xf (numeric): the signal of interest in the frequency domain
%    filter (*numeric OR struct*): the analysis filter in the frequency
%       domain.
%    ds (integer): log2 of downsampling factor with respect to xf
%
% Output
%    y_ds (numeric): the filtered, downsampled signal, in the time domain.
%
% Description
%    This function is at the foundation of the wavelet transform in 1D. It
%    performs an element-wise product of a signal and a filter in the
%    frequency domain, equivalent to a convolution in the time domain.
%    filter may either be :
%       * a DFT real vector, or
%       * a struct with parameters type, N, recenter, coefft and start.
%    See TRUNCATE_FILTER on the role of filter.recenter and filter.start.
%    filter.type is either 'fourier_multires' or 'fourier_truncated'
%    (default), and may be chosen by the user through
%    filt_opt.filter_format. See FILTER_BANK and the impl documentation
%    on this topic.
%    This function operates in at most four steps :
%       # Prior subsampling
%       # Multiplication in the frequency domain
%       # Posterior subsampling or interpolation
%       # Inverse Fourier transform
%
% See also
%   CONV_SUB_2D, WAVELET_1D

function y_ds = conv_sub_1d(xf,filter,ds)
	sig_length = length(xf);

	if isnumeric(filter) % DFT vector
		filter_j = sum(reshape(filter,[sig_length length(filter)/sig_length]),2);
		yf_ds = sum(reshape(xf.*filter_j,[sig_length/2^ds 2^ds]),2) / 2^(ds/2);
	elseif isstruct(filter) % see e.g. MORLET_FILTER_BANK_1D
		if strcmp(filter.type,'fourier_multires')
			yf = xf.*filter.coefft{1+log2(filter.N/sig_length)};
			yf_ds = sum(reshape(yf,[sig_length/2^ds 2^ds]),2) / 2^(ds/2);
		elseif strcmp(filter.type,'fourier_truncated')
			nCoeffts = length(filter.coefft);
			j = log2(nCoeffts/sig_length);
			if j>0 % zero-padding of xf
				xf = [xf(1:end/2); zeros(nCoeffts-sig_length,1); ...
				xf(end/2+1:end)];
			end
			if filter.start<=0 % see TRUNCATE_FILTER
				yf_ds = xf([end+filter.start:end ...
				1:nCoeffts+filter.start-1]) .* filter.coefft;
			else
				yf_ds = xf(filter.start:nCoeffts+filter.start-1).*filter.coefft;
			end
			dsj = ds+j; % log2 of downsampling factor with respect to yf
			if dsj>0 % posterior downsampling
				yf_ds = sum(reshape(yf_ds,[length(yf_ds)/2^dsj 2^dsj]),2);
			elseif dsj<0 % interpolation with zeros
				yf_ds = [yf_ds; zeros((2^(-dsj)-1)*length(yf_ds),1)];
			end
			if filter.recenter % see TRUNCATE_FILTER
				yf_ds = circshift(yf_ds,filter.start-1);
			end
			yf_ds = yf_ds / 2^(ds/2);
		end
	else
		error('Unsupported filter type');
	end

	y_ds = ifft(yf_ds);
end