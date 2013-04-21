% scatt_1d: Calculate the scattering transform.
% Usage
%    [S,U] = scatt_1d(x, wavemod)
% Input
%    x: The signal to be transformed.
%    wavemod: The wavelet modulus transforms.
% Output:
%    S: The scattering coefficients.
%    U: The wavelet modulus coefficients.

function [S,U] = scatt_1d(x,wavemod)
	N = size(x,1);
	nb_layer = numel(wavemod)-1;

	U{1}.signal = {x};
	U{1}.meta.bandwidth = 2*pi;
	U{1}.meta.resolution = 0;
	U{1}.meta.scale = zeros(1,0);
	
	U{1} = pad_layer_1d(U{1},2*N,'symm');
	
	for m = 1 : nb_layer
		[S{m},U{m+1}] = wavemod{m}(U{m});
	end

	S{nb_layer+1} = wavemod{nb_layer}(U{nb_layer+1});
	
	for m = 1:nb_layer+1
		if nargout >= 2
			U{m} = unpad_layer_1d(U{m},N);
		end
	
		S{m} = unpad_layer_1d(S{m},N);
	end
end
