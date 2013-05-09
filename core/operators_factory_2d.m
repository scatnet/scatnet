% cascade_factory_2d: Create wavelet cascade operators
%
% Usage
%    cascade = cascade_factory_1d(size_in, options)
%
% Input
%    size_in : <1x2> the size of the signals to be transformed.
%    options : <struct> of optionnal parameters such as :
%      - nb_layer   : <1x1> the number of layers
%      - J          : <1x1> the total number of scale
%      - nb_angle   : <1x1> the number of orientations
%      - margin_in  : <1x2> margin for mirror-padding before scattering
%      - margin_out : <1x2> margin for unpadding after scattering
%    options will be passed to morlet_filter_bank_2d and wavelet_layer_2d
%    an can thus contains any other relevant options for these functions.
%      
% Output
%    cascade : <struct> containing all operators that will be successively
%    apply in the computation of scattering : 
%      - pad : <function_handle> mirror pading to apply before
%      scattering
%      - unpad : <function_handle> unpading to apply after scattering
%      - wavelet{m} : <function_handle> the m-th wavelet operator in the
%      scattering cascade
%      - modulus{m} : <function_handle> the m-th modulus operator in the
%      scattering cascade
%    filters : <struct> the filter bank used by the wavelet transform
%

function [operators, filters] = operators_factory_2d(size_in, options)
	
	options = fill_struct(options, 'nb_layer', 3);
	options = fill_struct(options, 'J', 4);
	options = fill_struct(options, 'antialiasing', 1);
	options = fill_struct(options, 'v', 1);
	
	
	% padding and unpadding:
	default_margin = ...
		2^max(floor(options.J/options.v - options.antialiasing),0) * [1,1];
	
	margin_in = getoptions(options, 'margin_in', default_margin);
	margin_out = getoptions(options, 'margin_out', default_margin);
	
	operators.pad = @(x)(padd_mirror_layer_2d(x, margin_in));
	size_padded = size_in + 2*margin_in;
	operators.unpad = @(x)(unpadd_layer_2d(x, size_padded, margin_out));
	
	% filters :
	filters = morlet_filter_bank_2d(size_padded, options);
	
	% wavelet transforms :
	for m = 1:options.nb_layer
		cascade.wavelet{m} = @(x)(wavelet_layer_2d(x, filters, options));
	end
	
	% modulus :
	for m = 1:options.nb_layer
		cascade.modulus{m} = @(x)(modulus_layer(x));
	end
	
	
	
end
