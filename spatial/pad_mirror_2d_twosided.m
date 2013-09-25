function x_pad = pad_mirror_2d_twosided(x, marg)
	x = [x(marg(1)+1:-1:2,:); x; x(end-1:-1:end-marg(1),:)];
	x_pad = [x(:,marg(2)+1:-1:2), x, x(:,end-1:-1:end-marg(2))];
end
