function [y, fs] = sphere_read(filename, N)
	fid = fopen(filename);
	
	if fid == -1
		error('File not found.');
	end
	
	line = fgets(fid);
	
	if (isnumeric(line) && line == -1) || isempty(strfind(line, 'NIST_1A'))
		error('Invalid NIST SPHERE file (header not present).');
	end
	
	line = fgets(fid);
	
	header_length = str2num(line);
	
	if isempty(header_length)
		error('Invalid NIST SPHERE file (header length not present).');
	end
	
	header_length = round(header_length);
	
	fclose(fid);
	
	fid = fopen(filename,'rt','ieee-le');
	
	[data, count] = fread(fid, header_length, 'uchar');
	
	fclose(fid);
	
	if count ~= header_length
		error('Invalid NIST SPHERE file (unable to read header).');
	end
	
	header = char(data');
	
	lines = regexp(header,char(10),'split');
	
	fs = [];
	byte_format = [];
	count = [];
	
	for k = 1:length(lines)
		if strfind(lines{k}, 'sample_coding') == 1
			if ~isempty(strfind(lines{k}, 'shorten'))
				error('Unsupported coding scheme (''shorten'').');
			end
		elseif strfind(lines{k}, 'sample_rate') == 1
			fs = strread(lines{k}, 'sample_rate -i %d');
		elseif strfind(lines{k}, 'sample_count') == 1
			count = strread(lines{k}, 'sample_count -i %d');
		elseif strfind(lines{k}, 'channel_count') == 1
			if strread(lines{k}, 'channel_count -i %d') > 1
				error('Unsupported number of channels (>1).');
			end
		elseif strfind(lines{k}, 'sample_n_bytes') == 1
			if strread(lines{k}, 'sample_n_bytes -i %d') ~= 2
				error('Unsupported bit depth (not 16 bits).');
			end
		elseif strfind(lines{k}, 'sample_byte_format') == 1
			byte_format = strread(lines{k}, 'sample_byte_format -s2 %s');
		end
	end
	
	if ischar(N) && strcmp(N,'size')
		y = count;
		return;
	end
	
	if isempty(byte_format)
		warning('''sample_byte_format'' not specified, assuming little-endian.');
		byte_format = '01';
	end
	
	if strcmp(byte_format, '01')
		endianness = 'le';
	elseif strcmp(byte_format, '10')
		endianness = 'be';
	else
		error('Unknown ''sample_byte_format''.');
	end
	
	fid = fopen(filename, 'r', ['ieee-' endianness]);
	
	temp = fread(fid, header_length, 'char');
	
	if isempty(count)
		count = Inf;
	end
	
	y = fread(fid, count, 'short');
end