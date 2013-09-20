%% spatial
src = kthtips_src;
options.J = 4;
options.M = 2;

options.type = 'morlet';
options.parallel = 0;
w = wavelet_factory_2d_spatial(options, options);
features{1} = @(x)(sum(sum(format_scat(scat(x,w)),2),3));
%features{1} = @(x)(sum(sum(format_scat(renorm_scat_spatial(scat(x,w))),2),3));
db = prepare_database(src, features, options);

%%
%save
fn = [rpath, '/kth_2d.mat'];
save(fn, 'db');

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

mean(error_2d)
%KTH TIPS - PCA %acc
% haar J = 3
%  0.6587    0.9089    0.1000
% haar J = 4
%  0.7072    0.9285    0.9593
% haar J = 5
%  0.7164    0.9375    0.9602


%%

%% classif with 200 randomn partition and size 5 10 20
grid_train = [5,20,40];
n_fold = 10;
db.features = double(db.features);
clear train_opt;

clear error_2d;
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/81;
		[train_set, test_set] = create_partition(src, prop);
		%train_opt.dim = n_train;
        train_opt.kernel_type = 'linear';
        
        %train_opt.gamma = 10E-12;
		model = svm_train(db, train_set, train_opt);
		labels = svm_test(db, model, test_set);
		error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
		fprintf('fold %d n_train %g acc %g \n',i_fold, n_train, 1-error_2d(i_fold, i_grid));
	end
end
mean(error_2d)


%%
db2 = db;
featmax = max(db.features, [], 2);
db2.features = bsxfun(@rdivide, db.features, featmax);

grid_train = [5,20,40];
n_fold = 10;
clear error_2d;
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/81;
		[train_set, test_set] = create_partition(src, prop);
		train_opt.dim = n_train;
		model = affine_train(db2, train_set, train_opt);
		labels = affine_test(db2, model, test_set);
		error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
		fprintf('fold %d n_train %g acc %g \n',i_fold, n_train, 1-error_2d(i_fold, i_grid));
	end
end

mean(error_2d)

%%
grid_train = [5,20,40];
n_fold = 10;
clear train_opt;

clear error_2d;
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/81;
		[train_set, test_set] = create_partition(src, prop);
		%train_opt.dim = n_train;
        train_opt.kernel_type = 'linear';
        train_opt.C = 100000000;
        
        
		model = svm_train(db2, train_set, train_opt);
		labels = svm_test(db2, model, test_set);
		error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
		fprintf('fold %d n_train %g acc %g \n',i_fold, n_train, 1-error_2d(i_fold, i_grid));
	end
end
mean(error_2d)


%%
% independant l1 renorm (per example) + max renorm (per feature)
db3 = db;
localsum  = sum(db.features);
tmp = bsxfun(@rdivide, db.features, localsum);
tmp = bsxfun(@rdivide, tmp, max(tmp,[],2));
db3.features = tmp;


grid_train = [5,20,40];
n_fold = 10;
clear error_2d;
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/81;
		[train_set, test_set] = create_partition(src, prop);
		train_opt.dim = n_train;
		model = affine_train(db3, train_set, train_opt);
		labels = affine_test(db3, model, test_set);
		error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
		fprintf('fold %d n_train %g acc %g \n',i_fold, n_train, 1-error_2d(i_fold, i_grid));
	end
end

mean(error_2d)


%% svm
clear error_2d;
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/81;
		[train_set, test_set] = create_partition(src, prop);
		%train_opt.dim = n_train;
        train_opt.kernel_type = 'linear';
        train_opt.C = 1000000;
        
        
		model = svm_train(db2, train_set, train_opt);
		labels = svm_test(db2, model, test_set);
		error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
		fprintf('fold %d n_train %g acc %g \n',i_fold, n_train, 1-error_2d(i_fold, i_grid));
	end
end
mean(error_2d)



%% gaussian
clear error_2d;
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/81;
		[train_set, test_set] = create_partition(src, prop);
		%train_opt.dim = n_train;
        train_opt.kernel_type = 'gaussian';
        train_opt.C = 1000000;
        train_opt.gamma = 10-10;
        
        
		model = svm_train(db2, train_set, train_opt);
		labels = svm_test(db2, model, test_set);
		error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
		fprintf('fold %d n_train %g acc %g \n',i_fold, n_train, 1-error_2d(i_fold, i_grid));
	end
end
mean(error_2d)