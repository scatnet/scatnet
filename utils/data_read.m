% DATA_READ Read data (audio, image) file
%
% Usage
%    x = DATA_READ(filename, ...);
%
% Input
%    filename (char): The file to read.
%
% Output
%    x (numeric): The contents of the file. In the case of audio, this is a
%       one-dimensional vector, while for images, it is a two-dimensional
%       array. If the file is a MAT file, the function simply loads the
%       'signal' variable and returns its contents.
%
% Description
%    Detecting the type of file that filename refers to, the function calls
%    one of AUREAD, WAVREAD, SPHERE_READ, AUDIO_READ, IMREADBW, or LOAD in
%    order to read the data contained in the file. Any additional arguments are
%    passed on to the loading function.
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
			if exist('audioread')
				% If present, use it since it can read more sophisticated
				% types of WAV files
				[varargout{1},varargout{2}] = audioread(file,varargin{:});
			else
				[varargout{1},varargout{2}] = wavread(file,varargin{:});
			end
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
	elseif length(file) > 4 && strcmpi(file(end-3:end), '.mat')
		f = load(file);
		varargout{1} = f.signal;
	else
		error('Unknown file extension!');
	end
end
