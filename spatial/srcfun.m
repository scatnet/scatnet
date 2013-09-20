% srcfun : apply fun to each filenames of a ScatNet-compatible src
%
% Usage :
%   cell_out = srcfun(fun, src);
%
% Example of use :
%   

function cell_out = srcfun(fun, src)
	time_start = clock;
	for k = 1:length(src.files)
		db.indices{k} = k;
		filename = src.files{k};
		cell_out{k} = fun(filename);

		tm0 = tic;
		time_elapsed = etime(clock, time_start);
		estimated_time_left = time_elapsed * (length(src.files)-k) / k;
		fprintf('calculated features for %s. (%.2fs)\n',src.files{k},toc(tm0));
		fprintf('%d / %d : estimated time left %d seconds\n',k,length(src.files),floor(estimated_time_left));		
    end
end