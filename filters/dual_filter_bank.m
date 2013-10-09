% DUAL_FILTER_BANK Calculate the dual filter bank
%
% Usage
%    dual_filters = DUAL_FILTER_BANK(filters)
%
% Input
%    filters (struct): The original filter bank, output from FILTER_BANK or
%        related functions.
%
% Output
%    dual_filters (struct): The filter bank consisting of dual filters.
%
% Description
%    In order to compute the inverse wavelet transform, the dual filters need
%    to be computed from the original filter bank. If A(omega) is defined as 
%    the Littlewood-Paley sum over the filters, as calculated in
%    LITTLEWOOD_PALEY, the dual filter Fourier transformed are defined 
%    according to
%        dual_psi_j(omega) = conj(psi_j(omega))/A(omega)
%        dual_phi(omega) = conj(phi(omega))/A(omega),
%    where conj denotes complex conjugation.
%
% See also 
%    FILTER_BANK, INVERSE_WAVELET_1D

function dual_filters = dual_filter_bank(filters)
	A = littlewood_paley(filters);
	
	dual_filters = filters;
	
	for k = 1:length(filters.psi.filter)
		old_psi = realize_filter(filters.psi.filter{k});
		new_psi = conj(old_psi)./A;
		opt.filter_format = 'fourier';
		if isstruct(filters.psi.filter{k})
			opt.filter_format = filters.psi.filter{k}.type;
		end
		dual_filters.psi.filter{k} = optimize_filter(new_psi, 0, opt);
	end
	
	old_phi = realize_filter(filters.phi.filter);
	new_phi = conj(old_phi)./A;
	opt.filter_type = 'fourier';
	if isstruct(filters.phi.filter)
		opt.filter_format = filters.phi.filter.type;
	end
	dual_filters.phi.filter = optimize_filter(new_phi, 1, opt);
end