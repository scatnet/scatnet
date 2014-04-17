% PIXELIFY_IMAGE Repeat successively the values of an image.
%    
% Usage
%	x_rgb = IMAGE_COMPLEX(x)
%
% Input
%    x (complex 2d matrix): the signals to be displayed
%
% Output
%    x_rgb (numeric): a color image of the signal.
%
% Description
%    Repeat successively the values of an image to make its pixel
%    appear crispy. Usefull to avoid linear interpolation in third parties
%    software that tends to make the filters blury.
%
% See also
%    DISPLAY_FILTER_BANK_2D_COMPLEX, IMAGE_COMPLEX_CELL
function img_pixelified = pixelify_image(img, fac)
    
    switch numel(size(img))
        case 2
            [n, m] = size(img);
            N = n * fac;
            M = m * fac;
            [x, y] = meshgrid(1:m, 1:n);
            [X, Y] = meshgrid(...
                floor( (0:M-1) * m / M ) + 1, ...
                floor( (0:N-1) * n / N ) + 1);
            img_pixelified = interp2(x, y, img, X, Y, 'nearest');
        case 3
            [n, m, p] = size(img);
            N = n * fac;
            M = m * fac;
            [x, y, z] = meshgrid(1:m, 1:n, 1:p);
            [X, Y, Z] = meshgrid(...
                floor( (0:M-1) * m / M ) + 1, ...
                floor( (0:N-1) * n / N ) + 1,...
                1:p);
            img_pixelified = interp3(x, y, z, img, X, Y, Z, 'nearest');
        otherwise
            error('input is not a 2d or 3d image.');
            
    end
end