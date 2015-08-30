% EXTRACT_JOINT_VIEW For a fixed j1 and t, extract the j2-fr_j matrix
%
% Usage
%    mat = extract_joint_view(S, j1, t);
%

function [mat, j2, fr_j] = extract_joint_view(S, j1, t)
	ind = [S{3}.meta.j; S{3}.meta.fr_j];
	mat0 = cell2mat(S{3}.signal);

	subset = find(ind(1,:)==j1);

	j2 = unique(ind(2,subset));
	fr_j = unique(ind(3,subset));

	[j2s,fr_js] = ndgrid(j2, fr_j);

	ind = arrayfun( ...
		@(j2,fr_j)(find(all(bsxfun(@eq, [j1; j2; fr_j], ind), 1))), ...
		j2s, fr_js, 'uniformoutput', false);
	ind(cellfun(@isempty,ind)) = 0;
	ind = cell2mat(ind);

	mat = NaN(size(ind));
	mat(ind~=0) = mat0(t, ind(ind~=0));
end

