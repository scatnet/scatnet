%% spatial
src = kthtips_src;
options.J = 3;
options.M = 2;

options.type = 'haar';
options.parallel = 0;
w = wavelet_factory_2d_spatial(options, options);
features{1} = @(x)(sum(sum(format_scat(scat(x,w)),2),3));
%features{1} = @(x)(sum(sum(format_scat(renorm_scat_spatial(scat(x,w))),2),3));
db = prepare_database(src, features, options);


%% classif with 200 randomn partition and size 5 10 20
grid_train = [5,20,40];
n_fold = 10;
clear error_2d;
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/81;
		[train_set, test_set] = create_partition(src, prop);
		train_opt.dim = n_train;
		model = affine_train(db, train_set, train_opt);
		labels = affine_test(db, model, test_set);
		error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
		fprintf('fold %d n_train %g acc %g \n',i_fold, n_train, 1-error_2d(i_fold, i_grid));
	end
end

%KTH TIPS - PCA
% haar J = 3
%  0.6587    0.9089    0.1000
% haar J = 4
%  0.7072    0.9285    0.9593
% haar J = 5
%  0.7164    0.9375    0.9602
