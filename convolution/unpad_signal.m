% UNPAD_SIGNAL Remove de padding from PAD_SIGNAL
%
% Usage
%    x = UNPAD_SIGNAL(y, resolution, target_sz, center)
%
% Input
%    y (numeric): The signal to be unpadded.
%    resolution (int): The resolution of the signal (as a power of 2), with
%        respect to the original, unpadded version.
%    target_sz (numeric): The size of the original, unpadded version. Combined
%        with resolution, the size of the output y is given by
%        target_sz.*2.*(-resolution).
%    center (boolean, optional): If true, extracts the center part of y, oth-
%        erwise extracts the (upper) left corner (default false).
%
% Output
%    x (numeric): The extracted unpadded signal
%
% Description
%    To handle boundary conditions, a signal is often padded using PAD_SIGNAL
%    before being convolved with CONV_SUB_1D or CONV_SUB_2D. After this, the
%    padding needs to be removed to recover a regular signal. This is achieved
%    using UNPAD_SIGNAL, which takes the padded, convolved signal y as input,
%    as well as its resolution relative to the original, unpadded version,
%    and the size of this original version. Using this, it extracts the
%    coefficients in y that correspond to the domain of the original signal.
%    If the center flag was specified during PAD_SIGNAL, it is specified here
%    again in order to extract the correct part.
%
% See Also
%    PAD_SIGNAL
function x = unpad_signal(x, res, target_sz, center)
    if nargin < 4
        center = 0;
    end
    
    padded_sz = size(x);
    
    padded_sz = padded_sz(1:length(target_sz));
    
    offset = 0.*target_sz;
    
    if center
        offset = (padded_sz.*2.^res-target_sz)/2;
    end
    
    offset_ds = floor(offset./2.^res);
    target_sz_ds = 1+floor((target_sz-1)./2.^res);
    
    switch length(target_sz)
        case 1
            x = x(offset_ds + (1:target_sz_ds),:,:);
        case 2
            x = x(offset_ds(1) + (1:target_sz_ds(1)), ...
                offset_ds(2) + (1:target_sz_ds(2)), :);
    end
end
