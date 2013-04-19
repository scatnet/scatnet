function [S, U] = scatt(x, cascade)
% function [S, U] = scatt(x, cascade)
% S{m+1} contains the averaged scattering vector of order m
% U{m+1} contains the unaveraged scattering vector of order m

% init with padded signal
U{1}.signal = cascade.padd(x);
% init meta
U{1}.meta.resolution = 0;
U{1}.meta.scales = [];

% apply scattering 
nb_layer = numel(cascade.wavelet);
for m = 1:nb_layer
  if (m <= nb_layer)
    [S{m}, W] = cascade.wavelet{m}(U{m});
    U{m+1} = cascade.modulus{m}(W);
  else
    S{m} = cascade.wavelet{m}(U{m});
  end
end

% unpadd signals
for m = 1:nb_layer+1
  S{m} = cascade.unpadd(S{m});
  if (m <= nb_layer)
    U{m} = cascade.unpadd(U{m});
  end
end