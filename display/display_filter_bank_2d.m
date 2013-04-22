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

margin = 4;
N = 2*n+1;
N_margin = N + margin;
J = filters.meta.J;
nb_angle = filters.meta.nb_angle;
big_img = ones(N_margin*J, (2*nb_angle+1)*N_margin);


% low pass : first on the left
filt_for_disp = display_filter_2d(filters.phi.filter, n);
M = max(abs(filt_for_disp(:)));
if (renorm == 0)
  M = 1;
end
big_img((1:N), (1:N)) = real(filt_for_disp)/M;
big_img((1:N)+N_margin ,(1:N)) = imag(filt_for_disp)/M;

% high pass
for p = 1:numel(filters.psi.filter)
  filter = filters.psi.filter{p};
  filt_for_disp = display_filter_2d(filter, n);
  M = max(abs(filt_for_disp(:)));
  if (renorm == 0)
    M = 1;
  end
  
  j = filters.psi.meta.j(p);
  theta = filters.psi.meta.theta(p);
  
  big_img((1:N)+ j*N_margin, (1:N) + (theta)*N_margin) = ...
    real(filt_for_disp)/M;
  big_img((1:N)+ j*N_margin, (1:N) + (theta+nb_angle)*N_margin) = ...
    imag(filt_for_disp)/M;
end

imagesc(big_img);