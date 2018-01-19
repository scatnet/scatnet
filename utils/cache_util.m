% CACHE_UTIL Simple cache utility
%
% Usage
%
%    out = CACHE_UTIL(action, file);
%
% Input
%    action: An action code. One of the following:
%          - 0: List cached files. The output consists of a cell array with
%             all the cached filenames.
%          - 1: Read file into cache. In this case, the second argument will
%             passed to DATA_READ and the output loaded into the cache.
%             Returns the empty array.
%          - 2: Get file from cache. If the second argument matches any of the
%             file names in the cache, the relevant file will be returned. If
%             the file name is not found, an empty array is returned instead.
%          - 3: Clears cache. Returns the empty array.
%
% Output
%    out: Depends on the action code. See above.
%
% See also
%    DATA_READ

function out = cache_util(action, varargin)
    persistent p_files p_data;

    if isempty(p_files)
        p_files = {};
    end

    if isempty(p_data)
        p_data = {};
    end

    if action == 0
        out = p_files;
    elseif action == 1 && numel(varargin) == 1
        if ~any(strcmp(varargin{1}, p_files))
            data = data_read(varargin{1}, 'nocache');

            p_files{end+1} = varargin{1};
            p_data{end+1} = data;
        end
        out = [];
    elseif action == 2 && numel(varargin) == 1
        ind = find(strcmp(varargin{1}, p_files), 1);
        if isempty(ind)
            out = [];
        else
            out = p_data{ind};
        end
    elseif action == 3
        p_files = {};
        p_data = {};
    else
        error('Invalid action code.');
    end
end
