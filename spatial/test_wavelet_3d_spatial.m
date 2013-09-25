
filters = morlet_filter_bank_2d_pyramid();

sz = filters.meta.L * 2; % L orientations between 0 and pi
% periodic convolutions along angles
filt_rot_opt.boundary = 'per';
filt_rot_opt.filter_format = 'fourier_multires';
filt_rot_opt.J = 3;
filt_rot_opt.P = 0;
filters_rot = morlet_filter_bank_1d(sz, filt_rot_opt);

y = rand(480,640,8);
options.angular_range = 'zero_pi';
options.J = 4;


%%
profile on;
options.j_min = 1;
[y_Phi, y_Psi] = wavelet_3d_spatial(y, filters, filters_rot, options);
profile off;

%%

%% low pass only
y = rand(480,640,4);
options.angular_range = 'zero_2pi';
y_Phi = wavelet_3d_spatial(y, filters, filters_rot, options);
