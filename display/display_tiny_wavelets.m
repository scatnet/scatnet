function [] = display_tiny_wavelets(filters)
L = numel(filters.psi);
for l = 0:L-1
  subplot(5,1,l+1);
  psi_spatial_centered = fftshift(ifft(filters.psi{l+1}));
  plot([real(psi_spatial_centered); imag(psi_spatial_centered)]');
  legend(sprintf('real psi %d', l), sprintf('imag psi %d', l));
end
subplot(5,1,5);
phi_spatial_centered = fftshift(ifft(filters.phi));
plot(phi_spatial_centered);
legend(sprintf('phi %d', L));
end