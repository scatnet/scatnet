% DISPLAY_FILTER_2D Display and return the spatially centered cropped
% version of a filter
%
% Usage
%	filt_for_disp = DISPLAY_FILTER_2D(filter, rorim, n)
%
% Input
%    filter (struct): a filter from a wavelet factory (for instance).
%    rorim (string): 'r' real part, 'i' imaginary part
%    n (numeric): size of the window, only for 'fourier_multires' type of
%    function
%
% Output
%    filt_for_disp (numerical): displayed (real) image.
%
% Description
%    Display the real or imaginary part of a filter and returns it.
% 
% See also
% WAVELET_FACTORY_2D, WAVELET_FACTORY_2D_PYRAMID

function filt_for_disp = display_filter_2d(filter, rorim, n)
if ~exist('rorim','var')
  rorim='r';
end

switch filter.type
  case 'fourier_multires'
    filtf = filter.coefft{1};
    [H, W] = size(filtf);
    filt = fftshift(ifft2(filtf));
    filt_for_disp = (filt(floor(H/2)-n+1:floor(H/2)+n+1,floor(W/2)-n+1:floor(W/2)+n+1));
   case 'spatial_support'
    filt_for_disp = filter.coefft;
  otherwise
    error('not yet supported'); 
end


switch rorim
  case 'r'
    imagesc(real(filt_for_disp));
  case 'i'
    imagesc(imag(filt_for_disp));
end
