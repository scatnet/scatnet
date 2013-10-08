% SCAT_ENERGY Calculate scattering energy
%
% Usage
%    energy = scat_energy(S, U)
%
% Input
%    S (cell): The scattering transform.
%    U (cell): The wavelet modulus coefficients (optional).
%
% Output
%    energy (numeric): The energy of the scattering transform (the sum of the 
%       squares of the coefficients). If both S and U are given, the energy of
%       both are computed and summed.

function energy = scat_energy(S, U)
	if nargin < 2
		U = [];
	end
	
	if ~isempty(U)
		energy = scat_energy(S) + scat_energy(U);
	else
		if iscell(S)
			energy = 0;
			for m = 1:numel(S)
				energy = energy + scat_energy(S{m});
			end
		else
			energy = 0;
			for p = 1:numel(S.signal)
				sig = S.signal{p};
				% TODO: fix so that multiple signals work!!
				%sz = size(sig);
				%sig = reshape(sig,[prod(sz(1:end-1)) sz(end)]);
				energy = energy + sum(abs(sig(:)).^2,1);
			end
		end
	end
end

