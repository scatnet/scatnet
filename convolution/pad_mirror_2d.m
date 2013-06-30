% pad_mirror_2d : Pad an image symetricaly
%
% Usage
%	x_pad = padd_mirror(x, marg) extends the signal x of margin(1)
%	pixels vertically and margin(2) pixels horizontally
%	with mirror reflections of itself
%
% Input
%	x : input image
%	marg : <1,2 int> the vertical and horizontal margins
%
% Output
%	x_pad : the extended image

function x_pad = pad_mirror_2d(x, marg)
	if (numel(x)==1)
		x_pad = repmat(x,[2,2]);
	else
	x = [x; ...
		x(end-1:-1:end-ceil(marg(1)/2),:); ...
		x(floor(marg(1)/2)+1:-1:2,:)];
	x_pad = [x, ...
		x(:,end-1:-1:end-ceil(marg(2)/2)), ...
		x(:,floor(marg(2)/2)+1:-1:2)];
	end
end
