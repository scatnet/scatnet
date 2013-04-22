% scatt : Compute the scattering transform
%
% Usage
%    S = scatt(x, cascade) computes the scattering invariant coefficients S
%    [S, U] = scatt(x, cascade) computes the scattering invariant
%    coefficients S and the intermediate covariant coefficients U
% 
% Input
%    x : input signal
%    cascade : <struct> the cascade of operator, typically obtained
%       with the provided factory cascade_factory_1d or cascade_factory_2d
%
% Output
%    S : contains the invariant scattering vectors
%    S{m}.signal{p} contains the signal corresponding to the 
%        p-th path of the m-th layer of scattering.
%    Sx{m}.meta.j(:,p) contains the succesive scales of the wavelets
%    corresponding to S{m}.signal{p}
%   
%      
function [S, U] = scatt(x, cascade)
	
	% init signal and meta
	U{1}.signal{1} = x;
	U{1}.meta.j = zeros(0,1);
	
	U{1} = cascade.pad(U{1});
	
	% apply scattering
	nb_layer = numel(cascade.wavelet);
	for m = 1:nb_layer
		if (m < nb_layer)
			[S{m}, W] = cascade.wavelet{m}(U{m});
			U{m+1} = cascade.modulus{m}(W);
		else
			S{m} = cascade.wavelet{m}(U{m});
		end
	end
	
	% unpadd signals
	for m = 1:nb_layer
		S{m} = cascade.unpad(S{m});
		U{m} = cascade.unpad(U{m});
	end
end
