function out = lowpass_2d_layer(previous_layer, filters, downsampler, options)
% function out = lowpass_2d_layer(previous_layer, filters, downsampler, options)
%
% apply spatial averaging to a scattering layer
%
% inputs :
% - previous_layer : <1x1 struct> : contains the following fields :
%   - sig{p}          : the image of the p-th path of the input layer
%   - meta.j(p,:)     : the sequence of j (log-a of scale) corresponding to this path
%   - meta.theta(p,:) : the sequence of theta (orientation) corresponding to this path
%   - meta.res(p,:)   : the sequence of log2 of resolution corresponding to this path
% - filters : <1x1 struct> contains the following fields
%   - psi{res+1}{j+1}{th} : the fourier transform of high pass filter 
%     at resolution res, scale a^j and orientation index th
%   - phi{res+1}          :  the fourier transform of low pass filter 
%     at resolution res and scale a^J
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