function X = renorm_scatt(X,epsilon,min_order)
	if nargin < 2
		epsilon = 2^(-20);		% ~1e-6
	end
	
	if nargin < 3
		min_order = 2;
	end
	
	for m = length(X)-1:-1:min_order
		for p2 = 1:length(X{m+1}.signal)
			scale = X{m+1}.meta.scale(p2,:);
			p1 = find(all(bsxfun(@eq,X{m}.meta.scale,scale(1:m-1)),2));
			sub_multiplier = 2^(X{m}.meta.resolution(p1)/2);
			X{m+1}.signal{p2} = X{m+1}.signal{p2}./(X{m}.signal{p1}+epsilon*sub_multiplier);
		end
	end
end