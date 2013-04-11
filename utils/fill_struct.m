%FILL_STRUCT Sets default values of a structure
%   s = fill_struct(s,'field1',value1,'field2',value2,....) sets the s.field1
%   to value1 if s.field1 is empty or not set, the same for field2, etc.

function s = fill_struct(varargin)
	s = varargin{1};

	for k = 1:(nargin-1)/2
		field_name = varargin{2*(k-1)+2};
		field_value = varargin{2*(k-1)+3};
		if ~isfield(s,field_name) || isempty(getfield(s,field_name))
			s = setfield(s,field_name,field_value);
		end
	end 
end