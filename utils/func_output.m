function out = func_output(func,output_ind,varargin)
	out = cell(1,max(output_ind));
	[out{:}] = func(varargin{:});
	if numel(output_ind) == 1
		out = out{output_ind};
	else
		out = out(output_ind);
	end
end


