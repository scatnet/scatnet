% this script demonstrates the sensitivity of roto-translation scatterin
% to curvature

N = 128;
options.J = 4;
options.antialiasing = 10;
options_rot.meyer_rot = 1;
W_rt_meyer = wavelet_factory_3d([N,N], options, options_rot);

x = zeros(N,N);
x(N/2,:) = 1;
tic;
S_rt_meyer = scat(x, W_rt_meyer);
toc;
img_s_line = image_scat_layer(S_rt_meyer{3},0,0);

%%

%%
for radius = 1:N/2
	%% circle
	
	radius = 32;
	sigma_radius = 1;
	x = draw_circle([N,N], [N/2, N/2], radius, sigma_radius);
	imagesc(x);
	pause(0.1);
	
	
	%% roto-translation scattering with meyer wavelet along the angle
	options.null = 1;
	options_rot.meyer_rot = 1;
	tic;
	
	S_rt_meyer = scat(x, W_rt_meyer);
	
	img = image_scat_layer(S_rt_meyer{3},0,0);
	filename = sprintf('s_rt_3_radius_%d.png',radius);
	imwriteBW([img,img_s_line],filename);
	toc;
	radius
end