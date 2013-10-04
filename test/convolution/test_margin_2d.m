%
sz = [42,31];
res = 3;
j = 2;
min_margin = 2^j*[1,1];

% the smallest multiple of 2^res that is larger than sz by at least 2*min_margin
sz_paded = 2^res*ceil((sz + 2*min_margin)/2^res)