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
	x = [x(marg(1)+1:-1:2,:); x; x(end-1:-1:end-marg(1),:)];
	x_pad = [x(:,marg(2)+1:-1:2), x, x(:,end-1:-1:end-marg(2))];
end
