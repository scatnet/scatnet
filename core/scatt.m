% scatt : Compute the scattering transform
%
% Usage
%    S = scatt(x, Wavelet) computes the scattering invariant coefficients S
%    [S, U] = scatt(x, Wavelet) computes the scattering invariant
%    coefficients S and the intermediate covariant coefficients U
% 
% Input
%    x : input signal
%    Wavelet : <cell> the Wavelet operators , typically obtained
%       with the provided factory wavelet_factory_1d or wavelet_factory_2d
%
% Output
%    S : contains the invariant scattering vectors
%    S{m}.signal{p} contains the signal corresponding to the 
%        p-th path of the m-th layer of scattering.
%    Sx{m}.meta.j(:,p) contains the succesive scales of the wavelets
%    corresponding to S{m}.signal{p}


function [S, U] = scatt(x, Wavelet)
	
	% init signal and meta
	U{1}.signal{1} = x;
	U{1}.meta.j = zeros(0,1);
	
	% apply scattering
	nb_layer = numel(Wavelet);
	for m = 1:nb_layer
		if (m < nb_layer)
			[S{m}, W] = Wavelet{m}(U{m});
			U{m+1} = modulus_layer(W);
		else
			S{m} = Wavelet{m}(U{m});
		end
	end
	
end
