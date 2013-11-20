% PAD_SIGNAL Pad a signal
%
% Usage
%    y = PAD_SIGNAL(x, Npad, boundary, center)
%
% Input
%    x (numeric): The signal to be padded.
%    Npad (numeric): The desired size of the padded output.
%    boundary (string): The boundary condition of the signal, one of:
%        'symm': Symmetric boundary condition with half-sample symmetry, for
%             example [1 2 3 4]' -> [1 2 3 4 4 3 2 1]' for Npad = 8
%        'per': Periodic boundary with half-sample symmetry, for example
%             [1 2 3 4]' -> [1 2 3 4 1 2 3 4]' for Npad = 8
%        'zero': Zero boundary, for example
%             [1 2 3 4]' -> [1 2 3 4 0 0 0 0]' for Npad = 8
%        (default 'symm')
%    center (boolean): If true, the signal x is centered in the output y, 
%        otherwise it is located in the (upper) left corner (default false).
%
% Output
%    y (numeric): The padded signal of size Npad
%
% Description
%    The input signal x is padded to give a signal of the size Npad using the 
%    boundary conditions specified in boundary. This has the advantage of
%    reducing boundary effects when computing convolutions by specifying 
%    boundary to be 'symm' or 'zero', depending on the signal. It also allows
%    for convolutions to be calculated on signals smaller than the filter was 
%    originally defined for. Specifically, Npad does not need to be a multiple
%    of size(x). Indeed, if x = [1 2 3 4]', we can have Npad = 11, which gives
%    y = [1 2 3 4 4 3 2 4 3 2 1]'. There is a discontinuity since Npad is not
%    a multiple of 4, but this discontinuity occurs as far from the original 
%    signal, located in indices 1 through 4, as possible.
%
%    The function takes both 1D and 2D inputs.
%
% See Also
%    UNPAD_SIGNAL

function y = pad_signal(x, Npad, boundary, center)
	if nargin < 3 || isempty(boundary)
		boundary = 'symm';
	end

	if nargin < 4
		center = 0;
    end
    
    orig_sz = size(x);
    orig_sz = orig_sz(1:length(Npad));

	if any(orig_sz > Npad)
		error('Original size must be smaller than padding size');
	end

	if center
		margins = floor((Npad - orig_sz)/2);
    end

	has_imag = norm(imag(x(:)))>0;

	for d = 1:length(Npad)
		Norig = size(x,d);

		if strcmp(boundary,'symm')
			ind0 = [1:Norig Norig:-1:1];
			conjugate0 = [zeros(1,Norig) ones(1,Norig)];
		elseif strcmp(boundary,'per')
			ind0 = [1:Norig];
			conjugate0 = zeros(1,Norig);
		elseif strcmp(boundary,'zero')
			ind0 = [1:Norig];
			conjugate0 = zeros(1,Norig);
		else
			error('Invalid boundary conditions!');
		end

		if ~strcmp(boundary,'zero')
			ind = zeros(1,Npad(d));
			conjugate = zeros(1,Npad(d));
			ind(1:Norig) = 1:Norig;
			conjugate(1:Norig) = zeros(1,Norig);
			src = mod([Norig+1:Norig+floor((Npad(d)-Norig)/2)]-1,length(ind0))+1;
			dst = Norig+1:Norig+floor((Npad(d)-Norig)/2);
			ind(dst) = ind0(src);
			conjugate(dst) = conjugate0(src);
			src = mod(length(ind0)-[1:ceil((Npad(d)-Norig)/2)],length(ind0))+1;
			dst = Npad(d):-1:Norig+floor((Npad(d)-Norig)/2)+1;
			ind(dst) = ind0(src);
			conjugate(dst) = conjugate0(src);
		else
			ind = 1:Norig;
			conjugate = zeros(1,Norig);
		end

		if d == 1
			x = x(ind,:,:);
			if has_imag
				x = x-2*i*bsxfun(@times,conjugate.',imag(x));
			end
			if strcmp(boundary,'zero')
				x(Norig+1:Npad(d),:,:) = 0;
			end
		elseif d == 2
			x = x(:,ind,:);
			if has_imag
				x = x-2*i*bsxfun(@times,conjugate,imag(x));
			end
			if strcmp(boundary,'zero')
				x(:,Norig+1:Npad(d),:) = 0;
			end
		end
	end

	if center
		x = circshift(x, margins);
	end

	y = x;
end
