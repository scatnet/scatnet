%
function sz_paded = pad_size(sz, min_margin, res)
    sz_paded = 2^res*ceil((sz + 2*min_margin)/2^res);
end