% SUB_OPTIONS Copy optional fields among a specified valid list
%
% Usage 
%   options2 = SUB_OPTIONS(options, field_list)
%
% Input
%   options (struct): an input struct of field 
%   field_list (cell of string): the list of optional fields to copy
%
% Outpout
%   options2 (struct): containing a copy of all field of options that also
%       belong to valid_list
%
% See also
%   CHECK_OPTIONS_WHITE_LIST
%   FILL_STRUCT
function options2 = sub_options(options, field_list)
    field_to_copy = intersect(fieldnames(options), field_list);
    options2 = struct();
    for ifield = 1:numel(field_to_copy)
        field = field_to_copy{ifield};
        options2.(field) = options.(field);
    end
end