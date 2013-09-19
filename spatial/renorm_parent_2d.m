function Sx_rn = renorm_parent_2d(Sx)
	Sx_rn = Sx;
	if (isfield(Sx{2}.meta, 'theta')) %2d scat
		parent = @(p)(find(Sx{2}.meta.j(1,:) == Sx{3}.meta.j(1,p) &...
			Sx{2}.meta.theta(1,:) == Sx{3}.meta.theta(1,p) & ...
            Sx{2}.meta.q(1,:) == Sx{3}.meta.q(1,p)));
	else % 3d scat
		parent = @(p)(find(Sx{2}.meta.j(1,:) == Sx{3}.meta.j(1,p)));
	end
	for p = 1:numel(Sx{3}.signal)
		Sx_rn{3}.signal{p} = Sx_rn{3}.signal{p}./Sx{2}.signal{parent(p)};
	end
	
end