x = lena;

size_in = size(x);
options.null = 1;
cascade = cascade_factory_2d(size_in, options);
%%
tic;
[S, U] = scatt(x, cascade);
toc;