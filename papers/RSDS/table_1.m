% a script to reproduce table 1 of paper :
%
%   ``Rotation, Scaling and Deformation Invariant Scattering
%   for Texture Discrimination"
%   Laurent Sifre, Stephane Mallat
%   Proc. IEEE CVPR 2013 Portland, Oregon
%
% Scattering classification rates for KTH-TIPS databases
%
% NOTE THAT MAY SAVE YOU A LOT OF TIME : computing the scattering for the
% whole database takes time. We provide precomputed scattering in the files
%   precomputed/kth-tips/trans_scatt.mat
%   precomputed/kth-tips/roto_trans_scatt.mat
%   precomputed/kth-tips/roto_trans_scatt_log.mat
%   precomputed/kth-tips/roto_trans_scatt_log_scale_avg.mat
%   precomputed/kth-tips/roto_trans_scatt_log_scale_avg_multiscal_train.mat
% If you want to save time, you can load those files into MATLAB workspace
% and proceed directly to the classification step.
%
% DOWNLOAD : The KTH-TIPS databased can be downloaded at
%   http://www.nada.kth.se/cvap/databases/kth-tips/kth_tips_grey_200x200.tar



%% load the database
clear; close all;
% WARNING : the following line must be modified with the path to the
% KTH-TIPS database in YOUR system.
path_to_db = '/Users/laurentsifre/TooBigForDropbox/Databases/KTH_TIPS';
src = kthtips_src(path_to_db);

use_precompted_scattering = 1; % change to 0 to skip computation of scattering


%% ---------------------------------------------------
%% ----------------- trans_scatt ---------------------
%% ---------------------------------------------------


%% compute scattering of all images in the database
if (use_precompted_scattering)
    load('./precomputed/kth-tips/trans_scatt.mat');
else
    %configure scattering
    options.J = 5; % number of octaves
    options.Q = 1; % number of scales per octave
    options.M = 2; % scattering orders
    
    % build the wavelet transform operators for scattering
    Wop = wavelet_factory_2d_spatial(options, options);
    
    % a function handle that
    %   - read the image
    %   - resize it to 200x200
    %   - compute its scattering
    fun = @(filename)(scat(imresize_notoolbox(imreadBW(filename)...
        ,[200 200]), Wop));
    
    % compute all scattering
    % (500 seconds on a 2.4 Ghz Intel Core i7)
    trans_scatt_all = srcfun(fun, src);
    
    % a function handle that
    %   - format the scattering in a 3d matrix
    %   - remove margins
    %   - average accross position
    % (10 seconds on a 2.4 Ghz Intel Core i7)
    fun = @(Sx)(mean(mean(remove_margin(format_scat(Sx),1),2),3));
    trans_scatt = cellfun_monitor(fun ,trans_scatt_all);
    
    % save scattering
    %save('./precomputed/kth-tips/trans_scatt.mat', 'trans_scatt');
    
    % format the database of feature
    db = cellsrc2db(trans_scatt, src);
    
end

%% classification
grid_train = [5,20,40];
n_per_class = 81;
n_fold = 10; % Note : very similar results can be obtained with 200 folds.
clear error_2d;

for i_fold = 1:n_fold
    for i_grid = 1:numel(grid_train)
        n_train = grid_train(i_grid);
        prop = n_train/n_per_class ;
        [train_set, test_set] = create_partition(src, prop);
        train_opt.dim = n_train;
        model = affine_train(db, train_set, train_opt);
        labels = affine_test(db, model, test_set);
        error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
        fprintf('fold %d n_train %g acc %g \n', ...
            i_fold, n_train, 1-error_2d(i_fold, i_grid));
    end
end

%% averaged performance
perf = 100*(1-mean(error_2d));
perf_std = 100*std(error_2d);

for i_grid = 1:numel(grid_train)
    fprintf('kth-tips trans scatt with %2d training : %.2f += %.2f \n', ...
        grid_train(i_grid), perf(i_grid), perf_std(i_grid));
end
% expected output :
%   kth-tips trans scatt with  5 training : 69.84 += 3.40
%   kth-tips trans scatt with 20 training : 95.03 += 1.08
%   kth-tips trans scatt with 40 training : 98.10 += 0.79



%% ---------------------------------------------------
%% --------------- roto_trans_scatt ------------------
%% ---------------------------------------------------



%% compute scattering of all images in the database
if (use_precompted_scattering)
    load('./precomputed/kth-tips/roto_trans_scatt.mat');
else
    % configure scattering
    options.J = 5; % number of octaves
    options.Q = 1; % number of scales per octave
    options.M = 2; % scattering orders
    
    % build the wavelet transform operators for scattering
    Wop = wavelet_factory_3d_spatial(options, options, options);
    
    % a function handle that
    %   - read the image
    %   - resize it to 200x200
    %   - compute its scattering
    fun = @(filename)(scat(imresize_notoolbox(imreadBW(filename),[200 200]), Wop));
    % (800 seconds on a 2.4 Ghz Intel Core i7)
    roto_trans_scatt_all = srcfun(fun, src);
    
    % a function handle that
    %   - format the scattering in a 3d matrix
    %   - remove margins
    %   - average accross position
    fun = @(Sx)(mean(mean(remove_margin(format_scat(Sx),1),2),3));
    % (10 seconds on a 2.4 Ghz Intel Core i7)
    roto_trans_scatt = cellfun_monitor(fun ,roto_trans_scatt_all);
    
    % save scattering
    %save('./precomputed/kth-tips/roto_trans_scatt.mat', 'roto_trans_scatt');
    
    % format the database of feature
    db = cellsrc2db(roto_trans_scatt, src);
end

%% classification
grid_train = [5,20,40];
n_per_class = 81;
n_fold = 10; % Note : very similar results can be obtained with 200 folds.
clear error_2d;

for i_fold = 1:n_fold
    for i_grid = 1:numel(grid_train)
        n_train = grid_train(i_grid);
        prop = n_train/n_per_class ;
        [train_set, test_set] = create_partition(src, prop);
        train_opt.dim = n_train;
        model = affine_train(db, train_set, train_opt);
        labels = affine_test(db, model, test_set);
        error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
        fprintf('fold %d n_train %g acc %g \n', ...
            i_fold, n_train, 1-error_2d(i_fold, i_grid));
    end
end

%% averaged performance
perf = 100*(1-mean(error_2d));
perf_std = 100*std(error_2d);

for i_grid = 1:numel(grid_train)
    fprintf('kth-tips roto-trans scatt with %2d training : %.2f += %.2f \n', ...
        grid_train(i_grid), perf(i_grid), perf_std(i_grid));
end
% expected output :
%   kth-tips roto-trans scatt with  5 training : 71.01 += 3.51
%   kth-tips roto-trans scatt with 20 training : 94.80 += 1.15
%   kth-tips roto-trans scatt with 40 training : 99.29 += 0.54







%% ---------------------------------------------------
%% ------------- roto_trans_scatt_log ----------------
%% ---------------------------------------------------





if (use_precompted_scattering)
    load('./precomputed/kth-tips/roto_trans_scatt_log.mat');
else
    % a function handle that
    %   - format the scattering in a 3d matrix
    %   - take the logarithm
    %   - remove margins
    %   - average accross position
    fun = @(Sx)(mean(mean(log(remove_margin(format_scat(Sx),1)),2),3));
    roto_trans_scatt_log = cellfun_monitor(fun ,roto_trans_scatt_all);
    
    %save scattering
    save('./precomputed/kth-tips/roto_trans_scatt_log.mat', 'roto_trans_scatt_log');
    
    % format the database of feature
    db = cellsrc2db(roto_trans_scatt_log, src);
end

%% classification
grid_train = [5,20,40];
n_per_class = 81;
n_fold = 10; % Note : very similar results can be obtained with 200 folds.
clear error_2d;

for i_fold = 1:n_fold
    for i_grid = 1:numel(grid_train)
        n_train = grid_train(i_grid);
        prop = n_train/n_per_class ;
        [train_set, test_set] = create_partition(src, prop);
        train_opt.dim = n_train;
        model = affine_train(db, train_set, train_opt);
        labels = affine_test(db, model, test_set);
        error_2d(i_fold, i_grid) = classif_err(labels, test_set, src);
        fprintf('fold %d n_train %g acc %g \n', ...
            i_fold, n_train, 1-error_2d(i_fold, i_grid));
    end
end

%% averaged performance
perf = 100*(1-mean(error_2d));
perf_std = 100*std(error_2d);

for i_grid = 1:numel(grid_train)
    fprintf('kth-tips roto-trans scatt with %2d training : %.2f += %.2f \n', ...
        grid_train(i_grid), perf(i_grid), perf_std(i_grid));
end
% expected output :
%   kth-tips roto-trans scatt with  5 training : 77.97 += 3.03 
%   kth-tips roto-trans scatt with 20 training : 97.33 += 0.66 
%   kth-tips roto-trans scatt with 40 training : 99.29 += 0.41 




