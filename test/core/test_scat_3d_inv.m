% this script demonstrates the rotation covariance-invariance properties
% of roto-translation scattering

x = lena;
x = x(1:256, 1:256);

options.null = 1;
options.antialiasing = 10;

[ wavelet, filters, filters_rot ] = ...
	wavelet_factory_3d(size(x), options);
%%
tic;
[S, U] = scat(x, wavelet);
toc;
%%

x_rot = rot90(x,1);
[S_rot, U_rot] = scat(x_rot, wavelet);

%%

[S_format, meta] = format_scat(S);

S_format_rot = format_scat(S_rot);

%%
clear S_format_rot_back
for p = 1:size(S_format_rot,3)
	S_format_rot_back(:,:,p) = rot90(S_format_rot(:,:,p), -1);
end

%%
norm_diff = sqrt(sum((S_format(:)-S_format_rot_back(:)).^2));
norm_s = sqrt(sum((S_format(:)).^2));
norm_ratio = norm_diff/norm_s

%%
norm_per_path = squeeze(sqrt(sum(sum((S_format-S_format_rot_back).^2,1),2)));

%%
for p = 1:209
	
	imagesc([S_format(:,:,p),S_format_rot_back(:,:,p)])
	pause(0.1);
end