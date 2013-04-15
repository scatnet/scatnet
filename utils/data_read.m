function varargout = data_read(file,varargin)
	if nargin < 1
		error('Must specify filename!');
	end
	
	if length(file) > 3 && strcmpi(file(end-2:end),'.au')
		[varargout{1},varargout{2}] = auread(file,varargin{:});
	elseif length(file) > 4 && strcmpi(file(end-3:end),'.wav')
		s = textread(file,'%s',1);
		if isempty(strfind(s{1},'NIST_1A'))
			% TODO: Allow for 'size' parameter
			[varargout{1},varargout{2}] = wavread(file,varargin{:});
		else
			[varargout{1},varargout{2}] = readnist(file,varargin{:});
		end
	elseif length(file) > 4 && strcmpi(file(end-3:end),'.jpg')
		varargout{1} = imreadBW(file,varargin{:});
	else
		error('Unknown file extension!');
	end
end
