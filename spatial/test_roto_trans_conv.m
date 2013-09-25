
filt_opt.null = 1;
scat_opt.null = 1;
scat_opt = fill_struct(scat_opt, 'M', 2);

precision = getoptions(scat_opt, 'precision', 'single');
% filters :
filters = morlet_filter_bank_2d_pyramid(filt_opt);

% filters along angular variable
sz = filters.meta.L * 2; % L orientations between 0 and pi
% periodic convolutions along angles
filt_rot_opt.boundary = 'per';
filt_rot_opt.filter_format = 'fourier_multires';
filt_rot_opt.J = 3;
filt_rot_opt.P = 0;
filt_rot_opt.Q = 1;
filters_rot = morlet_filter_bank_1d(sz, filt_rot_opt);
if strcmp(precision,'single')
	filters_rot = singlify_filter_bank(filters_rot);
end


%%
Y = rand(64, 64, 8);

z1 = filters.g.filter;
z2 = filters_rot.psi.filter{1};
%%

Z = roto_trans_conv(Y, 'dirac', filters_rot.psi.filter{1})
