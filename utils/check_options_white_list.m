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