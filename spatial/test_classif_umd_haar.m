%% spatial
src = umd_src;
options.J = 6;
options.M = 2;

options.type = 'haar';
options.parallel = 0;
w = wavelet_factory_2d_spatial(options, options);
features{1} = @(x)(sum(sum(format_scat(scat(x,w)),2),3));
%features{1} = @(x)(sum(sum(format_scat(renorm_scat_spatial(scat(x,w))),2),3));
db = prepare_database(src, features, options);


%% classif with 200 randomn partition and size 5 10 20
grid_train = [5,10,20];
n_fold = 10;
clear error_2d;
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/40;
		[train_set, test_set] = create_partition(src, prop);
		train_opt.dim = n_train;
		model = affine_train(db, train_set, train_opt);
		labels = affine_test(db, model, test_set);
		error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
		fprintf('fold %d n_train %g acc %g \n',i_fold, n_train, 1-error_2d(i_fold, i_grid));
	end
end

%UMD PCA
% haar J = 5 (360 s to compute)
%    0.8693    0.9589    0.9884
% haar J = 6 (450 s to compute)
%    0.8770    0.9544    0.9866
 
