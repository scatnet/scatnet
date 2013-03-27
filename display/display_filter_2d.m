function filt_for_disp = display_filter_2d(filter, n, rorim)
% function filt = display_filter_spatial(filter, n, rorim)
% displays and returns the spatially centered cropped version of a filters
%
% inputs :
% - filter : <1x1 struct> a filter
% - n : <1x1 int> the size of the window we want to look at
% - rorim : [optional] <string> real or imaginary part ('r' or 'i')
%
% outputs :
% - filt_for_disp : the spatially centered cropped version of the filter

if ~exist('rorim','var')
  rorim='r';
end

switch filter.type
  case 'fourier_multires'
    filtf=  filter.coefft{1};
    [H, W] = size(filtf);
    filt = fftshift(ifft2(filtf));
    filt_for_disp = (filt(floor(H/2)-n+1:floor(H/2)+n+1,floor(W/2)-n+1:floor(W/2)+n+1));
    
  otherwise
    error('not yet supported'); 
end


switch rorim
  case 'r'
    imagesc(real(filt_for_disp));
  case 'i'
    imagesc(imag(filt_for_disp));
end
