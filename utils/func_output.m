% FUNC_OUTPUT Extracts multiple outputs of a function
%
% Usage
%    out = FUNC_OUTPUT(func, output_ind, ...)
%
% Input
%    func (function handle): The function whose outputs are to be extracted.
%    output_ind (int): The indices of the outputs.
%
% Output
%    out: The desired output of func specified by output_ind.
%
% Description
%    The function func is called, with the third and later arguments given to
%    it as arguments. If output_ind is a scalar, the output it refers to is
%    output by FUNC_OUTPUT. If multiple output indices are given in output_ind,
%    the corresponding outputs are returned as a cell array.

function out = func_output(func,output_ind,varargin)
	out = cell(1,max(output_ind));
	[out{:}] = func(varargin{:});
	if numel(output_ind) == 1
		out = out{output_ind};
	else
		out = out(output_ind);
	end
end


