% CHECK_OPTIONS_WHITE_LIST Check that all fields of a struct are valid
% 
% Usage
%   CHECK_OPTIONS_WHITE_LIST(options, white_list)
%
% Input
%   options (struct): a structure with optional fields
%   white_list (cell of string): containing the valid fields
% 
% Ouput
%   none   
%
% Description
%   Will crash with an error if the input options contains invalid fields
%
% See also :
%   FILL_STRUCT
%   CHECK_OPTIONS_WHITE_LIST

function [] = check_options_white_list(options, white_list)
    fn = fieldnames(options);
    invalid_fields = setdiff(fn, white_list);
    if (numel(invalid_fields) > 0)
        res = cellfun(@(x) [x ', '], invalid_fields, 'UniformOutput', false);
        res = cell2mat(res');
        res(end-1:end) = [];
        error('invalid fields : %s', res);
    end
end