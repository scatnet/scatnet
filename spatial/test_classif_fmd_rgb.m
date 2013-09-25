%% spatial
src = fmd_src;
options.J = 5;
options.Q = 1;
options.M = 2;

options.parallel = 0;
w = wavelet_factory_3d_pyramid(options, options, options);

fun = @(x)(sum(sum(format_scat(scat(x, w)),2),3));
% apply to yuv !
%fun = @(x)(sum(sum(format_scat(scat(x), w)),2),3));
rgbfun = @(x)(rgb_fun(x, fun));
%yuvfun = @(x)(yuv_fun(x, fun));

%%
%db = extract_feat(src, yuvfun);
%db = extract_feat(src, yuvfun);
features{1} = fun;
db = prepare_database(src, features, options);

%%
grid_train = 50;
n_fold = 10;
clear error_2d;
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/100;
		[train_set, test_set] = create_partition(src, prop);
		train_opt.dim = n_train;
		model = affine_train(db, train_set, train_opt);
		labels = affine_test(db, model, test_set);
		error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
		fprintf('fold %d n_train %g acc %g \n',i_fold, n_train, 1-error_2d(i_fold, i_grid));
	end
end


%% 
% J=5 Q=1 M=2 
% 0.3126

% J=5 Q=1 M=2 + log
% 0.4134


% J=5 Q=1 M=2 + log + mask
% 0.4278



%% max renorm all coefft
maxfeat = max(db.features, [], 2);
db2 = db;

db2.features = double(bsxfun(@rdivide, db.features, maxfeat));
%% linear svm with max renorm
grid_train = [50];
n_fold = 10;
clear error_2d;
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/100;
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
mean(1-error_2d)

%% gaussian svm with max renorm

grid_train = [50];
n_fold = 10;
clear error_2d;
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/100;
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
grid_train = [50];
n_fold = 10;
clear error_2d;
for i_fold = 1:n_fold
	for i_grid = 1:numel(grid_train)
		n_train = grid_train(i_grid);
		prop = n_train/100;
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
%  0.3971    0.2189    0.09

