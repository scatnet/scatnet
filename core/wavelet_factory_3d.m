% WAVELET_FACTORY_3D Build roto-translation wavelet operators
%
% Usage
%   [Wop, filters, filters_rot] = WAVELET_FACTORY_3D(size_in, filt_opt, filt_rot_opt, scat_opt)
%
% Input
%    size_in (2x1 int): the size of the image to be transformed
%    filt_opt (struct): the filter options, same as for MORLET_FILTER_BANK_2D 
%    filt_rot_opt (struct): the filter options for the 
%		filters along angular parameter, same as for MORLET_FILTER_BANK_1D 
%	 scat_opt (struct): the scattering and wavelet options, same as
%		WAVELET_LAYER_3D 
%
% Output
%    Wop: A cell array of wavelet transforms needed for the scattering trans-
%       form.
%    filters: A cell array of the filters used in defining the wavelets.
%
% Description
%   This function builds the wavelet operators used to compute the 
%   roto-translation scattering. The first operator is a 2d wavelet
%   transform obtained with WAVELET_LAYER_2D. The second operator and third
%   operators are roto-translation wavelet transform obtained with
%   WAVELET_LAYER_3D.
%
% See also
%   SCAT, WAVELET_2D, WAVELET_LAYER_2D, WAVELET_3D, WAVELET_3D_LAYER


function [ Wop, filters, filters_rot ] = ...
		wavelet_factory_3d(size_in, filt_opt, filt_rot_opt, scat_opt)
	
    % initialize the non-provided options with empty structure
    if (nargin < 4)
        scat_opt = struct();
    end
    if (nargin < 3)
        filt_rot_opt = struct();
    end
    if (nargin < 2)
        filt_opt = struct();
    end
	
	% filters along spatial variable
	filters = morlet_filter_bank_2d(size_in, filt_opt);
	
	% filters along angular variable
	sz = filters.meta.L * 2; % L orientations between 0 and pi
	% periodic convolutions along angles
	filt_rot_opt.boundary = 'per';
	filt_rot_opt.filter_format = 'fourier_multires';
	filt_rot_opt.J = 3;
	filt_rot_opt.P = 0;
	filters_rot = morlet_filter_bank_1d(sz, filt_rot_opt);
	
	% number of layer
	scat_opt = fill_struct(scat_opt, 'M', 2);
    wav_opt = rmfield(scat_opt, 'M');
	
	% first wavelet transform is an usual wavelet transform
	Wop{1} = @(x)(wavelet_layer_2d(x, filters, wav_opt));
	
	% other wavelet transform are roto-translation wavelet
	for m = 2:scat_opt.M+1
		Wop{m} = @(x)(wavelet_layer_3d(x, filters, filters_rot, wav_opt));
	end
end

