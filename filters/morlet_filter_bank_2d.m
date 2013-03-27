function filters = morlet_filter_bank_2d(size_in, options)
% function filters = morlet_filter_bank_2d(size_in, options)
%
% builds a filter bank to compute littlewood-paley
% wavelet transform.
%
% inputs :
% - size_in : <1x2 int> size of the input of the scattering
% - options : [optional] <1x1 struct> contains the following optional fields
%   - v              : <1x1 int> the number of scale per octave
%   - nb_scale       : <1x1 int> the total number of scale.
%   - nb_angle       : <1x1 int> the number of orientations
%   - sigma_phi      : <1x1 double> the width of the low pass phi_0
%   - sigma_psi      : <1x1 double> the width of the envelope
%                                   of the high pass psi_0
%   - xi_psi         : <1x1 double> the frequency peak
%                                   of the high_pass psi_0
%   - slant_psi      : <1x1 double> the excentricity of the elliptic
%  enveloppe of the high_pass psi_0 (the smaller slant, the larger
%                                      orientation resolution)
%
% outputs :
% - filters : <1x1 struct> contains the following fields
%   - psi{p}.filter.type : <string> 'fourier_multires'
%   - psi{p}.filter.coefft{res+1} : <?x? double> the fourier transform
%                          of the p high pass filter at resolution res
%   - psi{p}.meta.k     : its scale index
%   - psi{p}.meta.theta : its orientation scale
%   - phi{p}.filter.type : <string>'fourier_multires'
%   - phi{p}.meta.k

%   - meta : <1x1 struct> global parameters of the filter bank

options.null = 1;

v = getoptions(options,        'v',        1); % number of scale per octave
nb_scale = getoptions(options, 'nb_scale', 4); % total number of scales
nb_angle = getoptions(options, 'nb_angle', 8); % number of orientations

sigma_phi  = getoptions(options, 'sigma_phi',   1); 
sigma_psi  = getoptions(options, 'sigma_psi',  0.8);
xi_psi     = getoptions(options, 'xi_psi',     3*pi/4);
slant_psi  = getoptions(options, 'slant_psi',  0.5);

res_max = floor(nb_scale/v);

% compute low pass filters phi
filters.phi.filter.type = 'fourier_multires';
for res = 0:res_max
  N = ceil(size_in(1) / 2^res);
  M = ceil(size_in(2) / 2^res);
  scale = 2^((nb_scale-1) / v);
  filter_spatial = sqrt(2) * gabor_2d(N, M, sigma_phi*scale, 1, 0, 0);
  filters.phi.filter.coefft{res+1} = fft2(filter_spatial);
end

% compute high pass filters psi
angles = (0:nb_angle-1)  * pi / nb_angle;
p = 1;
for k = 1:nb_scale
  for theta = 1:numel(angles)
    angle = angles(theta);
    
    % compute all resolution of the filters
    filters.psi{p}.filter.type = 'fourier_multires';
    for res = 0:res_max
      N = ceil(size_in(1) / 2^res);
      M = ceil(size_in(2) / 2^res);
      scale = 2^((k-1)/v - res);
      if (scale >= 1)
          filter_spatial = morlet_2d_noDC(N, ...
            M,...
            sigma_psi*scale,...
            slant_psi,...
            xi_psi/scale,...
            angle) ;
          filters.psi{p}.filter.coefft{res+1} = fft2(filter_spatial);
       % littlewood_final = littlewood_final + abs(psif{res+1}{j+1}{th}).^2;
      end
    end
    
    filters.psi{p}.meta.k = k;
    filters.psi{p}.meta.theta = theta;
    p = p + 1;
  end
end

filters.meta.v = v;
filters.meta.nb_scale = nb_scale;
filters.meta.nb_angle = nb_angle;
filters.meta.sigma_phi = sigma_phi;
filters.meta.sigma_psi = sigma_psi;
filters.meta.xi_psi = xi_psi;
filters.meta.slant_psi = slant_psi;

end
