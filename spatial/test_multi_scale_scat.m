%% spatial
src = uiuc_src;
options.J = 5;
options.Q = 1;
options.M = 2;

options.parallel = 0;
Wop = wavelet_factory_3d_pyramid(options, options,options);
%fun = @(filename)(scat(imreadBW(filename), Wop));
fun = @(x)(scat(x, Wop));
multi_fun = @(filename)(fun_multiscale(fun, imreadBW(filename), sqrt(2), 4));
all_feat = srcfun(multi_fun, src);


%%


% %% renorm L1/L2 with smoothing 
% op = renorm_factory_L2_smoothing(3);
% renorm = @(x)(renorm_sibling_3d(x, op));
% feat_renorm = cellfun_monitor(renorm, all_feat);


% %% log renorm
renorm = @(x)(scatfun(@log, x));
renorm_ms = @(x)(cellfun_monitor(renorm, x));
feat_renorm = cellfun_monitor(renorm_ms, all_feat);


%% sibling L2 renorm

op = renorm_factory_L2_smoothing(0);
renorm = @(x)(renorm_sibling_2d(x, op));
renorm_ms = @(x)(cellfun_monitor(renorm, x));
feat_renorm = cellfun_monitor(renorm_ms, all_feat);
%%
% no remorm
feat_renorm = all_feat;
% %% renorm parent
%%renorm = @(x)(renorm_parent_3d(x));
%%feat_renorm = cellfun_monitor(renorm, all_feat);

%% spatial average 
vec = @(Sx)(mean(mean(remove_margin(format_scat(Sx),1),2),3));
vec_ms = @(x)(cellfun_monitor(vec, x));
feat_vec = cellfun_monitor(vec_ms, feat_renorm);

%% scale concatenate
scale_concat = @(x)(cell2mat(x'));
feat_space_scale_concat = cellfun_monitor(scale_concat, feat_vec);
db = cellsrc2db(feat_space_scale_concat, src);
%% scale average
scale_avg = @(x)(mean(cell2mat(x),2));

feat_space_scale_avg = cellfun_monitor(scale_avg, feat_vec);
% format for classif

db = cellsrc2db(feat_space_scale_avg, src);
figure(1);
imagesc(db.features);
%% keep only first scale

keep_first_scale = @(x)(x{1});
feat_space_avg_first_scale = cellfun_monitor(keep_first_scale, feat_vec);
db = cellsrc2db(feat_space_avg_first_scale, src);
figure(2);
imagesc(db.features);


%%
close all;
figure(1);
image_scat_layer(all_feat{990}{1}{2},0,0);

figure(2);
image_scat_layer(all_feat{990}{2}{2},0,0);
