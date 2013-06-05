src = uiuc_src;

%src.objects = src.objects(1)

options.J = 5;
options.antialiasing = 0;
w = wavelet_factory_2d([480, 640], options);

features{1} = @(x)(sum(sum(format_scat(scat(x,w)),2),3));
%%
options.parallel = 0;
db = prepare_database(src, features, options);