% KTHTIPS_SRC Creates a source for the KTH TIPS Texture dataset
%
% Usage
%    src = KTHTIPS_SRC(directory)
%
% Input
%    directory: The directory containing the KTH TIPS Texture dataset.
%
% Output
%    src: The KTH TIPS source.
%
% Note
%	The dataset is available at http://www.nada.kth.se/cvap/databases/kth-tips/

function src = kthtips_src(directory)
	if (nargin<1)
		directory = '/Users/laurentsifre/TooBigForDropbox/Databases/KTH_TIPS';
	end
	src = create_src(directory, @uiuc_extract_objects_fun);
end

function [objects, classes] = uiuc_extract_objects_fun(file)
	objects.u1 = [1, 1];
	x = imreadBW(file);
	[h, w] = size(x);
	objects.u2 = [h, w];
	path_str = fileparts(file);
	path_parts = regexp(path_str, filesep, 'split');
	classes = {path_parts{end}};
end
