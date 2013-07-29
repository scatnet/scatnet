
psi.coefft = [0,1,1;0,1,1;0,1,1];
psi.type = 'spatial_support';
x = rand(128,128);
xc1 = convsub2d_spatial(x, psi, 0);
en = xc1.^2;
en = sum(en(:))

xc2 = convsub2d_spatial(x, psi, 1);
