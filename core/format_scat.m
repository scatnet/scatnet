% format_scat: Formats a scattering transform
% Usage
%    [out, meta] = format_scat(S, fmt)
% Input
%    S: The scattering transform to be formatted.
%    fmt (optional): The desired format. Can be one of 'raw', 'order_table' or
%       'table' (default 'table').
% Output
%    out: The scattering transform in the desired format (see below).
%    meta: If needed, a meta structure containing the properties of the sig-
%       nals in out.
% Description
%    Three different formats are available for the scattering transform:
%       'raw': Do nothing, just return S. The meta structure is empty.
%       'order_table': For each order, create a table of scattering 
%          coefficients with scattering index running along the first dimen-
%          sion, time/space along the second, and signal index along the 
%          third. The out variable is then a cell array of tables, while
%          the meta variable is a cell array of meta structures, each 
%          corresponding to the meta structure for the given order. 
%       'table': Same as 'order_table', but with the tables for each order
%          concatenated into one table, which is returned as out. Note that
%          this requires that each order is of the same resolution, that is
%          that the lowpass filter phi of each filter bank is of the same
%          bandwidth. The meta variable is one meta structure formed by con-
%          catenating the meta structure of each order and filling out with
%          -1 where necessary (the j field, for example).

function [out,meta] = format_scat(X,fmt)
	if nargin < 2
		fmt = 'table';
	end
	
	if strcmp(fmt,'raw')
		out = X;
		meta = [];
	elseif strcmp(fmt,'table') || strcmp(fmt,'order_table')
		tables = {};
		metas = {};
		
		if strcmp(fmt,'table')
			last = -1;
			for m = 0:length(X)-1
				if length(X{m+1}.signal) == 0
					continue;
				end
				
				if last == -1
					last = m;
					continue;
				end
				
				if size(X{m+1}.signal{1},1) ~= size(X{last+1}.signal{1},1)
					error(['To use ''table'' output format, all orders ' ...
						'must be of the same resolution. Consider using ' ...
						'the ''order_table'' output format.']);
				end
			end
			
			X = flatten_scat(X);
		end
		
		last = 0;
		for m = 0:length(X)-1
			if length(X{m+1}.signal) == 0
				tables{m+1} = [];
			else
				tables{m+1} = zeros( ...
					[length(X{m+1}.signal), ...
					size(X{m+1}.signal{1},1), ...
					size(X{m+1}.signal{1},2)], ...
					class(X{m+1}.signal{1}));
				
				for j1 = 0:length(X{m+1}.signal)-1
					tables{m+1}(j1+1,:,:) = X{m+1}.signal{j1+1};
				end
				
				last = m;
			end
			
			if size(tables{m+1},3) == 1
				tables{m+1} = tables{m+1}(:,:,1);
			end
			
			metas{m+1} = X{m+1}.meta;
		end
	
		if strcmp(fmt,'table')
			out = tables{1};
			meta = metas{1};
		else
			out = tables;
			meta = metas;
		end
	end
end
