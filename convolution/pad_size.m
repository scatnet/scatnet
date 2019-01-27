% PAD_SIZE Compute the optimal size for padding
%
% Usage
%    sz_padded = PAD_SIZE(sz, min_margin, max_ds)
%
% Input
%    sz (int): The size of the original signal.
%    min_margin (int): The minimum margin for padding.
%    max_ds (int): The maximum downsampling factor.
%
% Output
%    sz_padded (int): The minimum size of the padded signal.
%
% Description
%    Calculates the smallest multiple of 2^max_ds larger than sz by at least
%    2*min_margin. This ensures that there is enough margin on both sides of
%    the signal to avoid border effects, assuming that min_margin is equal to
%    at least half of the size of the largest filter used, while ensuring that
%    downsampling by powers of 2 up to 2^max_ds are possible through
%    periodization of the Fourier transform. sz_added is also forced to be at
%    least one.
%
% See Also
%    PAD_SIGNAL, UNPAD_SIGNAL

function sz_padded = pad_size(sz, min_margin, max_ds)
    sz_padded = 2^max_ds * ceil( (sz + 2*min_margin)/2^max_ds );
    sz_padded = max(1, sz_padded);
end
