function out = downsampling_2d(x, ds, preserve_l2_norm)
% function out = downsampling_2d(x, ds, preserve_l2_norm)
%
% downsample a signal
%
% inputs :
% - x  : <NxM double> input image
% - ds : <1x1 int> log of the downsampling step
% - preserve_l2_norm : [optional] <1x1 bool> if 1, output will be rescaled
%   to preserve l2 norm
%
% output :
% - out <?x? double> downsampled image

if (~exist('preserve_l2_norm','var'))
  preserve_l2_norm = 1;
end

if (preserve_l2_norm==1)
  out = 2^ds * x(1:2^ds:end, 1:2^ds:end);
else
  out = x(1:2^ds:end, 1:2^ds:end);
end
end