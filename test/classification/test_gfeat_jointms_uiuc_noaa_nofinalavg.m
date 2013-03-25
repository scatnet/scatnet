% load an image from uiuc texture database
all_images = retrieve_uiuc(1,1);
x = all_images{1}{1};

% compute its 2d scattering 
tic;
options.feat = 'jointms_uiuc_noaa_nofinalavg';
[feat_f,outmeta,outprecomp] = gfeat(x,options);
toc; % about 20 seconds on a core i7 2.4Ghz
%%
% check number of coefficients :
% there should be :
% 9 
% psi psi
% (1+3+5+7)*8*3
% psi phi
% (1+3+5+7)*8
% phi psi
% 5*3
number_of_nodes = 9 + (1+3+5+7)*8*3 + (1+3+5+7)*8 + 5*3;
assert(number_of_nodes == size(feat_f{1},3));