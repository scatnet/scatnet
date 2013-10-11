% WAVELET_LAYER_3D_PYRAMID
% Usage
%
% Input
%
% Output
%
% Description
%
% See also
%

function [U_Phi, U_Psi] = wavelet_layer_3d_pyramid(...
        U, filters, filters_rot, options)
    
    calculate_psi = (nargout>=2); % do not compute any convolution
    % with psi if the user does not get U_psi
    
    % get the precision (required for preallocation of 3d matrix)
    if (isa(filters.h.filter.coefft, 'single'))
        prec = @(x)(single(x));
    else
        prec = @(x)(x);
    end
    %%
    J = getoptions(options, 'J', 4);
    Q = filters.meta.Q;
    w_options = options;
    L = filters.meta.L;
    %%
    % if previous layer is output of 2d wavelet transform,
    % extract the orbits
    porb = 1;
    if (~isfield(U.meta,'theta2'))
        for j = 0:J-1
            for q = 0:Q-1
                for theta = 1:L
                    p = find(U.meta.j(1,:) == j &...
                        U.meta.theta(1,:) == theta &...
                        U.meta.q(1,:) == q);
                    if (theta == 1)
                        tmp = prec(zeros([size(U.signal{p}), L]));
                    end
                    tmp(:, :, theta) = U.signal{p};
                end
                U_orb.signal{porb} = tmp;
                U_orb.meta.j(porb) = j;
                U_orb.meta.q(porb) = q;
                porb = porb + 1;
            end
            
        end
    else
        U_orb = U;
    end
    
    %% for each orbit, apply the 3d wavelet tranform
    
    p2 = 1;
    if (calculate_psi) % first application
        
        for p = 1:numel(U_orb.signal)
            j = U_orb.meta.j(end, p);
            q = U_orb.meta.q(end, p);
            
            % configure wavelet transform
            w_options.angular_range = 'zero_pi';
            w_options.j_min         = 1;
            w_options.J             = J - j;
            w_options.q_mask        = zeros(1,Q);
            w_options.q_mask(q + 1) = 1;
            
            % compute wavelet transform
            [y_Phi, y_Psi, meta_Phi, meta_Psi] = wavelet_3d_pyramid(U_orb.signal{p},...
                filters, filters_rot, w_options);
            
            % copy signal and meta
            U_Phi.signal{p} = y_Phi;
            U_Phi.meta.j(:,p) = [U_orb.meta.j(:,p); J];
            U_Phi.meta.q(:,p) = U_orb.meta.q(:,p);
            
            for p_psi = 1:numel(y_Psi)
                U_Psi.signal{p2} = y_Psi{p_psi};
                
                U_Psi.meta.j(:,p2)      = [j; meta_Psi.j2(:,p_psi) + j];
                U_Psi.meta.q(:,p2)  =  [U_orb.meta.q(:,p); meta_Psi.q2(:,p_psi)];
                U_Psi.meta.theta2(:,p2) = meta_Psi.theta2(:,p_psi);
                U_Psi.meta.k2(:,p2)      = meta_Psi.k2(:,p_psi);
                
                p2 = p2 + 1;
            end
        end
    else  % second application, only compute low pass
        for p = 1:numel(U_orb.signal)
            
            lastj = U_orb.meta.j(end,p);
            w_options.J = J - lastj;
            
            % configure wavelet transform
            w_options.angular_range = 'zero_2pi';
            
            % compute wavelet transform (low pass only)
            y_Phi = wavelet_3d_pyramid(U_orb.signal{p},...
                filters, filters_rot, w_options);
            
            %
            U_Phi.signal{p} = y_Phi;
            
            
        end
        U_Phi.meta = U_orb.meta;
        U_Phi.meta.j = [U_Phi.meta.j; J*ones(1, size(U_Phi.meta.j,2))];
    end
    
end
