function t = duration_feature(x,segment)
	t = permute(log([segment.u2]-[segment.u1]+1),[1 3 2]);
end
