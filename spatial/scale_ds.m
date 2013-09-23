function [xds,h] = scale_ds(x, scale_fac, nb_scale)
xds{1} = x;
for i = 1:nb_scale-1
    step = scale_fac^i;
    options.sigma_phi = sqrt(step^2 -1)*0.5;
    options.P = 2 + floor(2*step);
    filters = morlet_filter_bank_2d_spatial(options);
    
    h{i} = filters.h.filter;
    
    tmp = convsub2d_spatial(x, h{i}, 0);
    xds{i+1} = downsample_noninteger(tmp, step);
end

