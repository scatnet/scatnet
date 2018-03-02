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

	if numel(varargin) == 0
		cached_data = cache_util(2, file);
		if ~isempty(cached_data)
			varargout{1} = cached_data;
			return;
		end
	end

	if ~isempty(varargin) && strcmp(varargin{end}, 'nocache')
		varargin = varargin(1:end-1);
	end

	is_1d = false;
	
	if length(file) > 3 && strcmpi(file(end-2:end),'.au')
		[varargout{1},varargout{2}] = auread(file,varargin{:});
		is_1d = true;
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
		is_1d = true;
	elseif length(file) > 4 && strcmpi(file(end-3:end), '.ogg')
		if exist('audioread')
			[varargout{1},varargout{2}] = audioread(file,varargin{:});
		else
			error('Cannot read OGG file since audioread is not present!');
		end
		is_1d = true;
	elseif length(file) > 4 && (strcmpi(file(end-3:end),'.jpg')...
			|| strcmpi(file(end-3:end),'.png') )
		varargout{1} = imreadBW(file,varargin{:});
	elseif length(file) > 4 && strcmpi(file(end-3:end), '.mat')
		f = load(file);
		varargout{1} = f.signal;
	else
		error('Unknown file extension!');
	end

	if isempty(varargin) && is_1d
		varargout{1} = mean(varargout{1}, 2);
	end
end
