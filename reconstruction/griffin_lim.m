% GRIFFIN_LIM The Griffin & Lim phase retrieval algorithm
%
% Usage
%    x = griffin_lim(x_init, x_phi, x_psi_mod, filters, options)
%
% Input
%    x_init (numeric): The inital guess for x.
%    x_phi (numeric): The lowpass coefficients
%    x_psi_mod (cell): The wavelet modulus coefficients.
%    filters (struct): The filter bank used to calculate the wavelet transform
%        in WAVELET_1D.
%    options (struct, optional): Different parameters to the algorithm and to
%        WAVELET_1D and INVERSE_WAVELET_1D that are called. Parameters for
%        GRIFFIN_LIM are:
%            gl_iter (numeric): The number of iterations (default 32).
%
% Output
%     x (numeric): The result of the algorithm.
%
% Description
%    Given the lowpass coefficients and the modulus of the wavelet 
%    coefficients, the Griffin & Lim algorithm attempts to reconstruct the
%    original signal by recovering the phase of the wavelet coefficients. To
%    do this, it performs an alternating projection on the wavelet reproducing
%    kernel (the set of coefficients that are valid wavelet transforms) and
%    the set of coefficients of the desired modulus. Since the latter is a 
%    non-convex set, the algorithm will not converge. In some applications,
%    however, the approximation that it provides is sufficient. For more 
%    details, see [1].
%
% References
%    [1] D. W. Grifﬁn and J. S. Lim, “Signal estimation from modiﬁed short- 
%        time fourier transform,” IEEE Trans. Acoust., Speech, Signal
%        Process., vol. 32, no. 2, pp. 236–243, 1984. 
%
% See also 
%    WAVELET_1D, INVERSE_WAVELET_1D

function x = griffin_lim(x_init, x_phi, x_psi_mod, filters, options)
	options = fill_struct(options, 'gl_iter', 32);
	
	dual_filters = dual_filter_bank(filters);
	
	x0 = x_init;
	[x0_phi, x0_psi, meta_phi, meta_psi] = wavelet_1d(x0, filters, options);
	
	for iter = 1:options.gl_iter
		for k = 1:length(filters.psi.filter)
			if isempty(x_psi_mod{k})
				x1_psi{k} = x0_psi{k};
			else
				x1_psi{k} = x0_psi{k}.*x_psi_mod{k}./abs(x0_psi{k});
			end
		end
		
		x1 = inverse_wavelet_1d(length(x_init), x_phi, x1_psi, meta_phi, ...
			meta_psi, dual_filters, options);
		[x0_phi, x0_psi, meta_phi, meta_psi] = wavelet_1d(x1, filters, ...
			options);
	end
	
	x = x1;
end