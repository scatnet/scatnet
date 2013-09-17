% mean_renorm_scat: Renormalize scattering coefficients by the mean over
%    coefficients with the same parent.
% Usage
%    S = mean_renorm_scat(S)
% Input
%    S: A scattering transform.
% Output
%    S: The renormalized scattering transform.

function X = mean_renorm_scat(X,p)
	if nargin < 2
		p = 1;
	end
	
	for m = 0:length(X)-1
		js = unique(X{m+1}.meta.j(1:m-1,:)','rows')';
		if isfield(X{m+1}.meta,'theta')
			thetas = unique(X{m+1}.meta.theta(1:m-1,:)','rows')';
		else
			thetas = 0;
		end
		for k = 1:size(js,2)*size(thetas,2)
			parent_j = js(1:m-1,floor((k-1)/size(thetas,2))+1);
			j_mask = all(bsxfun(@eq,X{m+1}.meta.j(1:m-1,:),parent_j),1);
			if isfield(X{m+1}.meta,'theta')
				parent_theta = thetas(1:m-1,mod((k-1),size(thetas,2))+1);
				theta_mask = all(bsxfun(@eq,X{m+1}.meta.theta(1:m-1,:), ...
					parent_theta),1);
			else
				theta_mask = true(size(j_mask));
			end
			
			p2s = find(j_mask&theta_mask);
			
			sz = size(X{m+1}.signal{p2s(1)});
			if length(sz) < 3
				sz = [sz ones(1,3-length(sz))];
			end
			
			siblings = zeros([sz,length(p2s)]);
			for r = 1:length(p2s)
				siblings(:,:,:,r) = X{m+1}.signal{p2s(r)};
			end
			
			for p2 = p2s
				X{m+1}.signal{p2} = X{m+1}.signal{p2}./(sum(siblings.^p,4).^(1/p));
			end
		end
	end
end
