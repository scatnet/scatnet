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
%   - psi.filter{p}.type : <string> 'fourier_multires'
%   - psi.filter{p}.coefft{res+1} : <?x? double> the fourier transform
%                          of the p high pass filter at resolution res
%   - psi.meta.k(p,1)     : its scale index
%   - psi.meta.theta(p,1) : its orientation scale
%   - phi.filter.type     : <string>'fourier_multires'
%   - phi.filter.coefft
%   - phi.meta.k(p,1)

%   - meta : <1x1 struct> global parameters of the filter bank

options.null = 1;

v = getoptions(options,        'v',        1); % number of scale per octave
nb_scale = getoptions(options, 'nb_scale', 4); % total number of scales
nb_angle = getoptions(options, 'nb_angle', 8); % number of orientations

sigma_phi  = getoptions(options, 'sigma_phi',   0.8);
sigma_psi  = getoptions(options, 'sigma_psi',  0.8);
xi_psi     = getoptions(options, 'xi_psi',     3*pi/4);
slant_psi  = getoptions(options, 'slant_psi',  0.5);

res_max = floor(nb_scale/v);

% compute low pass filters phi
phi.filter.type = 'fourier_multires';

% compute all resolution of the filters
for res = 0:res_max
  
  N = ceil(size_in(1) / 2^res);
  M = ceil(size_in(2) / 2^res);
  scale = 2^((nb_scale-1) / v - res);
  filter_spatial =  gabor_2d(N, M, sigma_phi*scale, 1, 0, 0);
  phi.filter.coefft{res+1} = fft2(filter_spatial);
  phi.meta.k = nb_scale + 1;
  
  littlewood_final = zeros(N, M);
  % compute high pass filters psi
  angles = (0:nb_angle-1)  * pi / nb_angle;
  p = 1;
  for k = 1:nb_scale
    for theta = 1:numel(angles)
      
      psi.filter{p}.type = 'fourier_multires';
      
      angle = angles(theta);
      scale = 2^((k-1)/v - res);
      if (scale >= 1)
        filter_spatial = morlet_2d_noDC(N, ...
          M,...
          sigma_psi*scale,...
          slant_psi,...
          xi_psi/scale,...
          angle) ;
        psi.filter{p}.coefft{res+1} = fft2(filter_spatial);
        littlewood_final = littlewood_final + abs(psi.filter{p}.coefft{res+1}).^2;
      end
      
      psi.meta.k(p,1) = k;
      psi.meta.theta(p,1) = theta;
      p = p + 1;
    end
  end
  
  % second pass : renormalize psi by max of littlewood paley to have
  % an almost unitary operator
  % NOTE : phi must not be renormalized since we want its mean to be 1
  K = max(littlewood_final(:));
  for p = 1:numel(psi.filter)
    if (numel(psi.filter{p}.coefft)>=res+1)
      psi.filter{p}.coefft{res+1} = psi.filter{p}.coefft{res+1} / sqrt(K/2);
    end
  end
end

filters.phi = phi;
filters.psi = psi;

filters.meta.v = v;
filters.meta.nb_scale = nb_scale;
filters.meta.nb_angle = nb_angle;
filters.meta.sigma_phi = sigma_phi;
filters.meta.sigma_psi = sigma_psi;
filters.meta.xi_psi = xi_psi;
filters.meta.slant_psi = slant_psi;

end
