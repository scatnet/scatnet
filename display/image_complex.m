% IMAGE_COMPLEX Return a color image that for a complex 2d signal.
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
%    Compute a color image corresponding to a complex 2d signal.
%    The saturation corresponds to the complex modulus while the hue
%    corresponds to the complex argument.
%
% See also
%    DISPLAY_FILTER_BANK_2D_COMPLEX, IMAGE_COMPLEX_CELL
function x_rgb = image_complex(x)	
	x = x / max(abs(x(:)) + 1e-10);
	x_hsv(:,:,1) = (pi + 1e-5 + angle(x)) / (2*pi);
	x_hsv(:,:,2) = abs(x);
	x_hsv(:,:,3) = 1;
	x_rgb = hsv2rgb(x_hsv);
end

