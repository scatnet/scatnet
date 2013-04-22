function [S, U] = scatt(x, cascade)
% function [S, U] = scat(x, cascade)
% S{m+1} contains the averaged scattering vector of order m
% U{m+1} contains the unaveraged scattering vector of order m

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
