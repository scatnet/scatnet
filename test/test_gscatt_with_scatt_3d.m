% this demonstrates the rotation invariance of roto-translation joint
% scattering coefficients S
% - a scattering of an image and its rotated version 
% - the scattering of the rotated image is rotated back to the original
% coordinates
% - the maximum renormalized error is computed
%
% load an image
x = uiuc_sample;
x = x(1:143,1:127);

% compute propagators
options.aa = 10;
propagators = propagators_builder_3d(size(x), options);

% compute scattering
[S, U] = gscatt(x, propagators);

% display image of all renormalized scattering vector
figure(1);
clf;
big_img = display_gscatt_all(S{3}, 1, 0);
imagesc(big_img);
%%
% rotate image
x_r = rot90(x);

% compute propagators
propagators_r = propagators_builder_3d(size(x_r), options);

% compute scattering
[S_r, U_r] = gscatt(x_r, propagators_r);

% rotate back all signal of order 1 of S_r
S_r_o2 = S_r{3}.sig;
S_r_o2_back = cellfun(@(x)(rot90(x,3)), S_r_o2, 'UniformOutput', 0);

% display image of rotated back renormalized scattering vector (should be equal to fig1)
figure(2);
big_img_r = display_gscatt_all(S_r_o2_back, 1 ,0);
imagesc(big_img_r);
fprintf('max renormalized invariance error for order 2 of S %d \n',max(max(abs(big_img - big_img_r))));
%%
% this demonstrates covariance of roto-translation joint scattering
% coefficients U (non-averaged internal nodes)

% nodes of order 1 :
meta = U{2}.meta;
j1 = 3;
theta1 = 3;
p = find(meta.j(:,1) == j1 &...
  meta.theta(:,1) == theta1 );
theta1 = 1+ mod(theta1 + 4 -1,8);
p2 = find(meta.j(:,1) == j1 &...
  meta.theta(:,1) == theta1 );
u1 = U{2}.sig{p};
u2 =  rot90(U_r{2}.sig{p2},3);
imagesc( [ u1, u2]);
fprintf('relative covariance error for order 1 of U %d \n',norm(u1-u2)/(norm(u1)+norm(u2)));

%%
% nodes of order 2 :
j1 = 0;
j2 = 3;
jrot1 = 1;
th1ds = 6;
th2 = 1;
meta = U{3}.meta;
p = find(meta.j(:,1) == j1 & ...
  meta.j(:,2) == j2 & ...
  meta.j_rot(:,1) == jrot1 & ...
  meta.theta1_downsampled(:,1) == th1ds & ...
  meta.theta2(:,1) == th2);

th1ds = 1+ mod(th1ds - 4 -1,16);
p2 = find(meta.j(:,1) == j1 & ...
  meta.j(:,2) == j2 & ...
  meta.j_rot(:,1) == jrot1 & ...
  meta.theta1_downsampled(:,1) == th1ds & ...
  meta.theta2(:,1) == th2);

u1 = U{3}.sig{p};
u2 = rot90(U_r{3}.sig{p2},3);

imagesc([u1, u2]);
fprintf('relative covariance error for order 2 of U %d \n',norm(u1-u2)/(norm(u1)+norm(u2)));
%%