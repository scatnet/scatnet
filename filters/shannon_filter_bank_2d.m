% SHANNON_FILTER_BANK_2D Compute a bank of Shannon wavelet filters in
% the Fourier domain.
%
% Usage
%	filters = SHANNON_FILTER_BANK_2D(size_in, options)
%
% Input
%    options (structure): Options of the bank of filters. Optional, with
%    fields:
%       J (numeric):
%       min_margins (numeric): 1-by-2 vector for the horizontal and vertical
%       margin for mirror pading of signal
%
% Output
%    filters (struct):  filters, with the fields
%        psi (struct): high-pass filter psi, with the following fields:
%            filter (cell): cell of structure containing the coefficients
%            type (string): takes the value 'fourier_multires'
%        phi (struct): low-pass filter phi
%            filter (cell): cell of structure containing the coefficients
%            type (string): takes the value 'fourier_multires'
%        meta (struct): contains meta-information on (g,h)
%
% Description
%    Compute the Morlet filter bank in the Fourier domain.

function filters = shannon_filter_bank_2d(size_in, options)
    if(nargin<2)
        options = struct;
    end
    
    white_list = {'J', 'min_margin'};
    check_options_white_list(options, white_list);
    
    % Options
    options = fill_struct(options, 'J',4);
    J = options.J;
    options = fill_struct(options, 'min_margin', 2^J );
    
    
    % size
    res_max = floor(J);
    size_filter = pad_size(size_in, options.min_margin, res_max);
    phi.filter.type = 'fourier_multires';
    
    N = size_filter(1);
    M = size_filter(2);
    [X, Y] = meshgrid(0:M-1, 0:N-1);
    
    % compute low pass filters phi
    
    %filter_spatial =  gabor_2d(N, M, sigma_phi*scale, 1, 0, 0);
    j = J-1;
    phixf = min(X,M-X)<=M/2^(j+2);
    phiyf = min(Y,N-Y)<=N/2^(j+2);
    phi.filter = phixf .* phiyf;
    phi.meta.J = J;
    
    phi.filter = optimize_filter(phi.filter, 1, options);
    
    littlewood_final = zeros(N, M);
    % compute high pass filters psi
    p = 1;
    
    for j = 0:J-1
        
        if (j == 0)
            psixf = X>M/4 & X<3*M/4;
            phixf = 1 - psixf;
            psiyf = (Y>N/4 & Y<3*N/4);
            phiyf = 1 - psiyf;
            psiyf2 = psiyf;
        else
            psixf = X<=M/2^(j+1) & X>M/2^(j+2);
            phixf = min(X,M-X)<=M/2^(j+2);
            psiyf = Y<=N/2^(j+1) & Y>N/2^(j+2);
            phiyf = min(Y,N-Y)<=N/2^(j+2);
            psiyf2 = (N-Y)<=N/2^(j+1) & (N-Y)>N/2^(j+2);
        end
        psi.filter{p} = psixf .* phiyf;
        psi.filter{p+1} = psixf .* psiyf;
        psi.filter{p+2} = phixf .* psiyf;
        psi.filter{p+3} = psixf .* psiyf2;
        
        if (j == 0)
            psi.filter{p} = psi.filter{p}/sqrt(2);
            psi.filter{p+1} = psi.filter{p+1}/sqrt(4);
            psi.filter{p+2} = psi.filter{p+2}/sqrt(2);
            psi.filter{p+3} = psi.filter{p+3}/sqrt(4);
        end
            
        psi.meta.j(p) = j;
        psi.meta.j(p+1) = j;
        psi.meta.j(p+2) = j;
        psi.meta.j(p+3) = j;
        psi.meta.theta(p) = 1;
        psi.meta.theta(p+1) = 2;
        psi.meta.theta(p+2) = 3;
        psi.meta.theta(p+3) = 4;
        
        
        littlewood_final = littlewood_final + ...
            abs(realize_filter(psi.filter{p})).^2;
        littlewood_final = littlewood_final + ...
            abs(realize_filter(psi.filter{p+1})).^2;
        littlewood_final = littlewood_final + ...
            abs(realize_filter(psi.filter{p+2})).^2;
        littlewood_final = littlewood_final + ...
            abs(realize_filter(psi.filter{p+3})).^2;
        p = p + 4;
    end
    
    % second pass : renormalize psi by max of littlewood paley to have
    % an almost unitary operator
    % NOTE : phi must not be renormalized since we want its mean to be 1
    K = max(littlewood_final(:));
    for p = 1:numel(psi.filter)
        psi.filter{p} = psi.filter{p}/sqrt(K/2);
        psi.filter{p} = optimize_filter(psi.filter{p}, 0, options);
    end
    
    filters.phi = phi;
    filters.psi = psi;
    
    filters.meta.J = J;
    filters.meta.Q = 1;
    filters.meta.L = 4;
    filters.meta.size_in = size_in;
    filters.meta.size_filter = size_filter;
end
