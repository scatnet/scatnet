function filters = gabor_filter_bank_2d(size_in, options)
% function filters = gabor_filter_bank_2d(size_in, options)
%
% builds a filter bank to compute littlewood-paley
% wavelet transform.
%
% inputs :
% - size_in : <2x1 int> : size of the input of the scattering
% - options : [optional] <1x1 struct> containing the following optional options
%   - a : <1x1 double> the dilation factor of wavelet
%   - J : <1x1 int> the maximum scale of wavelets will be a^J
%   - L : <1x1 int> the number of orientations
%   - gab_type : <string> the kind of wavelets used
%   - sigma0 : <1x1 double> the width of the low pass phi_0
%   - sigma00 : <1x1 double> the width of the envelope of the high pass psi_0
%   - xi0 : <1x1 double> the frequency peak of the high_pass psi_0
%   - slant : <1x1 double> the excentricity of the elliptic enveloppe of
%       the high_pass psi_0 (the smaller slant, the larger angular resolution)
%
% outputs :
% - filters : <1x1 struct> : containing the following fields
%   - psi : <nested cell> : filters.psi{res+1}{j+1}{th} contains
%       the fourier transform of high pass filter at resolution res, 
%       scale a^j and orientation index th
%   - phi : <nested cell> : filters.phi{res+1} contains
%       the fourier transform of low pass filter at resolution res
%       and scale a^J
%   - infos : <1x1 struct> : parameters of the wavelets

options.null=1;

a = getoptions(options, 'a', 2);
J = getoptions(options, 'J', 4);
L = getoptions(options, 'L', 8);

if isfield(options, 'a')
  filters.a = a;
end

gab_type = getoptions(options, 'gab_type', 'morlet_noDC');
sigma0 = getoptions(options, 'sigma0', 1);
slant = getoptions(options, 'slant', 0.5);
xi0 = getoptions(options, 'xi0', 3*pi/4);
sigma00=getoptions(options,'sigma00', 0.8);

switch gab_type
  case 'gabor'
    gab = @gabor_2d;
  case 'morlet'
    gab = @morlet_2d;
  case 'morlet_noDC'
    gab=@morlet_2d_noDC;
end


thetas = (0:2*L-1)  * pi / L;
for res = 0:floor(log2(a)*(J-1))
  N = ceil(size_in(1)/2^res);
  M = ceil(size_in(2)/2^res);
  
  scale = a^(J-1)*2^(-res);
  phif{res+1} = sqrt(2)*fft2(gabor_2d(N, M, sigma0*scale, 1, 0, 0));%no slant for low freq
  
  %compute high pass filters psif{j}{theta}
  littlewood_final = abs(phif{res+1}).^2;
  for j = floor(res/log2(a)):(J-1)
    for th = 1:numel(thetas);
      theta = thetas(th);
      scale = a^j*2^(-res);
      psif{res+1}{j+1}{th} = ...
        fft2(gab(N, M, sigma00*scale, slant, xi0/scale,theta) );
      littlewood_final = littlewood_final + abs(psif{res+1}{j+1}{th}).^2;
    end
  end
  
  %get max of littlewood paley
  K=max(max(littlewood_final));
  % divide filters to have littlewood paley between 1-epsilon and 1
  phif{res+1}=phif{res+1}/sqrt(K);
  for j=floor(res/log2(a)):(J-1)
    for th=1:numel(thetas)/2;
      psif2{res+1}{j+1}{th}=sqrt(2/K)*psif{res+1}{j+1}{th};
    end
  end
  
  filters.psi = psif2;
  filters.phi = phif;
end


filters.infos.gab_type = gab_type;
filters.infos.sigma0 = sigma0;
filters.infos.sigma00 = sigma00;
filters.infos.slant = slant;
filters.infos.xi0 = xi0;
filters.infos.a = a;
filters.infos.L = L;
filters.infos.J = J;
filters.infos.K = K;

end
