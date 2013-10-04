% morlet_filter_bank_1d: Creates a spline wavelet filter bank.
% Usage
%    filters = spline_filter_bank_1d(sz, options)
% Input
%    sz: The size of the input data.
%    options (optional): Filter parameters.
% Output
%    filters: The spline wavelet filter bank corresponding to the data size sz
%       and the filter parameters in options.
% Description
%    Spline wavelet filters are defined for orders 1 (linera) and 3 (cubic) 
%    according to formulas in [1], except that the filters are chosen to be
%    symmetric around 0.
%
%    The following options can be specified:
%       options.J: The number of filters to generate. This controls the maxi-
%          mum size of the wavelets according to the formula 2^J (default 
%          log2(sz))
%       options.spline_order: Either 1 or 3. The former gives linear spline
%          wavelets while the latter gives cubic spline wavelets (default 3).
%       options.boundary, options.precision, and options.filter_format: 
%          See documentation for filter_bank function.
% References
%    [1] S. Mallat, "A wavelet tour of signal processing: the sparse way." 
%       Academic Press, 2008, pp. 291-292

function filters = spline_filter_bank_1d(sig_length,options)
	if nargin < 2
		options = struct();
	end
	
	sig_length = sig_length(1);
	
	options = fill_struct(options,'Q',1);
	options = fill_struct(options,'B',1);
	options = fill_struct(options,'J',round(log2(sig_length)));
	options = fill_struct(options,'P',0);
	options = fill_struct(options,'spline_order',3);
	options = fill_struct(options,'precision','double');
	options = fill_struct(options,'boundary','symm');
	options = fill_struct(options,'filter_format','fourier_truncated');
	
	if options.Q ~= 1
		error('Only one wavelet per octave allowed for spline wavelets');
	end
	
	if options.B ~= 1
		error('Bandwidth is fixed for spline wavelets');
	end

	if options.P ~= 0
		error('No constant-bandwidth filters allowed for spline wavelets');
	end

	if options.spline_order ~= 1 && ...
	   options.spline_order ~= 3
		error('Only linear and cubic splines supported!');
	end

	if ~strcmp(options.precision,'single') && ...
	   ~strcmp(options.precision,'double')
		error('Precision must be ''single'' or ''double''');
	end

	J = options.J;
	spline_order = options.spline_order;
	precision = options.precision;

	if strcmp(precision,'double')
		cast = @double;
	else
		cast = @single;
	end
	
	if spline_order == 1
		S = @(omega)((1+2*cos(omega/2).^2)./(48*sin(omega/2).^4));
	elseif spline_order == 3
		S = @(omega)((5+30*cos(omega/2).^2+30*sin(omega/2).^2.*cos(omega/2).^2+70*cos(omega/2).^4+ ...
			2*sin(omega/2).^4.*cos(omega/2).^2+2/3*sin(omega/2).^6)./(105*2^8*sin(omega/2).^8));
	end
	
	if (strcmp(options.boundary, 'symm'))
		N = 2*sig_length;
	else
		N = sig_length;
	end
	
	filters.meta.J = J;
	
	filters.meta.size_filter = N;
	
	filters.meta.spline_order = spline_order;
	
	filters.meta.boundary = options.boundary;
	
	filters.psi.filter = cell(1,J);
	filters.phi = [];
		
	omega = [0:N-1]'/N*2*pi;
	
	for j1 = 0:J-1
		support = 1:N;
		omega1 = 2^(j1+1)*omega(support);
		filter_f = zeros(N,1,precision);
		filter_f(support) = sqrt(2)*1./omega1.^(spline_order+1).* ...
			sqrt(S(omega1/2+pi)./(S(omega1).*S(omega1/2)));

		% Take care of Inf/Inf
		ind = N/2^(j1+1)+1:N/2^j1:N;
		filter_f(ind) = sqrt(2)*1./omega1(ind).^(spline_order+1).* ...
			sqrt(2^(2*spline_order+2)./S(omega1(ind)/2));
		
		% Take care of 1/Inf
		ind = 1:N/2^j1:N;
		filter_f(ind) = 0;

		filter_f = cast(filter_f);
		
		filters.psi.filter{j1+1} = optimize_filter(filter_f,0,options);
		filters.psi.meta.k(j1+1) = j1;
	end
	
	if J > 0
		omega = [0:N/2 -N/2+1:-1]'/N*2*pi;
		omega1 = 2^J*omega;
		filters.phi.filter = 1./(omega1.^(spline_order+1).*sqrt(S(omega1)));
		filters.phi.filter(1) = 1;

		filters.phi.filter = cast(filters.phi.filter);
	else
		filters.phi.filter = ones(N,1,precision);
	end
	
	filters.phi.filter = optimize_filter(filters.phi.filter,1,options);
	
	filters.phi.meta.k(1,1) = options.J;

	filters.meta.filter_type = 'spline_1d';
end
