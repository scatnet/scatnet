% DEFAULT_FILTER_OPTIONS Provides default options for filters
% Usage
%    filt_opt = default_filter_options(filter_type, averaging_size)
% Input
%    filter_type (string): Either 'image' (for images), 'audio' (for audio
%    signals) or 'dyadic'(for other, less oscillatory, 1D signals).
%    averaging_size (numeric): The desired averaging size of the lowpass
%    filters phi, that is, the maximal scale of the wavelets.
% Output
%    filt_opt (struct): A set of filter options to be given to the
%    filter_bank or wavelet_factory_Xd functions.
%
% Description
%    For images, the only compulsory option is J, an integer such that
%    2^J > averaging_size. The quality factor Q is implicitly equal to 1.
%    For audio signals, Q is set to 8 at the first layer, a common value
%    among Mel-frequency filter banks. For other 1D signals (financial
%    times series, physical measurements), Q is set to 1 at all layers,
%    leading to a dyadic wavelet processing. In these two latter cases, J
%    is computed through the utility T_TO_J.
% See also
%   AUDIO_DEMO1, FILTER_BANK, T_TO_J, WAVELET_FACTORY_1D, WAVELET_FACTORY_2D

function filt_opt = default_filter_options(filter_type, averaging_size)
	if strcmp(filter_type, 'image')
		filt_opt.J = ceil(log2(averaging_size));
	elseif strcmp(filter_type, 'audio')
		filt_opt.Q = [8 1];
		filt_opt.J = T_to_J(averaging_size, filt_opt);
	elseif strcmp(filter_type, 'dyadic')
		filt_opt.Q = 1;
		filt_opt.J = T_to_J(averaging_size, filt_opt);
	end
end