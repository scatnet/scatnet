% load an image from uiuc texture database
all_images = retrieve_uiuc(1,1);
x = all_images{1}{1};

% compute its 2d scattering 
tic;
options.feat = 'scatt2d_uiuc';
[feat_f,outmeta,outprecomp] = gfeat(x,options);
toc; % about 20 seconds on a core i7 2.4Ghz

% check number of coefficients : 
% there should be
% 9 (scales) * 8 (orientations) coefficients of order 1
% and
% (7+5+3+1) (scales) * 8^2 (orientations) coefficients of order 2
theoritical_size = 9*8 + (7+5+3+1)*8^2;

assert(numel(feat_f) == theoritical_size);