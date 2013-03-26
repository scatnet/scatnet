function filters = morlet_filter_bank_2d(size_in, options)
% function filters = gabor_filter_bank_2d(size_in, options)
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
%   - gab_type       : <string> the kind of wavelets used
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

%a = getoptions(options, 'a', 2); %DEPREC
%J = getoptions(options, 'J', 4); %DEPREC
%L = getoptions(options, 'L', 8); %DEPREC

v = getoptions(options,          'v', 2); % number of scale per octave
nb_k = getoptions(options,       'nb_k', 4); % total number of scales
nb_angle = getoptions(options, 'nb_angle', 8); % number of 
%                                                    orientations


% if isfield(options, 'a') %DEPREC
%   filters.a = a;
% end

gab_type = getoptions(options, 'gab_type', 'morlet_noDC');
sigma0   = getoptions(options, 'sigma0',   1);
slant    = getoptions(options, 'slant',    0.5);
xi00     = getoptions(options, 'xi00',      3*pi/4);
sigma00  = getoptions(options, 'sigma00',  0.8);

switch gab_type
  case 'gabor'
    gab = @gabor_2d;
  case 'morlet'
    gab = @morlet_2d;
  case 'morlet_noDC'
    gab=@morlet_2d_noDC;
end

res_max = floor(nb_k/v);
angles = (0:2*nb_angle-1)  * pi / nb_angle; % DEPREC
p = 1;
for res = 0:res_max
  for k 
  for th = 1:numel(angles)

    
  end
end

% 
% thetas = (0:2*L-1)  * pi / L; % DEPREC
% for res = 0:floor(log2(a)*(J-1))
%   N = ceil(size_in(1)/2^res);
%   M = ceil(size_in(2)/2^res);
%   
%   scale = a^(J-1)*2^(-res);
%   phif{res+1} = sqrt(2)*fft2(gabor_2d(N, M, sigma0*scale, 1, 0, 0));%no slant for low freq
%   
%   %compute high pass filters psif{j}{theta}
%   littlewood_final = abs(phif{res+1}).^2;
%   for j = floor(res/log2(a)):(J-1)
%     for th = 1:numel(thetas);
%       theta = thetas(th);
%       scale = a^j*2^(-res);
%       psif{res+1}{j+1}{th} = ...
%         fft2(gab(N, M, sigma00*scale, slant, xi0/scale,theta) );
%       littlewood_final = littlewood_final + abs(psif{res+1}{j+1}{th}).^2;
%     end
%   end
%   
%   %get max of littlewood paley
%   K=max(max(littlewood_final));
%   % divide filters to have littlewood paley between 1-epsilon and 1
%   phif{res+1}=phif{res+1}/sqrt(K);
%   for j=floor(res/log2(a)):(J-1)
%     for th=1:numel(thetas)/2;
%       psif2{res+1}{j+1}{th}=sqrt(2/K)*psif{res+1}{j+1}{th};
%     end
%   end
%   
%   filters.psi = psif2;
%   filters.phi = phif;
% end
% 
% 
% filters.infos.gab_type = gab_type;
% filters.infos.sigma0 = sigma0;
% filters.infos.sigma00 = sigma00;
% filters.infos.slant = slant;
% filters.infos.xi0 = xi0;
% filters.infos.a = a;
% filters.infos.L = L;
% filters.infos.J = J;
% filters.infos.K = K;

end
