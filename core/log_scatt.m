function X = log_scatt(X,epsilon)
	if nargin < 2
		epsilon = 2^(-20);		% ~1e-6
	end
	
	for m = length(X)-1:-1:0
		for p1 = 1:length(X{m+1}.signal)
			sub_multiplier = 2^(X{m+1}.meta.resolution(p1)/2);
			X{m+1}.signal{p1} = log(abs(X{m+1}.signal{p1})+epsilon*sub_multiplier);
		end
	end
end