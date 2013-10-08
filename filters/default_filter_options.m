% DEFAULT_FILTER_OPTIONS Provides default options for filters
%
% Usage
%    filt_opt = DEFAULT_FILTER_OPTIONS(filter_type, averaging_size)
%
% Input
%    filter_type (char): Either 'image' (for images), 'audio' (for audio
%       signals) or 'dyadic' (for other, less oscillatory, 1D signals).
%    averaging_size (numeric): The desired averaging size of the lowpass
%       filter phi, that is, the maximal scale of the wavelets.
%
% Output
%    filt_opt (struct): A set of filter options to be given to the
%        FILTER_BANK, WAVELET_FACTORY_1D or WAVELET_FACTORY_2D functions.
%
% Description
%    For images, Q is set to 1, giving dyadic wavelets, while J is set so that
%    the lowpass filter phi is of size 2^J ~ averaging_size. For audio sig-
%    nals, Q is set to 8 at the first layer, approximating the mel-frequency 
%    scale. For other 1D signals (financial time series, physical measure-
%    ments), Q is set to 1 at all layers, giving dyadic wavelets. In these two
%    cases, J is computed through the utility T_TO_J.
%
% See also
%    AUDIO_DEMO1, FILTER_BANK, T_TO_J, WAVELET_FACTORY_1D, WAVELET_FACTORY_2D

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