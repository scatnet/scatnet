function Z = scatt_freq(X,cascade)
	Y = concatenate_freq(X);
	
	Z = {};
	
	for m = 0:length(X)-1
		r = 1;
		
		Z{m+1} = {};
		
		for k = 1:length(Y{m+1}.signal)
			signal = Y{m+1}.signal{k};
			
			sz_orig = size(signal);
			if numel(sz_orig) == 2
				sz_orig(3) = 1;
			end
			
			ind = r:r+size(signal,1)-1;
			
			signal = reshape(signal,[sz_orig(1) sz_orig(2)*sz_orig(3)]);
			
			if m > 0
				sc_fr = scatt(signal,cascade);
			else
				sc_fr = {};
				
				sc_fr{1}.signal = {signal};
				sc_fr{1}.meta.bandwidth = 2*pi;
				sc_fr{1}.meta.resolution = 0;
				sc_fr{1}.meta.j = -1;
			end
			
			if isempty(Z{m+1})
				for mp = 0:length(sc_fr)-1
					Z{m+1}{mp+1}.signal = {};
					rp(mp+1) = 1;
				end
			end
			
			for mp = 0:length(sc_fr)-1
				sc_fr{mp+1} = unpad_layer_1d(sc_fr{mp+1},size(signal,1));
				
				for kp = 1:length(sc_fr{mp+1}.signal)
					nsignal = sc_fr{mp+1}.signal{kp};
					
					j1_count = size(nsignal,1);
					
					ds = sc_fr{mp+1}.meta.resolution(kp);
					
					inds = ind(1:2^ds:end);
					
					nsignal = reshape(nsignal,[j1_count sz_orig(2:3)]);
					
					for j1 = 1:j1_count
						Z{m+1}{mp+1}.signal{rp(mp+1)} = ...
							reshape(nsignal(j1,:,:),sz_orig(2:3));
						Z{m+1}{mp+1}.meta.bandwidth(1,rp(mp+1)) = ...
							Y{m+1}.meta.bandwidth(inds(j1));
						Z{m+1}{mp+1}.meta.resolution(1,rp(mp+1)) = ...
							Y{m+1}.meta.resolution(inds(j1));
						Z{m+1}{mp+1}.meta.j(:,rp(mp+1)) = ...
							Y{m+1}.meta.j(:,inds(j1));
						Z{m+1}{mp+1}.meta.fr_bandwidth(1,rp(mp+1)) = ...
							sc_fr{mp+1}.meta.bandwidth(kp);
						Z{m+1}{mp+1}.meta.fr_resolution(1,rp(mp+1)) = ...
							sc_fr{mp+1}.meta.resolution(kp);
						Z{m+1}{mp+1}.meta.fr_scale(:,rp(mp+1)) = ...
							sc_fr{mp+1}.meta.j(:,kp);
						rp(mp+1) = rp(mp+1)+1;
					end
				end
			end
			
			r = r+size(signal,1);
		end
		
		if m == 0
			Z{m+1} = {struct('signal',[],'meta',struct())};
		end
	end
	
	for m = 0:length(Z)-1
		temp = flatten_scatt(Z{m+1});
		Z{m+1} = temp{1};
	end
end

function Y = concatenate_freq(X)
	Y = {};
	
	for m = 0:length(X)-1
		[suffixes,temp,assigned] = unique(X{m+1}.meta.j(2:end,:).','rows');
		
		sz_orig = size(X{m+1}.signal{1});
		
		Y{m+1}.signal = {};
		Y{m+1}.meta.bandwidth = [];
		Y{m+1}.meta.resolution = [];
		Y{m+1}.meta.j = [];
		
		for k = 1:size(suffixes,1)
			ind = find(assigned==k);
			
			nsignal = [X{m+1}.signal{ind}];
			
			nsignal = reshape(nsignal,[sz_orig(1) sz_orig(2) length(ind)]);
			nsignal = permute(nsignal,[3 1 2]);
			
			Y{m+1}.signal{k} = nsignal;
			Y{m+1}.meta.bandwidth = [Y{m+1}.meta.bandwidth X{m+1}.meta.bandwidth(ind)];
			Y{m+1}.meta.resolution = [Y{m+1}.meta.resolution X{m+1}.meta.resolution(ind)];
			Y{m+1}.meta.j = [Y{m+1}.meta.j X{m+1}.meta.j(:,ind)];
		end
	end
end

function Z = separate_freq(Y)
	Z = {};
	
	for m = 0:length(Y)-1
		Z{m+1}.signal = {};
		Z{m+1}.meta.bandwidth = Y{m+1}.meta.bandwidth;
		Z{m+1}.meta.j = Y{m+1}.meta.j;
		
		r = 1;
		for k = 1:length(Y{m+1}.signal)
			% because matlab is stupid and ignores last dim if 1
			sz_orig = size(Y{m+1}.signal{k});
			if numel(sz_orig) == 2
				sz_orig(3) = 1;
			end
			
			for l = 1:size(Y{m+1}.signal{k},1)
				nsignal = Y{m+1}.signal{k}(l,:);
				
				nsignal = reshape(nsignal,[sz_orig(2) sz_orig(3)]);
				
				Z{m+1}.signal{r} = nsignal;
				
				r = r+1;
			end
		end
		
		[temp,I] = sort(Z{m+1}.meta.j(1:min(1,m),:));
		
		Z{m+1}.signal = Z{m+1}.signal(I);
		Z{m+1}.meta.bandwidth = Z{m+1}.meta.bandwidth(I);
		Z{m+1}.meta.j = Z{m+1}.meta.j(:,I);
	end
end