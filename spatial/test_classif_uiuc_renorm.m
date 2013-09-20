%% spatial
src = uiuc_src;
options.J = 5;
options.Q = 1;
options.M = 2;

options.parallel = 0;
Wop = wavelet_factory_2d_spatial(options, options);

%% compute all scattering
fun = @(filename)(scat(imreadBW(filename), Wop));
all_feat = srcfun(fun, src);


%%
%% roto-translation
src = uiuc_src;
options.J = 5;
options.Q = 1;
options.M = 2;

options.parallel = 0;
Wop = wavelet_factory_3d_spatial(options, options, options);

%% compute all scattering
fun = @(filename)(scat(imreadBW(filename), Wop));
all_feat = srcfun(fun, src);



%% renorm L1/L2 with smoothing 
op = renorm_factory_L2_smoothing(3);
renorm = @(x)(renorm_sibling_3d(x, op));
feat_renorm = cellfun_monitor(renorm, all_feat);

% %% log renorm
%renorm = @(x)(scatfun(@log, x));
%feat_renorm = cellfun_monitor(renorm, all_feat);

% %% renorm parent
%%renorm = @(x)(renorm_parent_3d(x));
%%feat_renorm = cellfun_monitor(renorm, all_feat);

% spatial average
vec = @(Sx)(sum(sum(format_scat(Sx),2),3));
feat_vec = cellfun_monitor(vec ,feat_renorm);

% format for classif
db = cellsrc2db(feat_vec, src);

%%
db.features = db.features(2:end,:);
