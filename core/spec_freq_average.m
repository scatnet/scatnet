function [out,meta] = spec_freq_average(in,filters,options)
	options = fill_struct(options,'oversampling',1);
	
	filters1 = filters{1};
	filters2 = filters{min(2,numel(filters))};
	
	[temp1,temp2,phi2_bw] = filter_freq(filters{2});

	supp_mult = 4;
	
	N = size(in,1);
	Nfilt = filters1.N;
	N1 = 2^round(log2(2*pi/phi2_bw));
	
	fs = zeros(N1*supp_mult,length(filters1.psi.filter));
	
	for k1 = 0:length(filters1.psi.filter)-1
		f_temp = realize_filter(filters1.psi.filter{k1+1});
		fs(:,k1+1) = abs(f_temp(1:Nfilt/(N1*supp_mult):Nfilt));
	end
	
	window = ifft(realize_filter(filters2.phi.filter));
	window = [window(Nfilt-N1*supp_mult/2+1:Nfilt); window(1:N1*supp_mult/2)];
	
	frames = zeros(length(window),round(N/N1*2^options.oversampling),size(in,2));
	
	out = zeros(size(frames,2),size(fs,2),size(in,2));
	
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

	meta.order = ones(size(fs,2),1);
	meta.scale = [0:size(fs,2)-1]';
	meta.bandwidth = phi2_bw*ones(size(fs,2),1);
	meta.resolution = resolution*ones(size(fs,2),1);
	
	X = cell(1,2);
	X{1}.signal = {};
	X{1}.meta.bandwidth = zeros(1,0);
	X{1}.meta.scale = zeros(1,0);
	
	X{2}.signal = cell(1,size(out,1));
	X{2}.meta = meta;
	
	for k0 = 0:size(out,1)-1
		X{2}.signal{k0+1} = reshape(out(k0+1,:,:),size(out,2),size(out,3));
	end

	out = X;
end
