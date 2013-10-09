% WAVELET_LAYER_2D_PYRAMID Compute the wavelet transform of layer
%
% Usage
%   [U_phi, U_psi] = wavelet_layer_2d_pyramid(U, filters, options) 
%
% Input
%   U (struct): a scattering layer
%   filters (struct): a 2d filter bank
%   options (struct): same as for WAVELET_2D
%
% Output
%   U_Phi (struct): low pass convolutions of all signal of U
%   U_Psi (struct): high pass convolutions of all signal of U
%
% Description
%   This function computes the 2d wavelet transform of each signal of the
%   input layer U. Convolutions with low pass filter are stored in U_phi
%   while convolutions with high pass filters are stored in U_psi.
%   It is similar to WAVELET_LAYER_2D but uses a WAVELET_2D_PYRAMID, a
%   pyramid implementation of the 2d wavelet transform which is faster and
%   better deals with boundary effect.
%
% See also
%   SCAT, WAVELET_FACTORY_2D_PYRAMID, WAVELET_2D_PYRAMID

function [U_phi, U_psi] = wavelet_layer_2d_pyramid(U, filters, options)
    
    calculate_psi = (nargout>=2); % do not compute any convolution
    % with psi if the user does not get U_psi
    
    if ~isfield(U.meta, 'theta')
        U.meta.theta = zeros(0,size(U.meta.j,2));
    end
    if ~isfield(U.meta, 'q')
        U.meta.q = zeros(0, size(U.meta.j,2));
    end
    J = getoptions(options, 'J', 4);
    Q = filters.meta.Q;
    
    p2 = 1;
    for p = 1:numel(U.signal)
        x = U.signal{p};
        if (numel(U.meta.j)>0)
            j = U.meta.j(end,p);
            w_options.j_min = 1;
        else
            j = 0;
            w_options.j_min = 0;
        end
        
        % compute mask for progressive paths
        w_options.J = J-j;
        if (numel(U.meta.q) > 0)
            w_options.q_mask = zeros(1,Q);
            w_options.q_mask(U.meta.q(end, p) +1) = 1;
        end
        
        if (calculate_psi)
            % compute wavelet transform
            [x_phi, x_psi, meta_phi, meta_psi] = wavelet_2d_pyramid(x, filters, w_options);
            
            % copy signal and meta for phi
            U_phi.signal{p} = x_phi;
            U_phi.meta.j(:,p) = [U.meta.j(:,p); J];
            U_phi.meta.q(:,p) = U.meta.q(:,p);
            U_phi.meta.theta(:,p) = U.meta.theta(:,p);
            
            % copy signal and meta for psi
            for p_psi = 1:numel(x_psi)
                U_psi.signal{p2} = x_psi{p_psi};
                U_psi.meta.j(:,p2) = [U.meta.j(:,p);...
                    j+ meta_psi.j(p_psi)];
                U_psi.meta.theta(:,p2) = [U.meta.theta(:,p);...
                    meta_psi.theta(p_psi)];
                U_psi.meta.q(:,p2) = [U.meta.q(:,p);...
                    meta_psi.q(p_psi)];
                p2 = p2 +1;
            end
            
        else
            % compute only low pass
            x_phi = wavelet_2d_pyramid(x, filters, w_options);
            
            % copy signal and meta for phi
            U_phi.signal{p} = x_phi;
            U_phi.meta.j(:,p) = [U.meta.j(:,p); J];
            U_phi.meta.theta(:,p) = U.meta.theta(:,p);
            U_phi.meta.q(:,p) = U.meta.q(:,p);
            
        end
        
    end
    
end
