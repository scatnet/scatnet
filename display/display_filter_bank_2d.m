% DISPLAY_FILTER_2D Display all the fine-resolution filters of the filter 
% bank and returns the result to display
%
% Usage
%	big_img = DISPLAYER_FILTER_BANK_2D(filters, n, renorm)
%
% Input
%    filters (cell of struct): filter banke from a wavelet factory (for 
%    instance).
%    n (numeric): cropping size, only for 'fourier_multires' type of
%    function
%    r (bool): renormalize the filters for display or not.
%
% Output
%    filt_for_disp (numerical): displayed (real) image.
%
% Description
%    Display the real or imaginary part of a filter bank and returns it.
% 
% See also
% DISPLAY_FILTER_2D

function big_img = display_filter_bank_2d(filters, n, renorm)
if (~exist('n','var'))
  n = min(32, floor(min(filters.meta.size_in)/2 -1));
end
if (~exist('renorm','var'))
  renorm = 1;
end

margin = 4;
N = 2*n+1;
N_margin = N + margin;
J = filters.meta.J;
L = filters.meta.L;
big_img = ones(N_margin*J, (2*L+1)*N_margin);


% low pass : first on the left
filt_for_disp = display_filter_2d(filters.phi.filter,'r', n);
M = max(abs(filt_for_disp(:)));
if (renorm == 0)
  M = 1;
end
big_img((1:N), (1:N)) = real(filt_for_disp)/M;
big_img((1:N)+N_margin ,(1:N)) = imag(filt_for_disp)/M;

% band pass : following filters
for p = 1:numel(filters.psi.filter)
  filter = filters.psi.filter{p};
  filt_for_disp = display_filter_2d(filter,'r', n);
  M = max(abs(filt_for_disp(:)));
  if (renorm == 0)
    M = 1;
  end
  
  j = filters.psi.meta.j(p);
  theta = filters.psi.meta.theta(p);
  
  big_img((1:N)+ j*N_margin, (1:N) + (theta)*N_margin) = ...
    real(filt_for_disp)/M;
  big_img((1:N)+ j*N_margin, (1:N) + (theta+L)*N_margin) = ...
    imag(filt_for_disp)/M;
end

imagesc(big_img);