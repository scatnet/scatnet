function varargout = func_output(func,output_ind,varargin)
	varargout = cell(max(output_ind),1);
	[varargout{:}] = func(varargin{:});
	varargout = varargout(output_ind);
end


