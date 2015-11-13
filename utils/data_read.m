% DATA_READ Read data (audio, image) file
%
% Usage
%    x = DATA_READ(filename, ...)
%
% Input
%    filename (char): The file to read.
%
% Output
%    x (numeric): The contents of the file. In the case of audio, this is a 
%       one-dimensional vector, while for images, it is a two-dimensional 
%       array.
%
% Description
%    Detecting the type of file that filename refers to, the function calls one
%    of AUREAD, WAVREAD, SPHERE_READ, or IMREADBW in order to read the data 
%    contained in the file. Any additional arguments are passed on to the load-
%    ing function.
%
% See also
%    SPHERE_READ, IMREADBW

function varargout = data_read(file,varargin)
	if nargin < 1
		error('Must specify filename!');
	end
	
	if length(file) > 3 && strcmpi(file(end-2:end),'.au')
		[varargout{1},varargout{2}] = auread(file,varargin{:});
	elseif length(file) > 4 && strcmpi(file(end-3:end),'.wav')
		fid = fopen(file,'r');
		s = textscan(fid,'%s',1);
		fclose(fid);
		if isempty(strfind(s{1}{1},'NIST_1A'))
			[varargout{1},varargout{2}] = wavread(file,varargin{:});
		else
			[varargout{1},varargout{2}] = sphere_read(file,varargin{:});
		end
	elseif length(file) > 4 && strcmpi(file(end-3:end), '.ogg')
		if exist('audioread')
			[varargout{1},varargout{2}] = audioread(file,varargin{:});
		else
			error('Cannot read OGG file since audioread is not present!');
		end
	elseif length(file) > 4 && (strcmpi(file(end-3:end),'.jpg')...
			|| strcmpi(file(end-3:end),'.png') )
		varargout{1} = imreadBW(file,varargin{:});
	else
		error('Unknown file extension!');
	end
end
