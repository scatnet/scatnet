% wavelet_3d : Compute the wavelet transform of a roto-translation orbit
%
% Usage
%	[y_Phi, y_Psi] = wavelet_3d(y, filters, filters_rot, options)
%		compute the roto-translation convolution of a three dimensional
%		signal y, with roto-translation wavelets defined as the separable product
%		low pass :
%		PHI(U,V) * PHI(THETA)
%		high pass :
%		PHI(U,V) * PHI(THETA)
%		PSI(U,V) * PHI(THETA)
%		PSI(U,V) * PSI(THETA)
%
% Ref
%	Rotation, Scaling and Deformation Invariant Scattering for Texture
%	Discrimination, Laurent Sifre, Stephane Mallat
%	Proc of CVPR 2013
%	http://www.cmapx.polytechnique.fr/~sifre/research/cvpr_13_sifre_mallat_final.pdf

function [y_Phi, y_Psi, meta_Phi, meta_Psi] = wavelet_3d(y, filters, filters_rot, options)
    
    % TODO : whitelist
    if (nargin<4)
        options = struct();
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
    
    
    if nargin<3
        options = struct();
    end
    
    Q = filters.meta.Q;
    J = filters.meta.J;
    
    % option retrieving
    % TODO : fill_struct the options
    oversampling = getoptions(options, 'oversampling', 1);
    oversampling_rot = getoptions(options, 'oversampling_rot', -1);
    psi_mask = getoptions(options, 'psi_mask', ones(1,numel(filters.psi.filter)));
    
    % precomputation
    lastres = log2(filters.meta.size_in(1)/size(y,1));
    
    
    sz_paded = filters.phi.filter.N;
    
    
    % ------- LOW PASS -------
    % ------- PHI(U,V) * PHI(THETA) -------
    
    ds_angle = max(filters_rot.meta.J/filters_rot.meta.Q - oversampling_rot, 0);
    if (~calculate_psi && 2^ds_angle == size(y,3))
        % if there is one coefft left along orientations, compute the sum
        % along orientation first is faster
        
        % low pass angle
        y_phi_angle =  sum(y, 3) / 2^(ds_angle/2);
        % low pass spatial
        ds = max(floor(J/Q)- lastres - oversampling, 0);
        
        
        xf = fft2(pad_signal(x, sz_paded, []));
        %margins = filters.meta.margins / 2^lastres;
        %tmp = fft2(pad_mirror_2d(y_phi_angle, margins));
        %margins = filters.meta.margins / 2^(lastres+ds);
        
        y_Phi = conv_sub_2d(tmp,filters.phi.filter, ds);
        y_Phi = unpad_signal(y_Phi, ds*[1 1], margins);
        
        
        meta_Phi.J(1) = filters.phi.meta.J;
        
    else
        phi_angle = filters_rot.phi.filter;
        % spatial mirror padding and fft
        margins = filters.meta.margins / 2^lastres;
        for theta = 1:nb_angle_in
            tmp = fft2(pad_mirror_2d(y(:,:,theta), margins));
            if (theta==1) % prealocate when we know the size
                yf = zeros([size(tmp), nb_angle_in]);
            end
            yf(:,:,theta) = tmp;
        end
        
        % low pass spatial (filter along first two dimension)
        for theta = 1:nb_angle_in
            ds = max(floor(J/Q)- lastres - oversampling, 0);
            margins = filters.meta.margins / 2^(lastres+ds);
            tmp = ...
                real(conv_sub_2d(yf(:,:,theta), filters.phi.filter, ds));
            tmp = unpad_signal(tmp, ds*[1 1], margins);
            if (theta == 1) % prealocate when we know the size
                y_phi = zeros([size(tmp), nb_angle_in]);
            end
            y_phi(:,:,theta) = tmp;
        end
        
        if (y_half_angle) % recopy thanks to (PROPERTY_1)
            y_phi = cat(3, y_phi, y_phi) / sqrt(2); % for energy preservation
        end
        
        % low pass angle
        phi_angle = filters_rot.phi.filter;
        ds = floor(max(filters_rot.J/filters_rot.Q - oversampling_rot, 0));
        if (2^ds == size(y_phi,3)) % if there is one coefft left, compute the sum
            % is faster than convolving with a constant filter
            y_Phi = sum(y_phi,3) / 2^(ds/2);
        else
            % fourier angle
            y_phi_f = fft(y_phi, [], 3);
            y_Phi = real(...
                sub_conv_1d_along_third_dim_simple(y_phi_f, phi_angle, ds));
        end
        meta_Phi.J(1) = filters.phi.meta.J;
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
            p = p + 1;
        end
        
        
        for lambda2 = find(psi_mask)
            theta2 = filters.psi.meta.theta(lambda2);
            j2 = filters.psi.meta.j(lambda2);
            ds = max(floor(j2/Q)- lastres - oversampling, 0);
            
            % convolution with psi_{j1, theta + theta2}
            for theta = 1:nb_angle_in
                theta_sum_mod2L =  1 + mod(theta + theta2 - 2, 2*L);
                theta_sum_modL =  1 + mod(theta + theta2 - 2, L);
                lambda2p1 = find(filters.psi.meta.theta == theta_sum_modL & ...
                    filters.psi.meta.j == j2);
                psi = filters.psi.filter{lambda2p1};
                margins = filters.meta.margins / 2^(lastres+ds);
                tmp = ...
                    conv_sub_unpad_2d(yf(:,:,theta), psi, ds, margins);
                
                if (theta == 1) % prealocate when we know the size
                    y_psi = zeros([size(tmp), nb_angle_in]);
                end
                
                % use PROPERTY_1 to compute convolution with filters that
                % have an angle > pi
                if (theta_sum_mod2L <= L)
                    y_psi(:,:, theta)  = tmp;
                else
                    y_psi(:,:, theta) = conj(tmp);
                end
            end
            
            if (y_half_angle) % thanks to PROPERTY_1
                y_psi = cat(3, y_psi, conj(y_psi)) / sqrt(2); % for energy preservation
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
                p = p + 1;
            end
        end
    end
    
    
end

