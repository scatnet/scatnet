function filt = display_filter_spatial(filtf, n, rorim)
% function filt = display_filter_spatial(filtf, n, rorim)
% displays and returns the spatially centered cropped version of a filters
%
% inputs :
% - filtf : <NxM double> the fourier transform of the filter
% - n : <1x1 int> the size of the window we want to look at
% - rorim : [optional] <string> real or imaginary part ('r' or 'i')
%
% outputs :
% - filt : the spatially centered cropped version of the filter

if ~exist('rorim','var')
  rorim='r';
end

[H, W] = size(filtf);
filt = fftshift(ifft2(filtf));
filt = (filt(floor(H/2)-n+1:floor(H/2)+n+1,floor(W/2)-n+1:floor(W/2)+n+1));
switch rorim
  case 'r'
    imagesc(real(filt));
  case 'i'
    imagesc(imag(filt));
end
