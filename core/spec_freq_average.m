% SPEC_FREQ_AVERAGE Calulates the frequency-averaged spectrogram
%
% Usage
%    spec = SPEC_FREQ_AVERAGE(x, filters, options)
%
% Input
%    x (numeric): The signal to be transformed.
%    filters (cell): The set of filters used to calculate the spectrogram
%       and the frequency averaging.
%    options (struct): Various options to the function:
%       options.oversampling (int): The amount of oversampling with respect to
%          the critical bandwidth, as a power of 2 (default 1).
%
% Output
%    spec (numeric): The frequency-averaged spectrogram, arranged in as a 
%       first-order scattering transform.
%
% Description
%    First, the spectrogram of x is computed with respect to the second-order
%    lowpass filter filters{2}.phi, if it is present, otherwise filters{1}.phi
%    is used. Once a spectrogram is obtained, the filters in filters{1}.psi are
%    averaged with the spectrogram to each yield a time-varying coefficient.
%    The resulting signals are arranged in spec in the format of a first-order
%    scattering transform. As a result, spec{1}.signal is empty, since no 
%    zeroth-order coefficients are present. However, spec{2}.signal contains 
%    the frequency-averaged spectrogram coefficients, arranged in order of 
%    decreasing frequeny.
%
%    The accompanying meta structure is also analogous to the scattering 
%    transform. Notably, spec{2}.meta.order is equal to 1 for each coefficient
%    and spec{2}.meta.j gives the index of the filter used to compute the
%    frequency averaging.
%
% See also 
%   MORLET_FILTER_BANK_1D, WAVELET_FACTORY_1D

function [out,meta] = spec_freq_average(in,filters,options)
	options = fill_struct(options,'oversampling',1);
	
	filters1 = filters{1};
	filters2 = filters{min(2,numel(filters))};
	
	[temp1,temp2,phi2_bw] = filter_freq(filters{2}.meta);

	supp_mult = 4;
	
	N = size(in,1);
	sig_count = size(in,3);
	Nfilt = filters1.meta.size_filter;
	N1 = 2^round(log2(2*pi/phi2_bw));
	
	fs = zeros(N1*supp_mult,length(filters1.psi.filter));
	
	for k1 = 0:length(filters1.psi.filter)-1
		f_temp = realize_filter(filters1.psi.filter{k1+1});
		fs(:,k1+1) = abs(f_temp(1:Nfilt/(N1*supp_mult):Nfilt));
	end
	
	window = ifft(realize_filter(filters2.phi.filter));
	window = [window(Nfilt-N1*supp_mult/2+1:Nfilt); window(1:N1*supp_mult/2)];
	
	frames = zeros(length(window),round(N/N1*2^options.oversampling),sig_count);
	
	out = zeros(size(frames,2),size(fs,2),sig_count);
	
	for t = 0:size(out,1)-1
		ind = round(t*N1/2^options.oversampling+[-N1*supp_mult/2:N1*supp_mult/2-1]+1);
		
		% symmetric extension
		ind(ind<1) = 1-ind(ind<1);
		ind(ind>N) = 2*N+1-ind(ind>N);
			
		frames(:,t+1,:) = in(ind,:);
	end
	
	frames = bsxfun(@times,frames,window);
		
	frame_fm = abs(fft(frames,[],1));
		
	out = fs.'*reshape(frame_fm,[size(frame_fm,1) size(frame_fm,2)*size(frame_fm,3)]);
	out = reshape(out,[size(fs,2) size(frame_fm,2) size(frame_fm,3)]);
	
	resolution = round(log2(N1))-options.oversampling;

	meta.order = ones(1,size(fs,2));
	meta.scale = [0:size(fs,2)-1];
	meta.bandwidth = phi2_bw*ones(1,size(fs,2));
	meta.resolution = resolution*ones(1,size(fs,2));
	
	X = cell(1,2);
	X{1}.signal = {};
	X{1}.meta.bandwidth = zeros(1,0);
	X{1}.meta.scale = zeros(1,0);
	
	X{2}.signal = cell(1,size(out,1));
	X{2}.meta = meta;
	
	for k0 = 0:size(out,1)-1
		X{2}.signal{k0+1} = reshape(out(k0+1,:,:),[size(out,2) 1 size(out,3)]);
	end

	out = X;
end
