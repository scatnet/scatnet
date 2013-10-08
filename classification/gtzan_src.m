% GTZAN_SRC Creates a source for the GTZAN dataset
%
% Usage
%    src = GTZAN_SRC(directory, N)
%
% Input
%    directory (char): The directory containing the GTZAN dataset.
%    N (int): The size to which the audio files are to be truncated (default 
%       5*2^17).
%
% Output
%    src (struct): The GTZAN source.
%
% Description
%    Creates a source index for the GTZAN dataset (available at 
%    http://marsyasweb.appspot.com/download/data_sets/) that can be used for
%    calculating a feature database and classifying musical genres.
%
% See also
%    CREATE_SRC

function src = gtzan_src(directory,N)
	if nargin < 1
		directory = 'gtzan';
	end
	
	if nargin < 2
		N = 5*2^17;
	end
	
	src = create_src(directory,@(file)(gtzan_objects_fun(file,N)));
end

function [objects,classes] = gtzan_objects_fun(file,N)
	objects.u1 = 1;
	objects.u2 = N;
	
	path_str = fileparts(file);
	
	path_parts = regexp(path_str,filesep,'split');
	
	classes = {path_parts{end}};
end