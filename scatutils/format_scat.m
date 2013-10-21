% FORMAT_SCAT Formats a scattering representation
%
% Usages
%    [out,meta]  = FORMAT_SCAT(S)
%
%    [out, meta] = FORMAT_SCAT(S, fmt)
%
% Input
%    S (cell): The scattering representation to be formatted.
%    fmt (string): The desired format. Can be either 'raw',
%     'order_table' or 'table' (default 'table').
%
% Output
%    out: The scattering representation in the desired format (see below).
%    meta (struct): Properties of the scattering nodes in out.
%
% Description
%    Three different formats are available for the scattering transform:
%       'raw': Does nothing, just return S. The meta structure is empty.
%       'order_table': For each order, creates a table of scattering
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
%
% See also
%   FLATTEN_SCAT, REORDER_SCAT

function [out,meta] = format_scat(X,fmt)
	if nargin < 2
		fmt = 'table';
	end

	if strcmp(fmt,'raw')
		out = X;
		meta = [];
		return;
	end

	if strcmp(fmt,'table')
		resolution = cellfun(@(x) length(x.signal{1}),X);
		% if not all nonzero resolutions are equal, an error is thrown
		if ~all(nonzeros(resolution)==resolution(1))
			error(['To use ''table'' output format, all orders ' ...
			'must be of the same resolution. Consider' ...
			'using the ''order_table'' output format.']);
		end
		X = flatten_scat(X); % puts all layers together
	elseif ~strcmp(fmt,'order_table')
		error(['Unknown format. Available formats are ''raw'', ''table'''...
		' or ''order_table''.']);
	end

	M = length(X); % M equals 1 if X has been flattened
	out = cell(1,M);
	meta = cell(1,M);

	for m = 0:M-1
		if isempty(X{1+m}.signal)
			out{1+m} = [];
		else
			out{1+m} = zeros( ...
			[length(X{1+m}.signal) size(X{1+m}.signal{1})], ...
			class(X{1+m}.signal{1}));

			for j1 = 0:length(X{1+m}.signal)-1
				out{1+m}(1+j1,1:numel(X{1+m}.signal{1})) = ...
				X{1+m}.signal{1+j1}(:);
			end
		end
		meta{m+1} = X{m+1}.meta;
	end

	if strcmp(fmt,'table')
		out = out{1};
		meta = meta{1};
	end
end
