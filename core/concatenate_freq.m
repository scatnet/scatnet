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
