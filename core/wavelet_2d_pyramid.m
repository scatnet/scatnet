% WAVELET_2D_PYRAMID Compute the scattering transform
%
% Usage
%   [x_phi, x_psi] = WAVELET_2D_PYRAMID(x, filters, options)
%
% Input
%   x (numeric): the input signal
%   filters (struct): a 2d pyramid filter bank, typically obtained with
%       MORLET_FILTER_BANK_2D_PYRAMID
%   options (struct): containing the following optional fields :
%       J : the maximum scale
%       precision : 'single' or 'double')
%       j_min : the minimum scale to compute
%       q_mask : a mask on the q (scale per octave) filter parameters
%       all_low_pass : output all intermediate low pass filtering
%
% Output
%   x_phi (layer): x filtered with the low pass filter
%   x_psi (layer): x filtered with all the high pass filters
%   options (struct): the computed options
%
% Description
%   Compute the wavelet transform of input signal x with a FAST WAVELET
%   TRANSFORM (FWT) http://en.wikipedia.org/wiki/Fast_wavelet_transform
%   FWT is a cascade of alternate convolutions with conjugate mirror
%   filters h and g, and downsampling. Convolutions are prefarably
%   implemented in spatial domain.
%
% See also
%   MORLET_FILTER_BANK_2D_PYRAMID
%   WAVELET_LAYER_2D_PYRAMID
%   CONV_SUB_2D


function [x_phi, x_psi, options] = wavelet_2d_pyramid(x, filters, options)
    
    % check options white list
    if (~exist('options','var')), options = struct(); end
    white_list = {'J', 'precision', 'j_min', 'q_mask', 'all_low_pass'};
    check_options_white_list(options, white_list);
    
    % retrieve options
    options = fill_struct(options, 'precision', 'single');
    options = fill_struct(options, 'J', 4);
    options = fill_struct(options, 'j_min',0);
    options = fill_struct(options, 'q_mask', ones(1, filters.meta.Q));
    options = fill_struct(options, 'all_low_pass', 0);
    
    % initialize structure
    if strcmp(options.precision, 'single')
        hx.signal{1} = single(x);
    else
        hx.signal{1} = x;
    end
    hx.meta.j(1) = 0;
    
    % low pass
    h = filters.h.filter;
    for j = 1:options.J
        signal = hx.signal{j};
        pad_signal(x, Npad, boundary, center)
        Npad = size(signal) + filters.meta.
        signal_paded = pad_signal(signal, size(signal)+filters.meta.P*[2,2], 'symm', 1);
        tmp = conv_sub_2d(signal_paded, h, 1);
        tmp = unpad_signal(tmp, 1, size(signal), [filters.meta.P,filters.meta.P]);
        hx.signal{j+1} = tmp;
        hx.meta.j(j+1) = j;
    end
    x_phi.signal{1} = hx.signal{options.J+1};
    x_phi.meta.j(1) = hx.meta.j(options.J+1);
    
    % intermediate low pass may be usefull (e.g. for roto-translation 
    % wavelets of type phi(u) psi(theta) )
    if (options.all_low_pass == 1)
        x_phi.all_low_pass = hx;
    end
    
    if (nargout>1) % otherwise do not high pass compute x_psi 
        % high passes
        p = 1;
        g = filters.g.filter;
        gx.signal = {};
        for j = options.j_min:options.J-1
            signal = hx.signal{j+1};
            signal_paded = pad_signal(signal,size(signal)+ filters.meta.P*[2,2], [], 0, 1);
            for pf = 1:numel(g) %% todo : find
                q = filters.g.meta.q(pf);
                if (options.q_mask(q+1))
                    tmp = conv_sub_2d(signal_paded, g{pf}, 0);
                    tmp = unpad_signal(tmp, 0, size(signal), [filters.meta.P,filters.meta.P]);
                    gx.signal{p} = tmp;
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
