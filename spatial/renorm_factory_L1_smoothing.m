% renorm_factory_L1_smoothing : a factory for operator that renormalize
%   with L1 along siblings and smoothing alon spatial position
%
% Usage 
%   op = renorm_factory_L1_smoothing(sigma)
%
% Input 
%   sigma (double) : window width for spatial smoohting
%
% Output
%   op (function_handle) : argument of renorm_sibling_*d

function op = renorm_factory_L1_smoothing(sigma)

    l1_op = @(x)(sum(x,3));
    if (sigma == 0)
        op = @(x)(l1_op(x) + 1E-20);
    else
       options.sigma_phi = 1;
       options.P = 2 + floor(2*sigma);
       filters = morlet_filter_bank_2d_spatial(options);
       h = filters.h.filter;
       smooth = @(x)(conv_sub_2d(x, h, 0));
        op = @(x)(smooth(l1_op(x)) + 1E-20); 
    end
end
