%% spatial
src = uiuc_src;
options.J = 6;
options.Q = 2;
options.M = 2;

options.parallel = 0;
w = wavelet_factory_3d_spatial(options, options, options);
features{1} = @(x)(sum(sum(format_scat(scat(x,w)),2),3));
%%
%features{1} = @(x)(sum(sum(format_scat(renorm_scat_spatial(scat(x,w))),2),3));
% log before final avg
%features{1} = @(x)(sum(sum(log(format_scat(scat(x,w))),2),3));
db = prepare_database(src, features, options);


%%
% save feature

%% classif with 200 randomn partition and size 5 10 20
db.features = double(db.features);
grid_train = [5,10,20];
n_fold = 10;
clear error_2d;
clear train_opt
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/40;
		[train_set, test_set] = create_partition(src, prop);
		%train_opt.dim = n_train;
        train_opt.C = 8*8;
        train_opt.kernel_type = 'linear';
        train_opt.gamma = 10e-6;
		model = svm_train(db, train_set, train_opt);
		labels = svm_test(db, model, test_set);
		error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
		fprintf('fold %d n_train %g acc %g \n',i_fold, n_train, 1-error_2d(i_fold, i_grid));
	end
end
mean(error_2d)
 %0.5327    0.4545    0.3454
%%
mean(error_2d)

%vs pca
clear train_opt
grid_train = [5,10,20];
n_fold = 10;
clear error_2d;
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/40;
		[train_set, test_set] = create_partition(src, prop);
		train_opt.dim = n_train;
        %train_opt.kernel_type = 'gaussian';
		model = affine_train(db, train_set, train_opt);
		labels = affine_test(db, model, test_set);
		error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
		fprintf('fold %d n_train %g acc %g \n',i_fold, n_train, 1-error_2d(i_fold, i_grid));
	end
end
mean(error_2d)
%  0.5070    0.3837    0.2364


%%
% max renorm all coefft
maxfeat = max(db.features, [], 2);
db2 = db;

db2.features = double(bsxfun(@rdivide, db.features, maxfeat));
%% linear svm with max renorm
grid_train = [5,10,20];
n_fold = 10;
clear error_2d;
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/40;
		[train_set, test_set] = create_partition(src, prop);
		%train_opt.dim = n_train;
        train_opt.C = 1000;
        train_opt.kernel_type = 'linear';
        train_opt.gamma = 10e-2;
		model = svm_train(db2, train_set, train_opt);
		labels = svm_test(db2, model, test_set);
		error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
		fprintf('fold %d n_train %g acc %g \n',i_fold, n_train, 1-error_2d(i_fold, i_grid));
	end
end
mean(error_2d)

%% gaussian svm with max renorm

grid_train = [5,10,20];
n_fold = 10;
clear error_2d;
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/40;
		[train_set, test_set] = create_partition(src, prop);
		%train_opt.dim = n_train;
        train_opt.C = 1000;
        train_opt.kernel_type = 'gaussian';
        train_opt.gamma = 10e-2;
		model = svm_train(db2, train_set, train_opt);
		labels = svm_test(db2, model, test_set);
		error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
		fprintf('fold %d n_train %g acc %g \n',i_fold, n_train, 1-error_2d(i_fold, i_grid));
	end
end
mean(error_2d)

%% pca with max renorm

clear train_opt
grid_train = [5,10,20];
n_fold = 10;
clear error_2d;
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/40;
		[train_set, test_set] = create_partition(src, prop);
		train_opt.dim = n_train;
        %train_opt.kernel_type = 'gaussian';
		model = affine_train(db2, train_set, train_opt);
		labels = affine_test(db2, model, test_set);
		error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
		fprintf('fold %d n_train %g acc %g \n',i_fold, n_train, 1-error_2d(i_fold, i_grid));
	end
end
mean(error_2d)
%  0.3971    0.2189    0.0948

%%
% independant l1 renorm (per example) + max renorm (per feature)
db3 = db;
localsum  = sum(db.features);
tmp = bsxfun(@rdivide, db.features, localsum);
tmp = bsxfun(@rdivide, tmp, max(tmp,[],2));
db3.features = tmp;

grid_train = [5,10,20];
n_fold = 10;
clear error_2d;
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/40;
		[train_set, test_set] = create_partition(src, prop);
		%train_opt.dim = n_train;
        train_opt.C = 2*8;
        train_opt.kernel_type = 'gaussian';
        train_opt.gamma = 10e-2;
		model = svm_train(db3, train_set, train_opt);
		labels = svm_test(db3, model, test_set);
		error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
		fprintf('fold %d n_train %g acc %g \n',i_fold, n_train, 1-error_2d(i_fold, i_grid));
	end
end
mean(error_2d)
%   0.5592    0.5335    0.5100
% C1000
%   0.4817    0.3604    0.2550
% C10000000
%   0.3822    0.2487    0.1436
%C = 1000000000;
%    0.3934    0.2519    0.1268
%
% C2
% 
%
%gamma = 1;

%% pca with max renorm

clear train_opt
grid_train = [5,10,20];
n_fold = 10;
clear error_2d;
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/40;
		[train_set, test_set] = create_partition(src, prop);
		train_opt.dim = n_train;
        %train_opt.kernel_type = 'gaussian';
		model = affine_train(db3, train_set, train_opt);
		labels = affine_test(db3, model, test_set);
		error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
		fprintf('fold %d n_train %g acc %g \n',i_fold, n_train, 1-error_2d(i_fold, i_grid));
	end
end
mean(error_2d)

