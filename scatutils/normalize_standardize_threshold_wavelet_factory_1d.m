function Wop = normalize_standardize_threshold_wavelet_factory_1d(N,filter_options,scat_options,epsilon)

if nargin <4
    epsilon =2^(-20);
end

filters = filter_bank(N, filter_options);

ren_op=@(X)(func_output(...
            @renorm_wavelet_layer_1d,[1,2],X,epsilon));
        
std_op= @(X,m)(func_output(...
            @standardize_wavelet_layer_1d,[1,2],X,scat_options.sigmas{m+1}));

	for m = 0:scat_options.M
		filt_ind = min(numel(filters), m+1);
        if m<scat_options.M
		Wop{m+1} = @(X)(threshold_wavelet_layer_1d(...
            std_op(...
            ren_op(func_output(@wavelet_layer_1d,[1,2],X,...
            filters{filt_ind},scat_options)),m),scat_options.threshold));
        else 
        Wop{m+1} = @(X)(threshold_wavelet_layer_1d(...
                      ren_op(func_output(@wavelet_layer_1d,[1,2],X,...
            filters{filt_ind},scat_options)),scat_options.threshold));
	end

end




   


