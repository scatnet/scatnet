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
	elseif length(file) > 4 && (strcmpi(file(end-3:end),'.jpg')...
			|| strcmpi(file(end-3:end),'.png') )
		varargout{1} = imreadBW(file,varargin{:});
	else
		error('Unknown file extension!');
	end
end
