%% a script to reproduce table 1 of RSDS paper :
%
% REFERENCE :
%   ``Rotation, Scaling and Deformation Invariant Scattering
%   for Texture Discrimination"
%   Laurent Sifre, Stephane Mallat
%   Proc. IEEE CVPR 2013 Portland, Oregon
%
%
% DOWNLOAD : The KTH-TIPS database can be downloaded at
%   http://www.nada.kth.se/cvap/databases/kth-tips/kth_tips_grey_200x200.tar



%% load the database
clear; close all;
% NOTE : the following line must be modified with the path to the
% KTH-TIPS database in YOUR system.
path_to_db = '/Users/laurentsifre/TooBigForDropbox/Databases/KTH_TIPS';
src = kthtips_src(path_to_db);
db_name = 'kth_tips';


grid_train = [5, 20, 40]; % number of training for classification
nb_split = 10; % number of split for classification

%% ---------------------------------------------------
%% ----------------- trans_scatt ---------------------
%% ---------------------------------------------------


%% compute scattering of all images in the database

%configure scattering
filt_opt = struct();
scat_opt.J = 5; % number of octaves

% build the wavelet transform operators for scattering
Wop = wavelet_factory_2d_pyramid(filt_opt, scat_opt);

% a function handle that
%   - read the image
%   - resize it to 200x200
%   - compute its scattering
fun = @(filename)(scat(imresize_notoolbox(imreadBW(filename)...
    ,[200 200]), Wop));

% compute all scattering
% (500 seconds on a 2.4 Ghz Intel Core i7)
trans_scatt_all = srcfun(fun, src);
%%
% a function handle that
%   - format the scattering in a 3d matrix
%   - remove order 0
%   - remove margins along dimension 2 and 3
%   - average accross position
% (10 seconds on a 2.4 Ghz Intel Core i7)
fun = @(Sx)(mean(mean(remove_margin(format_scat(Sx),[1,0,1,1,1,1]),2),3));
trans_scatt = cellfun_monitor(fun ,trans_scatt_all);


% format the database of feature
db = cellsrc2db(trans_scatt, src);

%% classification
rsds_classif(db, db_name, 'trans_scatt', grid_train, nb_split);
% exepected output :
%
% kth_tips trans_scatt with  5 training : 66.91 += 4.47
% kth_tips trans_scatt with 20 training : 91.44 += 1.67
% kth_tips trans_scatt with 40 training : 96.46 += 1.04


%% ---------------------------------------------------
%% --------------- roto_trans_scatt ------------------
%% ---------------------------------------------------





%% compute scattering of all images in the database

% configure scattering
scat_opt.J = 5; % number of octaves
filt_opt = struct();
filt_rot_opt = struct();

% build the wavelet transform operators for scattering
Wop = wavelet_factory_3d_pyramid(filt_opt, filt_rot_opt, scat_opt);

% a function handle that
%   - read the image
%   - resize it to 200x200
%   - compute its scattering
fun = @(filename)...
    (scat(imresize_notoolbox(imreadBW(filename),[200 200]), Wop));
% (800 seconds on a 2.4 Ghz Intel Core i7)
roto_trans_scatt_all = srcfun(fun, src);

% a function handle that
%   - format the scattering in a 3d matrix
%   - remove margins
%   - average accross position
fun = @(Sx)(mean(mean(remove_margin(format_scat(Sx),[1,0,1,1,1,1]),2),3));
% (10 seconds on a 2.4 Ghz Intel Core i7)
roto_trans_scatt = cellfun_monitor(fun ,roto_trans_scatt_all);

% format the database of feature
db = cellsrc2db(roto_trans_scatt, src);

%% classification
rsds_classif(db, db_name, feature_name, grid_train, nb_split);





%% ---------------------------------------------------
%% ------------- roto_trans_scatt_log ----------------
%% ---------------------------------------------------




feature_name = 'roto_trans_scatt_log';
precomputed_filename = ...
    sprintf('%s/%s/%s.mat',path_to_precomputed, db_name, feature_name);
if (use_precomputed_scattering)
    load(precomputed_filename);
else
    % a function handle that
    %   - format the scattering in a 3d matrix
    %   - take the logarithm
    %   - remove margins along dimension 2 and 3
    %   - average accross position
    fun = @(Sx)(mean(mean(remove_margin(log(format_scat(Sx)),[1,0,1,1,1,1]),2),3));
    roto_trans_scatt_log = cellfun_monitor(fun ,roto_trans_scatt_all);
    
    %save scattering
    save(precomputed_filename);
end
% format the database of feature
db = cellsrc2db(roto_trans_scatt_log, src);

%% classification
rsds_classif(db, db_name, feature_name, grid_train, nb_split);






%% ---------------------------------------------------
%% ---------- roto_trans_scatt_log_scale_avg ---------
%% ---------------------------------------------------







%% compute scattering of all images in the database

feature_name = 'roto_trans_scatt_log_scale_avg';
precomputed_filename = ...
    sprintf('%s/%s/%s.mat',path_to_precomputed, db_name, feature_name);
if (use_precomputed_scattering)
    load(precomputed_filename);
else
    % configure scattering
    options.J = 5; % number of octaves
    options.Q = 1; % number of scales per octave
    options.M = 2; % scattering orders
    
    % build the wavelet transform operators for scattering
    Wop = wavelet_factory_3d_pyramid(options, options, options);
    
    % a function handle that compute scattering given an image
    fun = @(x)(scat(x, Wop));
    
    % another function handle that
    %   - read the image
    %   - resize it to 200x200
    %   - apply fun to all scaled version of the image
    multi_fun = @(filename)(fun_multiscale(fun, ...
        imresize_notoolbox(imreadBW(filename),[200 200]), sqrt(2), 4));
    
    % (2748 seconds on a 2.4 Ghz Intel Core i7)
    roto_trans_scatt_multiscale = srcfun(multi_fun, src);
    
    %% log + spatial average
    fun = @(Sx)(mean(mean(log(remove_margin(format_scat(Sx),1,[2,3])),2),3));
    multi_fun = @(x)(cellfun_monitor(fun, x));
    roto_trans_scatt_multiscale_log_sp_avg = ...
        cellfun_monitor(multi_fun, roto_trans_scatt_multiscale);
    
    %% scale average
    fun = @(x)(mean(cell2mat(x),2));
    roto_trans_scatt_log_scale_avg = ...
        cellfun_monitor(fun, roto_trans_scatt_multiscale_log_sp_avg);
    
    % save scattering
    save(precomputed_filename, 'roto_trans_scatt_log_scale_avg');
    
    % format the database of feature
    db = cellsrc2db(roto_trans_scatt_log_scale_avg, src);
end

%% classification
rsds_classif(db, db_name, feature_name, grid_train, nb_split);





%% ---------------------------------------------------
%% - roto_trans_scatt_log_scale_avg_multiscal_train --
%% ---------------------------------------------------


% TODO



