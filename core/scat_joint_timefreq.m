function [S,U] = scat_joint_timefreq(X,cascade)
	Y = concatenate_freq(X);
	
	S = {};
	U = {};
	
	for m = 0:length(X)-1
		r = 1;
		
		S{m+1} = {};
		U{m+1} = {};
		
		for k = 1:length(Y{m+1}.signal)
			signal = Y{m+1}.signal{k};
			
			sz_orig = size(signal);
			if numel(sz_orig) == 2
				sz_orig(3) = 1;
			end
			
			ind = r:r+size(signal,1)-1;
			
			signal = reshape(signal,[sz_orig(1) sz_orig(2) sz_orig(3)]);
			
			if m > 0
				% note that here scat is 2d
				[S_fr,U_fr] = scat(signal,cascade);
				
				% needed for the case of U, are not init by scat
				if ~isfield(U_fr{1}.meta,'bandwidth')
					U_fr{1}.meta.bandwidth = 2*pi*ones(2,1);
				end
				if ~isfield(U_fr{1}.meta,'resolution')
					U_fr{1}.meta.resolution = 0*ones(2,1);
				end
				if ~isfield(U_fr{1}.meta,'j1')
					U_fr{1}.meta.j1 = -1*ones(1,1);
				end
				if ~isfield(U_fr{1}.meta,'j2')
					U_fr{1}.meta.j2 = -1*ones(1,1);
				end
			else
				S_fr = {};
				
				S_fr{1}.signal = {signal};
				S_fr{1}.meta.bandwidth = 2*pi*ones(2,1);
				S_fr{1}.meta.resolution = 0*ones(2,1);
				S_fr{1}.meta.j1 = -1*ones(1,1);
				S_fr{1}.meta.j2 = -1*ones(1,1);
				
				U_fr = {};

				U_fr{1}.signal = {signal};
				U_fr{1}.meta.bandwidth = 2*pi*ones(2,1);
				U_fr{1}.meta.resolution = 0*ones(2,1);
				U_fr{1}.meta.j1 = -1*ones(1,1);
				U_fr{1}.meta.j2 = -1*ones(1,1);
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
				% what do these do?
				%S_fr{mp+1} = unpad_layer_1d(S_fr{mp+1},[size(signal,1), size(signal,2)]);
				%U_fr{mp+1} = unpad_layer_1d(U_fr{mp+1},[size(signal,1), size(signal,2)]);
				
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
						t_count = size(nsignal,2);
					
						ds = X_fr{mp+1}.meta.resolution(:,kp);
					
						j1_inds = ind(1:2^ds(1):end);
					
						nsignal = reshape(nsignal,[j1_count t_count sz_orig(3)]);
					
						for j1 = 1:j1_count
							X{m+1}{mp+1}.signal{rc(mp+1)} = ...
								reshape(nsignal(j1,:,:),t_count,sz_orig(3));
							X{m+1}{mp+1}.meta.bandwidth(1,rc(mp+1)) = ...
								X_fr{mp+1}.meta.bandwidth(2,kp)/2*pi* ...
								Y{m+1}.meta.bandwidth(j1_inds(j1));
							X{m+1}{mp+1}.meta.resolution(1,rc(mp+1)) = ...
								X_fr{mp+1}.meta.resolution(2,kp)+ ...
								Y{m+1}.meta.resolution(j1_inds(j1));
							X{m+1}{mp+1}.meta.j(:,rc(mp+1)) = ...
								Y{m+1}.meta.j(:,j1_inds(j1));
							X{m+1}{mp+1}.meta.fr_bandwidth(:,rc(mp+1)) = ...
								X_fr{mp+1}.meta.bandwidth(1,kp);
							X{m+1}{mp+1}.meta.fr_resolution(:,rc(mp+1)) = ...
								X_fr{mp+1}.meta.resolution(1,kp);
							X{m+1}{mp+1}.meta.tf_j1(:,rc(mp+1)) = ...
								X_fr{mp+1}.meta.j1(:,kp);
							X{m+1}{mp+1}.meta.tf_j2(:,rc(mp+1)) = ...
								X_fr{mp+1}.meta.j2(:,kp);
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
		temp.meta.tf_order = temp.meta.order;
		temp.meta = rmfield(temp.meta,'order');
		S{m+1} = temp;
		temp = flatten_scat(U{m+1});
		temp = temp{1};
		temp.meta.tf_order = temp.meta.order;
		temp.meta = rmfield(temp.meta,'order');
		U{m+1} = temp;
	end
end

