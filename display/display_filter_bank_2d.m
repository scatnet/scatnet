function big_img = display_filter_bank_2d(filters, n, renorm)
% function out = display_filter_spatial_all(filters, n, renorm)
% display all the fine-resolution filters of the filter bank
%
% input :
% - filters : <1x1 struct> filter bank typically obtained with
%       gabor_filter_bank_2d.m
% - n : <1x1 int> [optional] the cropping size
% - renorm : <1x1 bool> [optional] renorm all filters for better readability
%
% output :
% - big_img : <?x? double> with all the filters display

if (~exist('n','var'))
  n =32;
end
if (~exist('renorm','var'))
  renorm = 1;
end

N = 2*n+1;
nb_scale = filters.meta.nb_scale;
nb_angle = filters.meta.nb_angle;
big_img = zeros(N*nb_scale, (2*N+1)*nb_angle);

% low pass : first on the left
filt_for_disp = display_filter_2d(filters.phi.filter, n);
M = max(abs(filt_for_disp(:)));
if (renorm == 0)
  M = 1;
end
big_img((1:N), (1:N)) = real(filt_for_disp)/M;
big_img((1:N)+N ,(1:N)) = imag(filt_for_disp)/M;

% high pass
for p = 1:numel(filters.psi)
  filter = filters.psi{p}.filter;
  filt_for_disp = display_filter_2d(filter, n);
  M = max(abs(filt_for_disp(:)));
  if (renorm == 0)
    M = 1;
  end
  
  k = filters.psi{p}.meta.k;
  theta = filters.psi{p}.meta.theta;
  
  big_img((1:N)+ (k-1)*N, (1:N) + N + (theta-1)*N) = ...
    real(filt_for_disp)/M;
  big_img((1:N)+ (k-1)*N, (1:N) + N + (theta-1+nb_angle)*N) = ...
    imag(filt_for_disp)/M;
end

imagesc(big_img);