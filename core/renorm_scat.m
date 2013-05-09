% renorm_scat: Renormalize a scattering transform.
% Usage
%    S = renorm_scat(S)
% Input
%    S: A scattering transform.
% Output
%    S: The scattering transform with second- and higher-order coefficients
%       divided by their parent coefficients.

function X = renorm_scat(X,epsilon,min_order)
	if nargin < 2
		epsilon = 2^(-20);		% ~1e-6
	end
	
	if nargin < 3
		min_order = 2;
	end
	
	for m = length(X)-1:-1:min_order
		for p2 = 1:length(X{m+1}.signal)
			j = X{m+1}.meta.j(:,p2);
			p1 = find(all(bsxfun(@eq,X{m}.meta.j,j(1:m-1)),1));
			sub_multiplier = 2^(X{m}.meta.resolution(p1)/2);
			X{m+1}.signal{p2} = X{m+1}.signal{p2}./(X{m}.signal{p1}+epsilon*sub_multiplier);
		end
	end
end
