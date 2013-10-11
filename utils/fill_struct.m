% FILL_STRUCT Sets default values of a structure
%
% Usage
%    s = FILL_STRUCT(s, field, value, ...)
%
% Input
%    s (struct): Structure whose fields are to be set.
%    field (char): The name of the field to set.
%    value: The default value of the field.
%
% Output
%    s (struct): The structure with the default values set.
%
% Description
%    If the s.field is empty or not set, it is set to the default value 
%    specified. If desired, multiple field/value pairs can be specified in the
%    same function call.

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