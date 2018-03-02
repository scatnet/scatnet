% CACHE_FILE Cache a file
%
% Usage
%    CACHE_FILE(filename);
%
% Input
%    filename: A the name of a file passed to DATA_READ and subsequently
%       loaded in to the cache.
%
% Description
%    This function loads a data file into the cache. Further calls to
%    DATA_READ with the same filename will then return the cached data from
%    memory.
%
% See also
%    DATA_READ

function cache_file(filename)
    cache_util(1, filename);
end
