function [S, U] = wavemod_2d_fourier_multires(x, filters, downsampler)

xf = fft2(x);

assert(strcmp(filters.phi.filter.type, 'fourier_multires'));
S.sig{1} = ifft2(xf.*filters.phi.filter.coefft{1});

for p = 1:numel(filters.psi)
  psi = filters.psi{p};
  assert(strcmp(psi.filter.type, 'fourier_multires'));
  ux = abs(ifft2(xf.*psi.filter.coefft{1}));
  ds = downsampler(psi.meta.k);
  ux = downsampling_2d(ux, ds);
  U.sig{p} = ux;
  U.meta.k(p, 1) = psi.meta.k;
  U.meta.theta(p, 1) = psi.meta.theta;
  U.meta.res(p, 1) = ds;
end