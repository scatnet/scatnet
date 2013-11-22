% PREPARE_DATABASE Calculates the features from objects in a source
%
% Usage
%    database = PREPARE_DATABASE(src, feature_fun, options)
%
% Input
%    src (struct): The source specifying the objects.
%    feature_fun (cell): The feature functions applied to each object.
%    options (struct): Options for calculating the features:
%       options.feature_sampling (int): specifies how to sample the feature 
%           vectors in time/space (default 1).
%       options.file_normalize (int): The normalization of each file before 
%          being given to feature_fun. Can be empty, 1, 2, or Inf (default []).
%       options.parallel (boolean): If true, tries to use the Distributed 
%          Computing Toolbox to speed up calculation (default true).
%       Other options are listed in the help for the FEATURE_WRAPPER function.
% Output
%    database (struct): The database of feature vectors.
%
% See also
%    CREATE_SRC, FEATURE_WRAPPER

function db = prepare_database(src,feature_fun,opt)
	if nargin < 3
		opt = struct();
	end
	
	opt = fill_struct(opt, 'feature_sampling', 1);
	opt = fill_struct(opt, 'file_normalize', []);
	opt = fill_struct(opt, 'parallel', 1);
	
	features = cell(1,length(src.files));
	obj_ind = cell(1,length(src.files));
	
	rows = 0;
	cols = 0;
	precision = 'double';
	
	if opt.parallel
		% parfor loop - note that the contents are the same as the serial loop, but
		% MATLAB doesn't seem to offer an easy way of deduplicating the code.

		% Loop through all the files in the source
		parfor k = 1:length(src.files)
			% Identify all the objects contained in the current file
			file_objects = find([src.objects.ind]==k);
	
			if length(file_objects) == 0
				% No objects, skip.
				continue;
			end
			
			tm0 = tic;

			% Load the complete file and normalize as needed.
			x = data_read(src.files{k});
			
			if ~isempty(opt.file_normalize)
				if opt.file_normalize == 1
					x = x/sum(abs(x(:)));
				elseif opt.file_normalize == 2
					x = x/sqrt(sum(abs(x(:)).^2));
				elseif opt.file_normalize == Inf
					x = x/max(abs(x(:)));
				end
			end
		
			% Due to parallelization constraints, each file stores its feature vectors 
			% in one index of the features cell array. The corresponding object indices
			% are stored in the obj_ind cell array.
			features{k} = cell(1,length(file_objects));
			obj_ind{k} = file_objects;
			
			% Apply all the feature functions to the objects contained in x. The output
			% buf is a PxNxK vector, where P corresponds to number of feature coeffi-
			% cients, N corresponds to the number of features - the number of "windows"
			% - in each object, and K corresponds to the number of objects.
			buf = apply_features(x,src.objects(file_objects),feature_fun,opt);
			
			% Subsample among the features as needed.
			buf = buf(:,1:opt.feature_sampling:end,:);

			% Separate each of the objects into its own array element.
			for l = 1:length(file_objects)
				features{k}{l} = buf(:,:,l);
			end
			fprintf('.');
		end
	else
		time_start = clock;
		for k = 1:length(src.files)
			file_objects = find([src.objects.ind]==k);
			
			if length(file_objects) == 0
				continue;
			end
			
			tm0 = tic;
			x = data_read(src.files{k});
			
			if ~isempty(opt.file_normalize)
				if opt.file_normalize == 1
					x = x/sum(abs(x(:)));
				elseif opt.file_normalize == 2
					x = x/sqrt(sum(abs(x(:)).^2));
				elseif opt.file_normalize == Inf
					x = x/max(abs(x(:)));
				end
			end
			
			features{k} = cell(1,length(file_objects));
			obj_ind{k} = file_objects;
			
			buf = apply_features(x,src.objects(file_objects),feature_fun,opt);
			
			buf = buf(:,1:opt.feature_sampling:end,:);

			for l = 1:length(file_objects)
				features{k}{l} = buf(:,:,l);
			end
			time_elapsed = etime(clock, time_start);
			estimated_time_left = time_elapsed * (length(src.files)-k) / k;
			fprintf('.');
		end
	end
	fprintf('\n');

	% Identify the files for which objects have been computed.
	nonempty = find(~cellfun(@isempty,features));

	% Determine the size of the features array. Each row corresponds to a feature 
	% coefficient, each column corresponds to a feature vector.
	rows = size(features{nonempty(1)}{1},1);
	cols = sum(cellfun(@(x)(sum(cellfun(@(x)(size(x,2)),x))),features(nonempty)));
	precision = class(features{nonempty(1)}{1});
	
	db.src = src;
	
	db.features = zeros(rows,cols,precision);
	
	db.indices = cell(1,length(src.objects));
	
	% Fill in the features array using the pre-calculated features.
	r = 1;
	for k = 1:length(features)
		for l = 1:length(features{k})
			ind = r:r+size(features{k}{l},2)-1;
			db.features(:,ind) = features{k}{l};
			db.indices{obj_ind{k}(l)} = ind;
			r = r+length(ind);
		end
	end
end

function out = apply_features(x,objects,feature_fun,opt)
	% For each feature function, apply it to the objects in x and concatenate
	% the results.

	if ~iscell(feature_fun)
		feature_fun = {feature_fun};
	end
	
	out = {};
	for k = 1:length(feature_fun)
		if nargin(feature_fun{k}) == 2
			% If only two inputs are given, the feature function will handle the cut
			% ting up of x into objects itself.
			out{k,1} = feature_fun{k}(x,objects);
		elseif nargin(feature_fun{k}) == 1
			% If only one input is given, the feature function relies on us to cut up
			% the input x into objects and feed them to it.
			out{k,1} = feature_wrapper(x,objects,feature_fun{k},opt);
		else
			error('Invalid number of inputs for feature function!')
		end
	end

	if length(feature_fun) == 1
		out = out{1};
	else
		% Concatenate along the first dimension - the feature dimension - of each
		% element.
		out = cellfun(@(x)(permute(x,[2 1 3])),out,'UniformOutput',false);
		out = permute([out{:}],[2 1 3]);
	end
end
