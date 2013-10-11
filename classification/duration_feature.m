% DURATION_FEATURE Calculate the log-duration of an object
%
% Usage
%    duration = DURATION_FEATURE(x, object)
%
% Input
%    x (numeric): The file data (not used).
%    object (struct): The objects contained in the data.
%
% Output
%    duration (numeric): The log-duration of the objects.
%
% See also
%    PREPARE_DATABASE

function t = duration_feature(x, object)
	t = permute(log([object.u2]-[object.u1]+1),[1 3 2]);
end
