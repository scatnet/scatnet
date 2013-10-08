function Wop = normalize_wavelet_factory_1d(N,filter_options,scat_options,epsilon)

if nargin <4
    epsilon = 2^(-20);
end

filters = filter_bank(N, filter_options);


for m = 0:scat_options.M
    filt_ind = min(numel(filters), m+1);
 
    Wop{m+1} = @(X)(renorm_wavelet_layer_1d(func_output(...
        @wavelet_layer_1d,[1,2],X,filters{filt_ind},scat_options),epsilon));
end

end







