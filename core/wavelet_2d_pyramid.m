% WAVELET_2D_PYRAMID Compute the scattering transform
%
% Usage
%   [x_phi, x_psi] = WAVELET_2D_PYRAMID(x, filters, options)
%
% Input
%   x (numeric): The input signal
%   filters (struct): A 2d pyramid filter bank, typically obtained with
%       MORLET_FILTER_BANK_2D_PYRAMID
%   options (struct): containing the optional following fields :
%       - J : the maximum scale
%       - precision : 'single' or 'double')
%       - j_min : the minimum scale to compute 
%       - q_mask : a mask on the q (scale per octave) filter parameters
%
%
% Output
%
% Description
%
% See also


function [x_phi, x_psi] = wavelet_2d_pyramid(x, filters, options)
    
    % check options white list
    options_white_list = {'J', 'precision', 'j_min', 'q_mask'};
    
    % retrieve options
    options.null = 1;
    precision = getoptions(options, 'precision', 'single');
    J = getoptions(options, 'J', 4);
    j_min = getoptions(options, 'j_min',0);
    q_mask = getoptions(options,'q_mask', ones(1, filters.meta.Q));
    
    % initialize structure
    if strcmp(precision, 'single')
        hx.signal{1} = single(x);
    else
        hx.signal{1} = x;
    end
    hx.meta.j(1) = 0;
    
    % low pass
    h = filters.h.filter;
    for j = 1:J
        hx.signal{j+1} = conv_sub_2d(hx.signal{j}, h, 1);
        hx.meta.j(j+1) = j;
    end
    x_phi.signal{1} = hx.signal{J+1};
    x_phi.meta.j(1) = hx.meta.j(J+1);
    if (all_low_pass == 1)
        x_phi.all_low_pass = hx;
    end
    
    if (nargout>1)
        % high passes
        p = 1;
        g = filters.g.filter;
        gx.signal = {};
        for j = j_min:J-1
            for pf = 1:numel(g)
                q = filters.g.meta.q(pf);
                if (q_mask(q+1))
                    gx.signal{p} = conv_sub_2d(hx.signal{j+1}, g{pf}, 0);
                    gx.meta.j(p) = j;
                    gx.meta.q(p) = q;
                    gx.meta.theta(p) = filters.g.meta.theta(pf);
                    p = p+1;
                end
            end
        end
        x_psi = gx;
    end
    
end
