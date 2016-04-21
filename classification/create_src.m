% CREATE_SRC Create a source of files & objects
%
% Usage
%    src = CREATE_SRC(directory, objects_fun)
%
% Input
%    directory (char): The directory in which the files are found.
%    objects_fun (function handle): Given a filename, objects_fun returns its 
%       constituent objects and their respective classes.
%
% Output
%    src (struct): The source corresponding to all data files (.jpg, .wav, 
%       .au) contained in directory and their objects as defined by 
%       objects_fun.
%
% See also
%    PREPARE_DATABASE

function src = create_src(directory,objects_fun)
	if nargin < 1
		error('Must specify directory!');
	end
	
	if nargin < 2
		objects_fun = @default_objects_fun;
	end
	
	files = find_files(directory);
	
	if isempty(files)
		error('No data files found in the specified directory!');
	end
	
	objects = cell(1, length(files));
	classes = cell(1, length(files));

	for ind = 1:length(files)
		[file_objects,file_classes] = objects_fun(files{ind});
		
		if ~isempty(file_objects)
			[file_objects.ind] = deal(ind);
		end

		objects{ind} = file_objects;
		classes{ind} = file_classes;
	end

	objects = [objects{:}];
	classes = [classes{:}];

	file_inds = [objects.ind];

	[file_inds,I,J] = unique(file_inds);

	J = num2cell(J);

	[objects.ind] = J{:};

	files = files(file_inds);

	fields = fieldnames(objects)';
	fields(strmatch('ind',fields)) = [];
	fields(strmatch('u1',fields)) = [];
	fields(strmatch('u2',fields)) = [];

	objects = orderfields(objects,[{'ind','u1','u2'} fields]);
	
	[classes,temp,obj_class] = unique(classes);
	
	obj_class = num2cell(obj_class);
	
	[objects.class] = obj_class{:};
	
	src.classes = classes;
	src.files = files;
	src.objects = objects;
end

function files = find_files(directory)
	extensions = {'au','wav','ogg','jpg','png','mat'};
	
	dir_list = dir(directory);
	
	files = {};
	
	for k = 1:length(dir_list)
		name = dir_list(k).name;
		
		% Hidden file or current/upper directory? Skip.
		if name(1) == '.'
			continue;
		end
		
		% Depending on file type, recurse or add file.
		if dir_list(k).isdir
			files = [files find_files(fullfile(directory,name))];
		else
			found = 0;
			for l = 1:length(extensions)
				len = length(extensions{l});
				if length(name) > len+1 && ...
				   strcmpi(name(end-len:end),['.' extensions{l}])
					found = l;
					break;
				end
			end
			if found > 0
				files = [files fullfile(directory,name)];
			end
		end
	end
end

