% this script demonstrates the rotation invariance 
% of the roto-translation scattering

x = uiuc_sample;
x = x(128:128+255, 128:128+255);

filt_opt.null = 1;
filt_rot_opt.null = 1;
% oversampling must be set to infty
% so that scattering of original and rotated
% image will be sampled at exactly the same points
scat_opt.oversampling = 10;

Wop = wavelet_factory_3d_pyramid(size(x), filt_opt, filt_rot_opt, scat_opt);

% compute scattering of x
Sx = scat(x, Wop);
sx_raw = format_scat(Sx);

% compute scattering of x rotated by pi/2
x_rot = rot90(x,1);
Sx_rot = scat(x_rot, Wop);
sx_rot_raw = format_scat(Sx_rot);

% rotate back every layer of output
for p = 1:size(sx_rot_raw,1)
	 tmp = rot90(squeeze(sx_rot_raw(p,:,:)), -1);
	 sx_rot_raw_back(p,:,:) = permute(tmp, [3, 1, 2]);
end

% compute norm ratio
norm_diff = sqrt(sum((sx_rot_raw_back(:)-sx_raw(:)).^2));
norm_s = sqrt(sum((sx_raw(:)).^2));
norm_ratio = norm_diff/norm_s
