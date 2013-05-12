% duration_feature: Calculate the log-duration of a segment.
% Usage
%    duration = duration_feature(x, object)
% Input
%    x: The file data (not used).
%    object: The objects contained in the data.
% Output
%    duration: The log-duration of the objects.

function t = duration_feature(x, object)
	t = permute(log([object.u2]-[object.u1]+1),[1 3 2]);
end
