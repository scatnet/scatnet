%% spatial
src = umd_src;
options.J = 6;
options.L = 6;
options.parallel = 0;
w = wavelet_factory_2d_spatial(options, options);
features{1} = @(x)(mean(mean(format_scat(scat(x,w)),2),3));
db = prepare_database(src, features, options);

