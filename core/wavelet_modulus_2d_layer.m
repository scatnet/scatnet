function out = wavelet_modulus_2d_layer(previous_layer, filters, downsampler, next_bands, options)
% function out = wavelet_modulus_2d(x, filters, downsampler, options)
%
% apply wavelet transform and complex modulus to a scattering layer 
%
% inputs :
% - previous_layer : <1x1 struct> : contains the following fields :
%   - sig{p}          : the image of the p-th path of the input layer
%   - meta.j(p,:)     : the sequence of j (log-a of scale) corresponding to this path
%   - meta.theta(p,:) : the sequence of theta (orientation) corresponding to this path
%   - meta.res(p,:)   : the sequence of log2 of resolution corresponding to this path
% - filters : <1x1 struct> : contains the following fields :
%   - psi : <nested cell> : filters.psi{res+1}{j+1}{th} contains
%       the fourier transform of high pass filter at resolution res, 
%       scale a^j and orientation index th
%   - phi : <nested cell> : filters.phi{res+1} contains
%       the fourier transform of low pass filter at resolution res
%       and scale a^J
% - downsampler : <function_handle> : returns the log2 of the downsampling step
%   as a function of next j (log-a of scale) and previous resolution
% - options : [optional] <1x1 struct> : may contain :
%   - preserve_l2_norm : [optional] <1x1 bool> wether the downsampling
%     should preserves the L2 norm of the signal.
%
% output :
% - out : <1x1 struct> : contains the following fields :
%   - sig{p}          : the image of the p-th path of the output layer
%   - meta.j(p,:)     : the sequence of j (log-a of scale) corresponding to this path
%   - meta.theta(p,:) : the sequence of theta (orientation) corresponding to this path
%   - meta.res(p,:)   : the sequence of log2 of resolution corresponding to this path

options.null = 1;
preserve_l2_norm = getoptions(options,'preserve_l2_norm', 1);
L = numel(filters.psi{1}{1});
nextp = 1;
for p = 1:numel(previous_layer.sig)
  % retrieve current signal and meta data
  x     = previous_layer.sig{p};
  res   = previous_layer.meta.res(p, :);
  j     = previous_layer.meta.j(p, :);
  theta = previous_layer.meta.theta(p, :);
  lastj    = j(end);
  lastres  = res(end);
  
  nb = next_bands(lastj);
  if (numel(next_bands)>0) % otherwise no need to compute the fft of x
    xf = fft2(x);
    for nextj = nb;
      for nexttheta = 1:L
        % wavelet modulus
        ux = abs(ifft2(xf .* filters.psi{lastres+1}{nextj+1}{nexttheta}));
        % downsampling
        ds = downsampler(nextj, lastres);
        out.sig{nextp} = downsampling_2d(ux, ds, preserve_l2_norm);
        % store meta
        out.meta.j(nextp, :) = [j, nextj];
        out.meta.theta(nextp, :) = [theta, nexttheta];
        out.meta.res(nextp, :) = [res, lastres + ds];
        nextp = nextp + 1;
      end
    end
  end
end
if (~exist('out','var'))
  out.sig = {};
end
end
