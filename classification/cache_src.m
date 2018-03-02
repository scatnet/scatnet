% CACHE_SRC Cache files in source
%
% Usage
%    CACHE_SRC(src);
%
% Input
%    src: A source object whose files are to be loaded into the cache.
%
% Description
%    This function used the CACHE_FILE function to load the data files in the
%    src object into the cache. As a result, accessing files from this source
%    later using DATA_READ done without reading from disk.
%
% See also
%    CACHE_FILE

function cache_src(src)
    ind = unique([src.objects.ind]);

    files = src.files(ind);

    for k = 1:numel(files)
        cache_file(files{k});
    end
end
