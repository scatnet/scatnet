%% spatial
src = uiuc_src;
options.J = 5;
options.Q = 1;
options.M = 2;

options.parallel = 0;
w = wavelet_factory_2d_spatial(options, options);

%% renorm L1 with smoothing 

options.sigma_phi = 1;
options.P = 4;
filters = morlet_filter_bank_2d_spatial(options);
h = filters.h.filter;
smooth = @(x)(convsub2d_spatial(x, h, 0));
%op = @(x)(smooth(sum(x,3)) + 1E-10);
op = @(x)(sum(x,3));


scat_renorm = @(x)(renorm_sibling_2d(scat(x, w), op));


features{1} = @(x)(sum(sum(format_scat(scat_renorm(x)),2),3));
%%
%features{1} = @(x)(sum(sum(format_scat(renorm_scat_spatial(scat(x,w))),2),3));
% log before final avg
%features{1} = @(x)(sum(sum(log(format_scat(scat(x,w))),2),3));
db = prepare_database(src, features, options);
