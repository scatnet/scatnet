% default_filter_options: Provides default options for filters
% Usage
%    filt_opt = default_filter_options(filter_type, averaging_size)
% Input
%    filter_type: Either 'image' (for images), 'audio' (for audio signals) or
%       'dyadic' (for other, less oscillatory, 1D signals)
%    averaging_size: The desired averaging size of the lowpass filters, that 
%       is, the maximal scale of the wavelets.
% Output
%    filt_opt: A set of filter options to be given to the filter_bank or 
%       wavelet_factory_Xd functions

function filt_opt = default_filter_options(filter_type, averaging_size)
	if strcmp(filter_type, 'image')
		filt_opt.J = log2(averaging_size);
	elseif strcmp(filter_type, 'audio')
		filt_opt.Q = [8 1];
		filt_opt.J = T_to_J(averaging_size, filt_opt);
	elseif strcmp(filter_type, 'dyadic')
		filt_opt.Q = 1;
		filt_opt.J = T_to_J(averaging_size, filt_opt);
	end
end