function filters = gabor_filter_bank_2d_all_low_pass(size_in, options)
% function filters = gabor_filter_bank_2d_all_low_pass(size_in, options)
%
% builds a filter bank to compute littlewood-paley
% wavelet transform 
%
% inputs : same as gabor_filter_bank_2d 
%
% outputs : same as gabor_filter_bank_2d, plus :
% - filters.phi_allscale{res+1}{j+1} : <nested cell> the fourier transform 
%     of low pass filter at resolution res and scale a^j

options.null = 1;
filters = gabor_filter_bank_2d(size_in,options);
J = filters.infos.J;
a = filters.infos.a;
sigma0 = filters.infos.sigma0;
K = filters.infos.K;

for res = 0:floor(log2(a)*(J-1  +1 ))
  for j = floor(res/log2(a)):J
    N=ceil(size_in(1)/2^res);
    M=ceil(size_in(2)/2^res);
    
    scale=a^(j-1)*2^(-res);
    phif = sqrt(2)*fft2(gabor_2d(N,M,sigma0*scale,1,0,0));%no slant for low freq
    
    filters.phi_allscale{res+1}{j+1} = phif /sqrt(K);
  end
end