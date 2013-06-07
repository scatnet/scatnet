src = uiuc_src;
options.J = 5;
options.antialiasing = 0;
w = wavelet_factory_2d([480, 640], options);

features{1} = @(x)(sum(sum(format_scat(scat(x,w)),2),3));
%% this takes about an hour on 2.4 Ghz core i7
options.parallel = 0;
db = prepare_database(src, features, options);
options.J = 5;
options.antialiasing = 0;
w = wavelet_factory_3d([480, 640], options);
features{1} = @(x)(sum(sum(format_scat(scat(x,w)),2),3));

%% this takes about two hour on 2.4 Ghz core i7
options.parallel = 0;
db2 = prepare_database(src, features, options);



%% joint with slog
db3 = db2;
db3.features = log(db2.features);


%% classif with 200 randomn partition and size 5 10 20
grid_train = [5,10,20];
n_fold = 200;
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
		fprintf('fold %d n_train %d error %d \n',i_fold, n_train, error_2d(i_fold, i_grid));
	end
end
%  0.5278    0.6775    0.8379

%% joint scatt
for i = 1:100
	[train_set, test_set] = create_partition(src, 1/2);
	train_opt.dim = 20;
	model = affine_train(db2, ...
		train_set, train_opt);
	
	labels = affine_test(db2, model, ...
		test_set);
	err_3d(i) = classif_err(labels, test_set, src);
	fprintf('fold %d error %d \n',i, err_3d(i));
end


for i = 1:100
	[train_set, test_set] = create_partition(src, 1/8);
	train_opt.dim = 5;
	model = affine_train(db3, ...
		train_set, train_opt);
	
	labels = affine_test(db3, model, ...
		test_set);
	err_3d_log(i) = classif_err(labels, test_set, src);
	fprintf('fold %d correct %d \n',i,100*(1- err_3d_log(i)));
end

