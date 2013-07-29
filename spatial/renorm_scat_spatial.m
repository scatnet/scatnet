function Sx_rn = renorm_scat_spatial(Sx)
	Sx_rn = Sx;
	parent = @(p)(find(Sx{2}.meta.j(1,:) == Sx{3}.meta.j(1,p) &...
		Sx{2}.meta.theta(1,:) == Sx{3}.meta.theta(1,p)));
	for p = 1:numel(Sx{3}.signal)
		Sx_rn{3}.signal{p} = Sx_rn{3}.signal{p}./Sx{2}.signal{parent(p)};
	end
	
end