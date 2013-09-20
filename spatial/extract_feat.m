function db = extract_feat(src, fun)
	time_start = clock;
	db.src = src;
	for k = 1:length(src.files)
		db.indices{k} = k;
		tmp  = fun(src.files{k});
		db.features(k,:) = reshape(tmp, [numel(tmp), 1]);

		
		tm0 = tic;
		time_elapsed = etime(clock, time_start);
		estimated_time_left = time_elapsed * (length(src.files)-k) / k;
		fprintf('calculated features for %s. (%.2fs)\n',src.files{k},toc(tm0));
		fprintf('%d / %d : estimated time left %d seconds\n',k,length(src.files),floor(estimated_time_left));		
	end
	db.features = db.features';
end