% SPARSITY_FEATURE Measures the L1/L2 ratio of a segment
%
% Usage
%    t = sparsity_feature(x, obj);
%

function t = sparsity_feature(x, obj)
	for l = 1:length(obj)
		t(l) = sum(sum(abs(x(obj(l).u1+1:obj(l).u2)), 1), 2)./sqrt(sum(sum(abs(x(obj(l).u1+1:obj(l).u2)).^2, 1), 2));
	end

	t = reshape(t, [1 1 length(obj)]);
end
