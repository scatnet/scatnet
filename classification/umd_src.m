% umd_src: Creates a source for the UMD Texture dataset.
%
% Usage
%    src = umd_src(directory)
%
% Input
%    directory: The directory containing the UMD Texture dataset.
%
% Output
%    src: The UMD source.
%


function src = umd_src(directory)
	if (nargin<1)
		directory = '/Users/laurentsifre/TooBigForDropbox/Databases/umd';
	end
	src = create_src(directory, @uiuc_extract_objects_fun);
end

function [objects, classes] = uiuc_extract_objects_fun(file)
	objects.u1 = [1, 1];
	objects.u2 = [960, 1280];
	path_str = fileparts(file);
	path_parts = regexp(path_str, filesep, 'split');
	classes = {path_parts{end}};
end