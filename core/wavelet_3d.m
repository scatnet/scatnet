% WAVELET_3D Compute the roto-translation wavelet transform
%
% Usage
%   [y_Phi, y_Psi, meta_Phi, meta_Psi] = WAVELET_3D(y, filters, filters_rot, options)
%
% Input
%   y (numeric): a 3d matrix whose first two dimension corresponds to spatial
%       postion and third dimension corresponds to orientation.
%   filters (struct): a 2d filter bank (applied along spatial variable)
%   filters_rot (struct): a 1d filter bank (applied along orientation)
%   options (struct): containing the following optional fields 
%       x_resolution (int): the log of spatial resolution
%       psi_mask (bool array): a mask for determining which filter to apply
%       oversampling (int): the log of spatial oversampling
%       oversampling_rot (int): the log of orientation oversampling
%
% Output
%   y_Phi (numeric): the roto-translation convolution y * Phi
%   y_Psi (cell): containing all the roto-translation convolution y * Psi
%   meta_phi (struct): meta associated to y_Phi
%   meta_psi (struct): meta associated to y_Psi
%
% Description
%	compute the roto-translation convolution of a three dimensional
%	signal y, with roto-translation wavelets defined as the separable product
%	low pass :
%		PHI(U,V) * PHI(THETA)
%	high pass :
%		PHI(U,V) * PHI(THETA)
%		PSI(U,V) * PHI(THETA)
%		PSI(U,V) * PSI(THETA)
%
% Reference
%	Rotation, Scaling and Deformation Invariant Scattering for Texture
%	Discrimination, Laurent Sifre, Stephane Mallat
%	Proc of CVPR 2013
%	http://www.cmapx.polytechnique.fr/~sifre/research/cvpr_13_sifre_mallat_final.pdf
%
% See also
%   WAVELET_LAYER_3D, WAVELET_FACTORY_3D

function [y_Phi, y_Psi, meta_Phi, meta_Psi] = wavelet_3d(y, filters, filters_rot, options)
    
    % Options
    if (nargin<4)
        options = struct();
    end
    white_list = {'x_resolution', 'psi_mask', 'oversampling', 'oversampling_rot'};
    check_options_white_list(options, white_list);
    options = fill_struct(options, 'oversampling', 1);
    options = fill_struct(options, 'oversampling_rot', -1);
    options = fill_struct(options, 'psi_mask', ones(1,numel(filters.psi.filter)));
    options = fill_struct(options, 'x_resolution', 0);
    
    % required cast for preallocation
    if (isa(filters.phi.filter.coefft, 'single'))
       cast = @single;
    else 
       cast = @double; 
    end
    
    calculate_psi = (nargout>=2); % do not compute any convolution
    % with high pass
    
    nb_angle = filters_rot.meta.size_filter;
    L = nb_angle/2;
    nb_angle_in = size(y,3);
    y_half_angle = nb_angle_in == nb_angle/2;
    % if only half of the signal is input, the roto-translation
    % convolution can be speeded up by a factor of 2 since
    % \psi_{\theta_2 + \pi} = conj(\psi_{\theta_2})
    % and (PROPERTY_1)
    % |x * \psi_{\theta_1 + \pi}| = |x * \psi_{\theta_1}|
    % we have that
    % | x* \psi_{\theta_1 + \pi} | * \psi_{\theta_2 + \pi}  =
    % conj(| x* \psi_{\theta_1} | * \psi_{\theta_2} )
    
    
    Q = filters.meta.Q;
    J = filters.meta.J;
    Q_rot = filters_rot.meta.Q;
    J_rot = filters_rot.meta.J;
    sz_paded = filters.phi.filter.N / 2^(options.x_resolution);
    
    
    % ------- LOW PASS -------
    % ------- PHI(U,V) * PHI(THETA) -------
    
    ds_angle = max(J_rot/Q_rot - options.oversampling_rot, 0);
    if (~calculate_psi && 2^ds_angle == size(y,3))
        % if there is one coefft left along orientations, compute the sum
        % along orientation first is faster
        
        % low pass angle
        y_phi_angle =  sum(y, 3) / 2^(ds_angle/2);
        % low pass spatial
        ds = max(floor(J/Q)- options.x_resolution - options.oversampling, 0);
        tmp = fft2(pad_signal(y_phi_angle, sz_paded, []));
        tmp = conv_sub_2d(tmp, filters.phi.filter, ds);
        y_Phi = real(unpad_signal(tmp, ds*[1 1],  [size(y,1), size(y,2)]));
        %meta
        meta_Phi.J(1) = filters.phi.meta.J;
        meta_Phi.resolution(1) = options.x_resolution+ds;
    else
        % spatial mirror padding and fft
        yf = cast(zeros([sz_paded, nb_angle_in]));
        for theta = 1:nb_angle_in
            tmp = fft2(pad_signal(y(:,:,theta), sz_paded, []));
            yf(:,:,theta) = tmp;
        end
        
        % low pass spatial
        
        for theta = 1:nb_angle_in
            ds = max(floor(J/Q) - options.x_resolution - options.oversampling, 0);
            tmp = ...
                real(conv_sub_2d(yf(:,:,theta), filters.phi.filter, ds));
            tmp = unpad_signal(tmp, ds*[1 1], [size(y,1), size(y,2)]);
            if (theta == 1) %preallocate when we know the size
                y_phi = cast(zeros([size(tmp), nb_angle_in]));
            end
            y_phi(:,:,theta) = tmp;
        end
        
        if (y_half_angle) % recopy thanks to (PROPERTY_1)
            y_phi = cat(3, y_phi, y_phi) / sqrt(2); % for energy preservation
        end
        
        % low pass angle
        phi_angle = filters_rot.phi.filter;
        ds_rot = floor(max(floor(J_rot/Q_rot) - options.oversampling_rot, 0));
        if (2^ds_rot == size(y_phi,3)) % if there is one coefft left, compute the sum
            % is faster than convolving with a constant filter
            y_Phi = sum(y_phi,3) / 2^(ds_rot/2);
        else
            % fourier angle
            y_phi_f = fft(y_phi, [], 3);
            y_Phi = real(...
                sub_conv_1d_along_third_dim_simple(y_phi_f, phi_angle, ds_rot));
        end
        meta_Phi.J(1) = filters.phi.meta.J;
        meta_Phi.resolution(1) = options.x_resolution+ds;
    end
    
    y_Psi = {};
    if (calculate_psi)
        % ------- HIGH PASS -------
        p = 1;
        
        % high pass angle to obtain
        % ------- PHI(U,V) * PSI(THETA) -------
        if ~exist('y_phi_f', 'var')
            % fourier angle
            y_phi_f = fft(y_phi, [], 3);
        end
        for k2 = 0:numel(filters_rot.psi.filter)-1
            psi_angle = filters_rot.psi.filter{k2+1};
            y_Psi{p} = ...
                sub_conv_1d_along_third_dim_simple(y_phi_f, psi_angle, 0);
            meta_Psi.theta2(p) = 0;
            meta_Psi.j2(p) = filters.phi.meta.J;
            meta_Psi.k2(p) = k2;
            meta_Psi.resolution(1,p) = meta_Phi.resolution(1);
            p = p + 1;
        end
        
        
        for lambda2 = find(options.psi_mask)
            theta2 = filters.psi.meta.theta(lambda2);
            j2 = filters.psi.meta.j(lambda2);
            ds = max(floor(j2/Q)- options.x_resolution - options.oversampling, 0);
            
            % convolution with psi_{j1, theta + theta2}
            for theta = 1:nb_angle_in
                theta_sum_mod2L =  1 + mod(theta + theta2 - 2, 2*L);
                theta_sum_modL =  1 + mod(theta + theta2 - 2, L);
                lambda2p1 = find(filters.psi.meta.theta == theta_sum_modL & ...
                    filters.psi.meta.j == j2);
                psi = filters.psi.filter{lambda2p1};
                
                %tmp = ...
                %    conv_sub_unpad_2d(yf(:,:,theta), psi, ds, margins);
                tmp = conv_sub_2d(yf(:,:,theta), psi, ds);
                tmp = unpad_signal(tmp, ds*[1,1], [size(y,1), size(y,2)]);
                
                if (theta == 1) % prealocate when we know the size
                    y_psi = cast(zeros([size(tmp), 2*L]));
                end
                
                % use PROPERTY_1 to compute convolution with filters that
                % have an angle > pi
                if (theta_sum_mod2L <= L)
                    y_psi(:,:,theta) = tmp;
                    y_psi(:,:,theta+L) = conj(tmp);
                else
                    y_psi(:,:,theta) = conj(tmp);
                    y_psi(:,:,theta+L) = tmp;
                end
            end
            
            
            % fourier angle
            y_psi_f = fft(y_psi,[],3);
            
            % low pass angle to obtain
            % ------- PSI(U,V) * PHI(THETA) -------
            phi_angle = filters_rot.phi.filter;
            y_Psi{p} = ...
                sub_conv_1d_along_third_dim_simple(y_psi_f, phi_angle, 0);
            meta_Psi.j2(p) = j2;
            meta_Psi.theta2(p) = theta2;
            meta_Psi.k2(p) = -1;
            meta_Psi.resolution(p) = options.x_resolution+ds;
            p = p+1;
            
            % high pass angle to obtain
            % ------- PSI(U,V) * PSI(THETA) -------
            for k2 = 0:numel(filters_rot.psi.filter)-1
                psi_angle = filters_rot.psi.filter{k2+1};
                y_Psi{p} = ...
                    sub_conv_1d_along_third_dim_simple(y_psi_f, psi_angle, 0);
                meta_Psi.theta2(p) = theta2;
                meta_Psi.j2(p) = j2;
                meta_Psi.k2(p) = k2;
                meta_Psi.resolution(p) = options.x_resolution+ds;
                p = p + 1;
            end
        end
    end
    
    
end

