% FMD_SRC Creates a source for the FMD Texture dataset
%
% Usage
%    src = FMD_SRC(directory)
%
% Input
%    directory: The directory containing the FMD Texture dataset.
%
% Output
%    src: The FMD source.
%
% Note
%	The dataset is available at http://people.csail.mit.edu/celiu/CVPR2010/FMD/


function src = fmd_src(directory)
	if nargin<1
		directory = '/Users/laurentsifre/TooBigForDropbox/Databases/FMD/image/';
	end
	src = create_src(directory, @uiuc_extract_objects_fun);
end

function [objects, classes] = uiuc_extract_objects_fun(file)
	objects.u1 = [1, 1];
	objects.u2 = [512, 384];
	path_str = fileparts(file);
	path_parts = regexp(path_str, filesep, 'split');
	classes = {path_parts{end}};
end
