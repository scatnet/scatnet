% WAVELET_LAYER_2D Compute the wavelet transform of a scattering layer
%
% Usage
%    [U_phi, U_psi] = WAVELET_LAYER_2D(U, filters, options)
%
% Input
%    U (struct): input scattering layer
%    filters (struct): filter bank 
%    options (structure): same as wavelet_2d
%
% Output
%    A (struct): Averaged wavelet coefficients
%    V (struct): Wavelet coefficients of the next layer
%
% Description
%    This function has a pivotal role between WAVELET_2D (which computes a
%    single wavelet transform), and WAVELET_FACTORY_2D (which creates the
%    whole cascade). Given inputs modulus wavelet coefficients
%    corresponding to a layer, WAVELET_LAYER_2D computes the wavelet
%    transform coefficients of the next layer using WAVELET_2D.
%
% See also
%   WAVELET_2D, WAVELET_FACTORY_2D, WAVELET_LAYER_1D

function [U_phi, U_psi] = wavelet_layer_2d(U, filters, options)
    
    calculate_psi = (nargout>=2); % do not compute any convolution
    % with psi if the user does get U_psi
    
    if ~isfield(U.meta,'theta')
        U.meta.theta = zeros(0,size(U.meta.j,2));
    end
    
    if ~isfield(U.meta, 'resolution'),
        U.meta.resolution = 0;
    end
    
    p2 = 1;
    for p = 1:numel(U.signal)
        x = U.signal{p};
        if (numel(U.meta.j)>0)
            j = U.meta.j(end,p);
        else
            j = -1E20;
        end
        
        % compute mask for progressive paths
        options.psi_mask = calculate_psi & ...
            (filters.psi.meta.j >= j + filters.meta.Q);
        
        % set resolution of signal
        options.x_resolution = U.meta.resolution(p);
        
        % compute wavelet transform
        [x_phi, x_psi, meta_phi, meta_psi] = wavelet_2d(x, filters, options);
        
        % copy signal and meta for phi
        U_phi.signal{p} = x_phi;
        U_phi.meta.j(:,p) = [U.meta.j(:,p); filters.phi.meta.J];
        U_phi.meta.theta(:,p) = U.meta.theta(:,p);
        U_phi.meta.resolution(1,p) = meta_phi.resolution;
        
        % copy signal and meta for psi
        for p_psi = find(options.psi_mask)
            U_psi.signal{p2} = x_psi{p_psi};
            U_psi.meta.j(:,p2) = [U.meta.j(:,p);...
                filters.psi.meta.j(p_psi)];
            U_psi.meta.theta(:,p2) = [U.meta.theta(:,p);...
                filters.psi.meta.theta(p_psi)];
            U_psi.meta.resolution(1,p2) = meta_psi.resolution(p_psi);
            p2 = p2 +1;
        end
        
    end
    
end
