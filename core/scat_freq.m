function [S,U] = scat_freq(X, Wop)
	Y = concatenate_freq(X);
	
	S = {};
	U = {};
	
	for m = 0:length(X)-1
		r = 1;
		
		S{m+1} = {};
		U{m+1} = {};
		
		for k = 1:length(Y{m+1}.signal)
			% note: here each signal is a table
			signal = Y{m+1}.signal{k};
			
			sz_orig = size(signal);
			sz_orig = [sz_orig ones(1,3-length(sz_orig))];
			
			ind = r:r+size(signal,1)-1;
			
			signal = reshape(signal,[sz_orig(1) 1 prod(sz_orig(2:3))]);
			
			if m > 0
				[S_fr,U_fr] = scat(signal, Wop);
				
				% needed for the case of U, are not init by scat
				if ~isfield(U_fr{1}.meta,'bandwidth')
					U_fr{1}.meta.bandwidth = 2*pi;
				end
				if ~isfield(U_fr{1}.meta,'resolution')
					U_fr{1}.meta.resolution = 0;
				end
			else
				S_fr = {};
				
				S_fr{1}.signal = {signal};
				S_fr{1}.meta.bandwidth = 2*pi;
				S_fr{1}.meta.resolution = 0;
				S_fr{1}.meta.j = -1;
				
				U_fr = {};

				U_fr{1}.signal = {signal};
				U_fr{1}.meta.bandwidth = 2*pi;
				U_fr{1}.meta.resolution = 0;
				U_fr{1}.meta.j = -1;
			end
			
			if isempty(S{m+1})
				for mp = 0:length(S_fr)-1
					S{m+1}{mp+1}.signal = {};
					U{m+1}{mp+1}.signal = {};
					rp(mp+1) = 1;
					rb(mp+1) = 1;
				end
			end
			
			for mp = 0:length(S_fr)-1
				for kp = 1:length(S_fr{mp+1}.signal)
					for t = 0:1
						if t == 0
							X_fr = S_fr;
							X = S;
							rc = rp;
						else
							X_fr = U_fr;
							X = U;
							rc = rb;
						end
					
						nsignal = X_fr{mp+1}.signal{kp};
					
						j1_count = size(nsignal,1);
					
						ds = X_fr{mp+1}.meta.resolution(kp);
					
						inds = ind(1:2^ds:end);
					
						nsignal = reshape(nsignal,[j1_count sz_orig(2:3)]);
					
						for j1 = 1:j1_count
							X{m+1}{mp+1}.signal{rc(mp+1)} = ...
								reshape(nsignal(j1,:,:), ...
									[sz_orig(2) 1 sz_orig(3)]);
							X{m+1}{mp+1}.meta.bandwidth(1,rc(mp+1)) = ...
								Y{m+1}.meta.bandwidth(inds(j1));
							X{m+1}{mp+1}.meta.resolution(1,rc(mp+1)) = ...
								Y{m+1}.meta.resolution(inds(j1));
							X{m+1}{mp+1}.meta.j(:,rc(mp+1)) = ...
								Y{m+1}.meta.j(:,inds(j1));
							X{m+1}{mp+1}.meta.fr_bandwidth(1,rc(mp+1)) = ...
								X_fr{mp+1}.meta.bandwidth(kp);
							X{m+1}{mp+1}.meta.fr_resolution(1,rc(mp+1)) = ...
								X_fr{mp+1}.meta.resolution(kp);
							X{m+1}{mp+1}.meta.fr_j(:,rc(mp+1)) = ...
								X_fr{mp+1}.meta.j(:,kp);
							rc(mp+1) = rc(mp+1)+1;
						end
						
						if t == 0
							S_fr = X_fr;
							S = X;
							rp = rc;
						else
							U_fr = X_fr;
							U = X;
							rb = rc;
						end
					end
				end
			end
			
			r = r+size(signal,1);
		end
	end
	
	for m = 0:length(S)-1
		temp = flatten_scat(S{m+1});
		temp = temp{1};
		temp.meta.fr_order = temp.meta.order;
		temp.meta = rmfield(temp.meta,'order');
		S{m+1} = temp;
		
		temp = flatten_scat(U{m+1});
		temp = temp{1};
		temp.meta.fr_order = temp.meta.order;
		temp.meta = rmfield(temp.meta,'order');
		U{m+1} = temp;
	end
end
