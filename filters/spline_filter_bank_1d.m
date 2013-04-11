%TODO: redo doc
%SPLINE_FILTER_BANK Create a filter bank of spline wavelets
%   filters = spline_filter_bank(sig_length,options) generates a 
%   spline wavelet (linear,cubic) filterbank for signals of length sig_length 
%   using parameters contained in options.
%
%   The following options can be specified
%      options.J - The maximal scale of the filters, giving a maximal temporal
%         support of 2^(J-1) [default 4]
%      options.spline_order - If 1, generates linear splines and if 3
%         generates cubic splines [default 3]
%      options.precision - The precision, 'double' or 'single', used to define 
%         the filters. [Default 'double']
%      options.optimize - The optimization technique used to store the
%         filters. If set to 'none', filters are stored using their full
%         Fourier transform. If 'periodize', filters are periodized to create
%         Fourier transform at lower resolutions. Finally, if 'truncate', 
%         the Fourier transform of the filter is truncated and its support is
%         stored. [Default 'truncate']

function filters = spline_filter_bank_1d(sig_length,options)
	if nargin < 2
		options = struct();
	end
	
	options = fill_struct(options,'V',1);
	options = fill_struct(options,'J',floor(log2(sig_length)*options.V+1e-6));
	options = fill_struct(options,'P',0);
	options = fill_struct(options,'spline_order',3);
	options = fill_struct(options,'precision','double');
	options = fill_struct(options,'filter_format','fourier_truncated');
	
	if options.V ~= 1
		error('Only one wavelet per octave allowed for spline wavelets');
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
	
	N = sig_length;
	
	filters.J = J;
	
	filters.N = N;
	
	filters.psi.filter = cell(1,J);
	filters.phi = [];
		
	omega = [0:N-1]'/N*2*pi;
	
	for j1 = 0:J-1
		support = 1:N;
		omega1 = 2^(j1+1)*omega(support);
		filter_f = zeros(N,1,precision);
		filter_f(support) = sqrt(2)*exp(-i*omega1/2)./omega1.^(spline_order+1).* ...
			sqrt(S(omega1/2+pi)./(S(omega1).*S(omega1/2)));

		% Take care of Inf/Inf
		ind = N/2^(j1+1)+1:N/2^j1:N;
		filter_f(ind) = sqrt(2)*exp(-i*omega1(ind)/2)./omega1(ind).^(spline_order+1).* ...
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

	filters.filter_type = 'spline_1d';
end
