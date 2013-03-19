function filters = tiny_wavelets(N, L)
% function filters = tiny_wavelets(N, L)
%
% builds a 1D morlet wavelets filter bank with very small support
% which will act on the rotation parameter
% in the roto-translation joint scattering
%
% inputs :
% - N : <1x1 int> number of sample, should be two times the number of
%   orientation of the 2d oriented wavelets
% - L : <1x1 int> maximum scale
%
% outputs :
% - filters : <1x1 struct> contains the following fields
%   - psi{l+1}: <1xL cell> the fourier transform of 
%       high pass filter at scale 2^l
%   - phi     : <1xN double> the fourier transform of 
%       low pass filter 

sigma0 = 0.7;
xi0 = 3*pi/4;
slant = 1;

% compute wavelet on large support NN and periodize them to avoid
% boundary effects
K = 16;
NN = K*N;
for l=0:L-1
  % normalization scale since morlet_2d are normalized for 2d
  scale=2^l;
  filterlarge=scale*2*sqrt(2*pi*sigma0^2/slant)*morlet_2d(1,NN,sigma0*scale,slant,xi0/scale,0);
  filter=zeros(1,N);
  % sum over the K blocks of size N
  for k=1:K
    filter=filter+filterlarge((1:N)+(k-1)*N);
  end
  filters.psi{l+1}=conj(fft(filter));
end

%normalization scale since morlet_2d are normalized for 2d
scale=2^L;
filterlarge=scale*sqrt(2*pi*sigma0^2/slant)*gabor_2d(1,NN,sigma0*scale,slant,0,0);
filter=zeros(1,N);
for k=1:K
  filter=filter+filterlarge((1:N)+(k-1)*N);
end
filters.phi=conj(fft(filter));
end