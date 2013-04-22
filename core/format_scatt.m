%TODO redo doc
%FORMAT_SCATT Formats a scattering representation
%   [out,meta] = format_scatt(X,fmt) formats the scattering output X (from
%   the function scatt, or scatt_time with output set to 'raw') according
%   to the format specified in fmt. The following formats are allowed:
%
%      'raw' - No formatting is done and the original object is returned
%      'table' - The scattering coefficients are arranged into a 2D table,
%         with the scattering coefficient index running along the first
%         dimension and time running along the second dimension. This is only
%         possible if the scattering coefficients of different orders are of
%         the same resolution, which is the case when the lowpass filters phi
%         of the filter banks coincide. The signals are ordered by increasing
%         order, increasing first scale, increasing second scale, etc. Their
%         meta-information (order, scale, etc) are stored in the accompanying
%         meta structure. These correspond to the meta structures of X,
%         concatenated, and complemented by -1 when no value is available.
%         In addition, an order field is provided to give the order of the
%         coefficient. For example, if we have ascattering transform of order 
%         2, and the coefficient at index k is the first-order coefficient 
%         with scale j1, it would have meta.order(k) equal to 1 and
%         meta.scale(k,:) equal to [j1 -1]. Likewise if the kth coefficient is
%         a second-order coefficient corresponding to scales j1 and j2, it 
%         would have meta.order(k) equal to 2, and meta.scale(k,:) equal to
%         [j1 j2].

function [out,meta] = format_scatt(X,fmt)
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
			
			X = flatten_scatt(X);
		end
		
		last = 0;
		for m = 0:length(X)-1
			if length(X{m+1}.signal) == 0
				tables{m+1} = [];
			else
				tables{m+1} = zeros( ...
					[size(X{m+1}.signal{1},1), ...
					size(X{m+1}.signal{1},2), ...
					length(X{m+1}.signal)], ...
					class(X{m+1}.signal{1}));
				
				for j1 = 0:length(X{m+1}.signal)-1
					tables{m+1}(:,:,j1+1) = X{m+1}.signal{j1+1};
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
