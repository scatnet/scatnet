% selesnick_filter_bank_1d: Creates a Selesnick wavelet filter bank.
% Usage
%    filters = selesnick_filter_bank_1d(sz, options)
% Input
%    sz: The size of the input data.
%    options (optional): Filter parameters.
% Output
%    filters: The Selesnick wavelet filter bank corresponding to the data 
%       size sz and the filter parameters in options.
% Description
%    Selesnick wavelet filters are compactly supported complex wavelets, 
%    whose real and imaginary parts have 4 vanishing moments and are nearly
%    Hilbert transform pairs.
%
%    The following options can be specified:
%       options.J: The number of filters to generate. This controls the 
%          maximum size of the wavelets according to the formula 2^J 
%          (default log2(sz)).
%       options.boundary, options.precision, and options.filter_format: 
%          See documentation for filter_bank function.
% References
%   http://eeweb.poly.edu/iselesni/WaveletSoftware/dt1D.html

function filters = selesnick_filter_bank_1d(sig_length,options)
	if nargin < 2
		options = struct();
	end
	
	sig_length = sig_length(1);
	
	options = fill_struct(options,'Q',1);
	options = fill_struct(options,'J',round(log2(sig_length)));
	options = fill_struct(options,'precision','double');
	options = fill_struct(options,'boundary','symm');
	options = fill_struct(options,'filter_format','fourier_truncated');

    if options.Q ~= 1
		error('Only one wavelet per octave allowed for Selesnick wavelets');
    end

	if ~strcmp(options.precision,'single') && ...
	   ~strcmp(options.precision,'double')
		error('Precision must be ''single'' or ''double''');
	end

	J = options.J;
	precision = options.precision;

	if strcmp(precision,'double')
		cast = @double;
	else
		cast = @single;
	end

	if (strcmp(options.boundary, 'symm'))
		N = 2*sig_length;
	else
		N = sig_length;
	end

	filters.meta.J = J;
	
	filters.meta.size_filter = N;
		
	filters.meta.boundary = options.boundary;
    
    filters.meta.filter_type = 'selesnick_1d';
	
	filters.psi.filter = cell(1,J);
    filters.psi.meta.k = zeros(1,J);
	
    filters.phi = [];
    
    outf = selesnick_bis([N 1], options);
    
    for j1=0:J-1
        filter_f = outf.psi{1}{j1+1}{1};
        filter_f = cast(filter_f);
        filters.psi.filter{j1+1} = optimize_filter(filter_f,0,options);
        filters.psi.meta.k(j1+1) = j1;
    end
    
    filter_f = outf.phi;
    filter_f = cast(filter_f);
    filters.phi.filter = optimize_filter(filter_f,1,options);
    filters.phi.meta.k(1,1) = options.J;

end