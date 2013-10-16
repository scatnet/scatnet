function X = joint_renorm_scat(X,epsilon)
	if nargin < 2
		epsilon = 2^(-20);		% ~1e-6
	end
	
	for m = 2:2
		fr_J = max(X{m+1}.meta.fr_j);
		J = max(X{m+1}.meta.j(m,:));
		for p2 = 1:length(X{m+1}.signal)
			fr_j = X{m+1}.meta.fr_j(p2);
			j = X{m+1}.meta.j(:,p2);
			if fr_j < fr_J
				p1 = find(all(bsxfun(@eq,X{m+1}.meta.j,[j(1:m-1); J]),1)&(X{m+1}.meta.fr_j==fr_j));
				sub_multiplier = 2^(X{m+1}.meta.resolution(p1)/2);
				X{m+1}.signal{p2} = X{m+1}.signal{p2}./(X{m+1}.signal{p1}+epsilon*sub_multiplier);
			else
				p1 = find(all(bsxfun(@eq,X{m}.meta.j,j(1:m-1)),1));
				sub_multiplier = 2^(X{m}.meta.resolution(p1)/2);
				X{m+1}.signal{p2} = X{m+1}.signal{p2}./(X{m}.signal{p1}+epsilon*sub_multiplier);
			end
		end
	end
end
