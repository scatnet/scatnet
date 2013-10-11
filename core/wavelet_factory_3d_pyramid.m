% WAVELET_FACTORY_3D_PYRAMID Create operators for roto-translation scattering
% Usage
%
% Input
%
% Output
%
% Description
%
% See also
%

function [Wop, filters, filters_rot] = wavelet_factory_3d_pyramid(filt_opt, filt_rot_opt, scat_opt)	
	if (nargin < 3)
        scat_opt = struct();
    end
    if (nargin < 2)
        filt_rot_opt = struct();
    end
    if (nargin < 1)
        filt_opt = struct();
    end
	scat_opt = fill_struct(scat_opt, 'M', 2);
    wavelet_opt = rmfield(scat_opt, 'M');
	
	precision = getoptions(scat_opt, 'precision', 'single');
	% filters :
	filters = morlet_filter_bank_2d_pyramid(filt_opt);
	
	% filters along angular variable
	sz = filters.meta.L * 2; % L orientations between 0 and pi
	% periodic convolutions along angles
	filt_rot_opt.boundary = 'per';
	filt_rot_opt.filter_format = 'fourier_multires';
	filt_rot_opt.J = 3;
	filt_rot_opt.P = 0;
	filt_rot_opt.Q = 1;
	filt_rot_opt.precision = precision;
	filters_rot = morlet_filter_bank_1d(sz, filt_rot_opt);
	
	% first layer : usual 2d wavelet transform
	Wop{1} = @(x)(wavelet_layer_2d_pyramid(x, filters, wavelet_opt));
	Wop{2} = @(x)(wavelet_layer_3d_pyramid(x, filters, filters_rot, wavelet_opt));
	Wop{3} = @(x)(wavelet_layer_3d_pyramid(x, filters, filters_rot, wavelet_opt));
	
end

