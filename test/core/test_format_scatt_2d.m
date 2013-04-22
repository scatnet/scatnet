x = lena;

options.J = 4;
cascade = cascade_factory_2d(size(x), options);

Sx = scatt(x, cascade);
sx = format_scatt(Sx,'table');

%% with mnist
x = retrieve_mnist(1,1,1);
x = x{1}{1};


options.J = 3;
options.nb_angle = 6;
options.antialiasing = 0;
[cascade, filters] = cascade_factory_2d(size(x), options);


Sx = scatt(x, cascade);
sx = format_scatt(Sx,'table');
