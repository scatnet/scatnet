% wavemod_1d: 1D wavelet modulus transform.
% Usage
%    [S,U] = wavemod_1d(in, filters, options)
% Input
%    in: The input layer to be transformed.
%    filters: The filters of the wavelet transform.
%    options: Various options for the transform. options.antialiasing controls
%       the antialiasing factor when subsampling.
% Output
%    S: The coefficients of in, lowpass-filtered (scattering coefficients).
%    U: The wavelet modulus coefficients.

function [S,U] = wavemod_1d(in,filters,options)
	if nargin < 3
		options = struct();
	end
	
	calc_U = (nargout>=2);

	options = fill_struct(options,'antialiasing',1);
	
	[psi_xi,psi_bw,phi_bw] = filter_freq(filters);
	
	S.signal = {};
	S.meta.bandwidth = [];
	S.meta.resolution = [];
	S.meta.scale = zeros(0,size(in.meta.scale,2));
	
	U.signal = {};
	U.meta.bandwidth = [];
	U.meta.resolution = [];
	U.meta.scale = zeros(0,size(in.meta.scale,2)+1);
	
	rS = 1;
	rU = 1;
	for k1 = 0:length(in.signal)-1
		sig = in.signal{k1+1};
		sig_f = fft(sig,[],1);	
		
		filter_bw = phi_bw;
		ds = max(0,round(log2(2*pi/filter_bw))-log2(filters.N/size(sig,1))-options.antialiasing);
		S.signal{rS} = real(conv_sub_1d(sig_f,filters.phi.filter,ds));
		S.meta.bandwidth(rS,1) = filter_bw;
		S.meta.resolution(rS,1) = log2(filters.N/size(S.signal{rS},1));
		S.meta.scale(rS,:) = in.meta.scale(k1+1,:);
		
		rS = rS+1;
		
		if ~calc_U
			continue;
		end
		
		for k2 = find(in.meta.bandwidth(k1+1)>psi_xi)-1
			filter_bw = psi_bw(k2+1);
			ds = max(0,round(log2(2*pi/filter_bw/2))-log2(filters.N/size(sig,1))-options.antialiasing);
			U.signal{rU} = abs(conv_sub_1d(sig_f,filters.psi.filter{k2+1},ds));
			U.meta.bandwidth(rU,1) = filter_bw;
			U.meta.resolution(rU,1) = log2(filters.N/size(U.signal{rU},1));
			U.meta.scale(rU,:) = [in.meta.scale(k1+1,:) k2];
			
			rU = rU+1;
		end
	end
end
