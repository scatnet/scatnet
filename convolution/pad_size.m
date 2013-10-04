% PAD_SIZE Compute the optimal size for pading
%
% Usage
%   sz_paded = PAD_SIZE(sz, min_margin, res)
%
% Input
%   sz (int) : the size of the original signal
%   min_margin (int) : the minimum margin for pading 
%   res (int) : the downsampled resolution
%
% Output
%   sz_paded (int) : the optimal size for pading
%
% Description
%   the smallest multiple of 2^res that is
%   larger than sz by at least 2*min_margin
function sz_paded = pad_size(sz, min_margin, res)
    sz_paded = 2^res * ceil( (sz + 2*min_margin)/2^res );
end