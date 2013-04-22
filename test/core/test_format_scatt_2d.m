f = lena;
options = struct();
cascade = cascade_factory_2d(size(f), options);

S = scatt(f, cascade);
%%
s = format_scatt(S,'table');