% WAVELET_FACTORY_3D_PYRAMID Build roto-translation wavelet operators
%
% Usage
%   [Wop, filters, filters_rot] = WAVELET_FACTORY_3D_PYRAMID(filt_opt, filt_rot_opt, scat_opt)
%
% Input
%    filt_opt (struct): the filter options, same as for MORLET_FILTER_BANK_2D_PYRAMID
%    filt_rot_opt (struct): the filter options for the
%		filters along angular parameter, same as for MORLET_FILTER_BANK_1D
%	 scat_opt (struct): the scattering and wavelet options, same as
%		WAVELET_LAYER_3D_PYRAMID
%
% Output
%    Wop: A cell array of wavelet transforms needed for the scattering trans-
%       form.
%    filters: A cell array of the filters used in defining the wavelets.
%
% Description
%   This function builds the wavelet operators used to compute the
%   roto-translation scattering. The first operator is a 2d wavelet
%   transform obtained with WAVELET_LAYER_2D_PYRAMID. The second operator and third
%   operators are roto-translation wavelet transform obtained with
%   WAVELET_LAYER_3D_PYRAMID.
%   Compared to WAVELET_FACTORY_3D this function is faster because it uses
%   a pyramid algorithm and spatial convolution whereas WAVELET_FACTORY_3D
%   uses FFT-based convolution
%
% See also
%   SCAT, WAVELET_2D_PYRAMID, WAVELET_LAYER_2D_PYRAMID, WAVELET_3D_PYRAMID,
%   WAVELET_3D_LAYER_PYRAMID
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
    for m = 2:scat_opt.M+1
        Wop{m} = @(x)(wavelet_layer_3d_pyramid(x, filters, filters_rot, wavelet_opt));
    end
    
end

