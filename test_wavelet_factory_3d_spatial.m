clear
x = uiuc_sample;
%%
options.J = 3;
options.precision = 'single';
tic;
[Wop,f1,f2] = wavelet_factory_3d_spatial(options, options, options);
toc;
tic;
[Sx, Ux] = scat(x, Wop);
toc;
%%
options.oversampling = 0;
options.J = 3;
tic;
Wop2 = wavelet_factory_3d(size(x), options, options, options);
toc;
tic;
[Sx2, Ux2] = scat(x, Wop2);
toc;


%%
immac(image_scat_layer(Sx{2}, 0, 0),1);
immac(image_scat_layer(Sx2{2}, 0, 0),2);

%%
immac(image_scat_layer(Sx{3}, 1, 1),1);

immac(image_scat_layer(Sx2{3}, 1, 1),2);

