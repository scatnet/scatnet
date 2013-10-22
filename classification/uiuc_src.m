% uiuc_src: Creates a source for the UIUC Texture dataset.
%
% Usage
%    src = uiuc_src(directory)
%
% Input
%    directory: The directory containing the UIUC Texture dataset.
%
% Output
%    src: The UIUC source.
%
% Note
%	The dataset is available at http://www-cvr.ai.uiuc.edu/ponce_grp/data/


function src = uiuc_src(directory)
	if (nargin<1)
		directory = ''; % PUT DEFAULT DIRECTORY HERE
	end
	src = create_src(directory, @uiuc_extract_objects_fun);
end

function [objects, classes] = uiuc_extract_objects_fun(file)
	objects.u1 = [1, 1];
	objects.u2 = [480, 640];
	path_str = fileparts(file);
	path_parts = regexp(path_str, filesep, 'split');
	classes = {path_parts{end}};
end