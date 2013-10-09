% WAVELET_3D_PYRAMID Compute the roto-translation wavelet transfrom
%
% Usage
%   [y_Phi, y_Psi, meta_Phi, meta_Psi] = wavelet_3d_pyramid(y, filters, filters_rot, options)
%
% Input
%   y (numeric): a 3d matrix whose first two dimension corresponds to spatial
%       postion and third dimension corresponds to orientation.
%   filters (struct): a 2d pyramid filter bank (applied along spatial variable)
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
%   This is a pyramid implementation of the roto-translation wavelet
%   transform. Another (slower, FFT-based) implementation is available as
%   WAVELET_3D.
%	This function computes the roto-translation convolution of a three dimensional
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

function [y_Phi, y_Psi, meta_Phi, meta_Psi] = wavelet_3d_pyramid(y,...
        filters, filters_rot, options)
    
    % retrieve info on input
    Q = filters.meta.Q;
    L = filters_rot.meta.size_filter / 2;
    % do not compute any convolution with high pass if y_Psi is not
    % outputed
    calculate_psi = (nargout>=2);
    [N, M, T] = size(y);
    
    % retrieve options
    white_list = {'J', 'angular_range', 'oversampling_rot', 'j_min', 'q_mask'};
    check_options_white_list(options, white_list);
    options = fill_struct(options, 'J', 4);
    options = fill_struct(options, 'angular_range', 'non_specified');
    options = fill_struct(options, 'oversampling_rot', -1);
    options = fill_struct(options, 'j_min', 0);
    options = fill_struct(options, 'q_mask', ones(1, Q));
    
    % angular resolution
    switch (options.angular_range)
        case 'zero_pi'
            angular_res = floor(log2(2*L/(2*T)));
        case 'zero_2pi'
            angular_res = floor(log2(2*L/T));
        otherwise
            error('unspecified angular range');
    end
    
    if (isa(filters.h.filter.coefft, 'single'))
        prec = @(x)(single(x));
    else 
       prec = @(x)(x); 
    end
    
    %%%%%%%%%%%%%%%%%%
    %%% low passes %%%
    %%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%
    %%% phi - phi %%%%
    %%%%%%%%%%%%%%%%%%
    
    %% low pass filter spatial : cascade with h for every slice
    % initialize structure
    hy.signal{1} = y;
    hy.meta.j(1) = 0;
    
    % low pass spatial using a pyramid
    h = filters.h.filter;
    for j = 1:options.J
        for theta = 1:T % filter each slice
            if (theta == 1) % allocate when size is known
                tmp_slice = pad_conv_sub_unpad(hy.signal{j}(:,:,theta), h);
                tmp = prec(zeros([size(tmp_slice), T]));
                tmp(:,:,theta) = tmp_slice;
            else
                clear tmp_slice;
                tmp(:,:,theta) = ...
                   pad_conv_sub_unpad(hy.signal{j}(:,:,theta), h);
            end
        end
        hy.signal{j+1} = tmp;
        hy.meta.j(j+1) = j;
    end
    y_phi.signal{1} = hy.signal{options.J+1};
    y_phi.meta.j(1) = hy.meta.j(options.J+1);
    
    %% low pass filter anguler : fft along anguler
    % initialize structure (recopy if range is zero_pi)
    ds = max(filters_rot.meta.J/filters_rot.meta.Q - options.oversampling_rot, 0);
    if (2^ds == 2*L)
        % in this case it is faster to compute the sum along the angle
        y_Phi = sum(y_phi.signal{1},3) / 2^(ds/2);
    else
        if (strcmp(angular_range, 'zero_pi'))
            % divide by sqrt(2) for energy preservation
            y_phi.signal{1} = repmat(y_phi.signal{1}, [1 1 2]) / sqrt(2);
        end
        y_phi_f = fft(y_phi.signal{1}, [], 3);
        phi_angle = filters_rot.phi.filter;
        y_Phi = real(...
            sub_conv_1d_along_third_dim_simple(y_phi_f, phi_angle, ds));
    end
    meta_Phi.j2 = options.J;
    meta_Phi.k2 = filters_rot.meta.J;
    
    
    %%
    
    %%%%%%%%%%%%%%%%%%%
    %%% high passes %%%
    %%%%%%%%%%%%%%%%%%%
    
    if (calculate_psi)
        p = 1;
        %%%%%%%%%%%%%%%%%%
        %%% phi - psi %%%%
        %%%%%%%%%%%%%%%%%%
        
        %% low pass spatial - already computed
        %% high pass angular
        % NOTE : y_phi_f
        % (the (angular) fourier transform of y * (spatial) phi)
        % might have already been computed
        if ~exist('y_phi_f', 'var')
            % fourier angle
            if (strcmp(options.angular_range, 'zero_pi'))
                % divide by sqrt(2) for energy preservation
                y_phi.signal{1} = repmat(y_phi.signal{1}, [1 1 2]) / sqrt(2);
            end
            y_phi_f = fft(y_phi.signal{1}, [], 3);
        end
        for k2 = 0:numel(filters_rot.psi.filter)-1
            psi_angle = filters_rot.psi.filter{k2+1};
            ds = max(k2/filters_rot.meta.Q - options.oversampling_rot, 0);
            y_Psi{p} = ...
                sub_conv_1d_along_third_dim_simple(y_phi_f, psi_angle, ds);
            meta_Psi.j2(p) = options.J;
            meta_Psi.q2(p) = 0;
            meta_Psi.theta2(p) = 0;
            meta_Psi.k2(p) = k2;
            p = p + 1;
        end
        
        
        %%%%%%%%%%%%%%%%%%
        %%% psi - phi %%%%
        %%%%%%%%%%%%%%%%%%
        %      AND       %
        %%%%%%%%%%%%%%%%%%
        %%% psi - phi %%%%
        %%%%%%%%%%%%%%%%%%
        
        %% high pass spatial - with pyramid
        if (strcmp(options.angular_range, 'zero_pi') && angular_res == 0)
            g = filters.g.filter;
            
            for j2 = options.j_min:options.J-1
                for q = find(options.q_mask==1)-1
                    for theta2 = 1:L
                        for theta = 1:L
                            % convolution with psi_{j1, theta + theta2}
                            theta_sum_mod2L =  1 + mod(theta + theta2 - 2, 2*L);
                            theta_sum_modL =  1 + mod(theta + theta2 - 2, L);
                            tmp_slice = pad_conv_unpad(hy.signal{j2+1}(:,:,theta), g{theta_sum_modL + L*q});
                            if (theta == 1) % allocate
                                tmp = prec(zeros([size(tmp_slice), 2*L]));
                            end
                            if (theta_sum_mod2L <= L)
                                tmp(:,:,theta) = tmp_slice;
                                tmp(:,:,theta+L) = conj(tmp_slice);
                            else
                                tmp(:,:,theta) = conj(tmp_slice);
                                tmp(:,:,theta+L) = tmp_slice;
                            end
                        end
                        
                        % tmp can now be filtered along the orientation
                        tmp_f = fft(tmp, [], 3);
                        %% low pass angle
                        ds = min(2*L, max(filters_rot.meta.J/filters_rot.meta.Q - options.oversampling_rot, 0));
                        if (2^ds == 2*L)
                            % faster to compute the sum along the angle
                            y_Psi{p} = sum(tmp, 3) / 2^(ds/2);
                        else
                            y_Psi{p} = ...
                                sub_conv_1d_along_third_dim_simple(tmp_f, phi_angle, ds);
                        end
                        meta_Psi.j2(p) = j2;
                        meta_Psi.theta2(p) = theta2;
                        meta_Psi.k2(p) = filters_rot.meta.J;
                        meta_Psi.q2(p) = q;
                        p = p + 1;
                        
                        %% high pass angle
                        for k2 = 0:numel(filters_rot.psi.filter)-1
                            psi_angle = filters_rot.psi.filter{k2+1};
                            ds = max(k2/filters_rot.meta.Q - options.oversampling_rot, 0);
                            y_Psi{p} = ...
                                sub_conv_1d_along_third_dim_simple(tmp_f, psi_angle, ds);
                            meta_Psi.j2(p) = j2;
                            meta_Psi.theta2(p) = theta2;
                            meta_Psi.k2(p) = k2;
                            meta_Psi.q2(p) = q;
                            p = p + 1;
                        end
                        
                    end
                end
            end
        else
            error('not yet supported');
        end
        
        
    end
    
    function out = pad_conv_sub_unpad(in, filter)
        Npad = size(in) + filters.meta.size_filter - 1;
        out = pad_signal(in, Npad, 'symm', 1);
        out = conv_sub_2d(out, filter, 1);
        out = unpad_signal(out, 1, size(in), filters.meta.offset);
    end

    
    function out = pad_conv_unpad(in, filter)
        Npad = size(in) + filters.meta.size_filter - 1;
        out = pad_signal(in, Npad, 'symm', 1);
        out = conv_sub_2d(out, filter, 0);
        out = unpad_signal(out, 0, size(in), filters.meta.offset);
    end
end

