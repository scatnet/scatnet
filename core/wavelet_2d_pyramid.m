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


function [x_phi, x_psi, meta_phi, meta_psi, options] = wavelet_2d_pyramid(x, filters, options)
    
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
    hx{1} = x; 
    
    % low pass
    h = filters.h.filter;
    for j = 1:options.J
        signal = hx{j};
        Npad = size(signal) + filters.meta.size_filter - 1;
        signal_paded = pad_signal(signal, Npad, 'symm', 1);
        tmp = conv_sub_2d(signal_paded, h, 1);
        tmp = unpad_signal(tmp, 1, size(signal), filters.meta.offset);
        hx{j+1} = tmp;
    end
    x_phi{1} = hx{options.J+1};
    meta_phi.j(1) = options.J;
    
    % intermediate low pass may be usefull (e.g. for roto-translation 
    % wavelets of type phi(u) psi(theta) )
    if (options.all_low_pass == 1)
        x_phi.all_low_pass = hx;
    end
    
    if (nargout>1) % otherwise do not high pass compute x_psi 
        % high passes
        p = 1;
        g = filters.g.filter;
        x_psi = {};
        for j = options.j_min:options.J-1
            signal = hx{j+1};
            Npad = size(signal) + filters.meta.size_filter - 1;
            signal_paded = pad_signal(signal, Npad, 'symm', 1);
            for pf = 1:numel(g) %% todo : find
                q = filters.g.meta.q(pf);
                if (options.q_mask(q+1))
                    tmp = conv_sub_2d(signal_paded, g{pf}, 0);
                    tmp = unpad_signal(tmp, 0, size(signal), filters.meta.offset);
                    x_psi{p} = tmp;
                    meta_psi.j(p) = j;
                    meta_psi.q(p) = q;
                    meta_psi.theta(p) = filters.g.meta.theta(pf);
                    p = p+1;
                end
            end
        end
        
    end
    
end
