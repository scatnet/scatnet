function out = downsampling_2d(x,ds,preserve_l2_norm)
if (~exist('preserve_l2_norm','var'))
  preserve_l2_norm =1;
end

if (preserve_l2_norm==1)
  out = 2^ds * x(1:2^ds:end,1:2^ds:end);
else
  out = x(1:2^ds:end,1:2^ds:end);
end
end