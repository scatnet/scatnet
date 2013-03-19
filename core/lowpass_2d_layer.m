function out = lowpass_2d_layer(previous_layer, filters, downsampler, options)
% function out = lowpass_2d_layer(previous_layer, filters, downsampler, options)
%
% apply spatial averaging to a scattering layer
%
%
if (numel(previous_layer.sig)==0)
  out.sig = {};
  return
end
options.null = 1;
preserve_l2_norm = getoptions(options,'preserve_l2_norm',1);
J = numel(filters.psi{1});
for p = 1:numel(previous_layer.sig)
  % retrieve current signal and meta data
  x     = previous_layer.sig{p};
  res   = previous_layer.meta.res(p, :);
  lastres  = res(end);
  % lowpass filter
  ax = ifft2( fft2(x) .* filters.phi{lastres + 1} );
  % downsampling
  ds = downsampler(J,lastres);
  out.sig{p} = downsampling_2d(ax, ds,preserve_l2_norm);
  out.meta.res(p, :) = [res, lastres + ds];
end
% copy meta data that did not change
out.meta.j = previous_layer.meta.j;
out.meta.theta = previous_layer.meta.theta;
end