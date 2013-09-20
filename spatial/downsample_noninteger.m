function xds = downsample_noninteger(x, step)
[n, m ] = size(x);
[u, v] = meshgrid(1:m, 1:n);
[uds, vds] = meshgrid(1:step:m, 1:step:n);
xds = interp2(u,v,x,uds,vds);
end