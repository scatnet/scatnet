% scatt_energy: Calculate scattering energy.
% Usage
%    energy = scatt_energy(S, U)
% Input
%    S: The scattering transform.
%    U: The wavelet modulus coefficients (optional).
% Output
%    energy: The energy of the scattering transform (the sum of the squares
%    of the coefficients).

function energy = scatt_energy(S, U)
	if nargin < 2
		U = [];
	end
	
	if ~isempty(U)
		energy = scatt_energy(S) + scatt_energy(U);
	else
		if iscell(S)
			energy = 0;
			for m = 1:numel(S)
				energy = energy + scatt_energy(S{m});
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

