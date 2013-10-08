function Wop = normalize_wavelet_factory_1d(N, filter_options, scat_options, epsilon)
    
    if nargin <4
        epsilon = 2^(-20);
    end
    
    filters = filter_bank(N, filter_options);
    
    
    for m = 0:scat_options.M
        filt_ind = min(numel(filters), m+1);
        Wop{m+1} = @(X)(wavelet_renorm(X, m));
    end
    
    function [S, Utilde] = wavelet_renorm(U, m)
        filt_ind = min(numel(filters), m+1);
        [S, U] = wavelet_layer_1d(U, filters{filt_ind}, scat_options);
        Utilde = renorm_low_pass_layer_1d(S, U, epsilon);
    end
    
end







