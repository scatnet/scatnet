function [S, U] = wavemod_2d_fourier_multires(x, filters, downsampler)

xf = fft2(x);

assert(strcmp(filters.phi.filter.type, 'fourier_multires'));
ux = ifft2(xf.*filters.phi.filter.coefft{1});
k = filters.phi.meta.k;

ds = downsampler(k);
ux = downsampling_2d(ux, ds);
S.sig{1} = ux;
S.meta.k = k;

for p = 1:numel(filters.psi.filter)
  
  filt = filters.psi.filter{p};
  assert(strcmp(filt.type, 'fourier_multires'));
  ux = abs(ifft2(xf.*filt.coefft{1}));
  
  k = filters.psi.meta.k(p,1);
  theta = filters.psi.meta.theta(p,1);
  
  ds = downsampler(k);
  ux = downsampling_2d(ux, ds);
  U.sig{p} = ux;
  U.meta.k(p, 1) = k;
  U.meta.theta(p, 1) = theta;
  U.meta.res(p, 1) = ds;
end