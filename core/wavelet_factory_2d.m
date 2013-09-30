% WAVELET_FACTORY_2D Create wavelet cascade from morlet filter bank
%
% Usage
%    [Wop, filters] = WAVELET_FACTORY_2D(size_in, filt_opt, scat_opt)
%
% Input
%    size_in (numeric): The size of the signals to be transformed.
%    filt_opt (structure): The filter options, same as for 
%    MORLET_FILTER_BANK_2D
%	 scat_opt (structure): The scattering and wavelet options, identical to
%    WAVELET_LAYER_1D/WAVELET_1D.
%
% Output
%    Wop (cell of function handle): A cell array of wavelet transforms 
%    needed for the scattering trans-
%       form.
%    filters (cell): A cell array of the filters used in defining the wavelets.
%
% Description
%    This function create a cell array of linear operators that will be
%    used for the successive wavelet transforms. Here, only the morlet
%    filter bank is used.
%
%    If M is not specified, its value is set automatically to 2.
%
% See also
%    WAVELET_2D, MORLET_FILTER_BANK_2D 

function [Wop, filters] = wavelet_factory_2d(size_in, filt_opt, scat_opt)
	
    % Options
	filt_opt.null = 1;
	scat_opt.null = 1;
	scat_opt = fill_struct(scat_opt, 'M', 2);
	
	% Create filters
	filters = morlet_filter_bank_2d(size_in, filt_opt);
	
	% Create the wavelet transform to apply at the m-th layer
	for m = 1:scat_opt.M+1
		Wop{m} = @(x)(wavelet_layer_2d(x, filters, scat_opt));
	end
end