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

function y_ds = conv_sub_1d(xf, filter, ds)
	sig_length = size(xf,1);

	if isnumeric(filter)
		% simple Fourier transform
		filter_j = sum(reshape(filter,[sig_length length(filter)/sig_length]),2);
		yf = bsxfun(@times, xf, filter_j);
	elseif isstruct(filter)
		% optimized filter, output of OPTIMIZE_FILTER
		if strcmp(filter.type,'fourier_multires')
			% periodized multiresolution filter, output of PERIODIZE_FILTER
			yf = bsxfun(@times, xf, filter.coefft{1+log2(filter.N/sig_length)});
		elseif strcmp(filter.type,'fourier_truncated')
			% truncated filter, output of TRUNCATE_FILTER
			coefft = filter.coefft;
			nCoeffts = length(coefft);
			j = log2(nCoeffts/sig_length);
			if j > 0
				% filter is larger than signal, so zero-pad the latter
				xf = [xf(1:end/2,:); zeros(nCoeffts-sig_length,size(xf,2)); ...
					xf(end/2+1:end,:)];
			end
			if filter.start<=0
				% filter support starts in negative frequencies, extract
				% negative frequencies of signal
				yf = bsxfun(@times, ...
					xf([end+filter.start:end 1:nCoeffts+filter.start-1],:), ...
					filter.coefft);
			else
				% filter support starts in positive frequencies, only extract
				% positive frequencies of signal
				yf = bsxfun(@times, ...
					xf(filter.start:nCoeffts+filter.start-1,:), ...
					filter.coefft);
			end
			
			if filter.recenter
				% result has been shifted in frequency so that the zero fre-
				% quency is actually at -filter.start+1
				yf = circshift(yf,filter.start-1);
			end
		end
	else
		error('Unsupported filter type');
	end
	
	% calculate the downsampling factor with respect to yf
	dsj = ds+log2(size(yf,1)/sig_length);
	if dsj > 0 
		% actually downsample, so periodize in Fourier
		yf_ds = reshape( ...
			sum(reshape(yf,[size(yf,1)/2^dsj 2^dsj size(yf,2)]),2), ...
			[size(yf,1)/2^dsj size(yf,2)]);
	elseif dsj < 0
		% upsample, so zero-pad in Fourier
		yf_ds = [yf; zeros((2^(-dsj)-1)*length(yf),size(yf,2))];
	end

	y_ds = ifft(yf_ds)/2^(ds/2);
end