% RENORM_SCAT Renormalize a scattering coefficients by their parents
%
% Usage
%    S = renorm_scat(S)
%
% Input
%    S: A scattering transform.
%
% Output
%    S: The scattering transform with second- and higher-order coefficients
%       divided by their parent coefficients.

function X = renorm_scat(X, epsilon, min_order)
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
			sub_multiplier = 2^(X{m+1}.meta.resolution(p2)/2);
			ds = log2(size(X{m}.signal{p1},1)/size(X{m+1}.signal{p2},1));
			if ds > 0
				parent = X{m}.signal{p1}(1:2^ds:end,:,:)*2^(ds/2);
			else
				parent = interpft(X{m}.signal{p1},size(X{m}.signal{p1},1)*2^(-ds))*2^(-ds/2);
			end
			X{m+1}.signal{p2} = X{m+1}.signal{p2}./(parent+epsilon*sub_multiplier);
		end
	end
end
