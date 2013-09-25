% remove_margin : remove margins along specified dimensions
% 
% Input 
%   - x (numeric) : the array (up to 3d) for which to remove the margin
%   - n (positive integer) : the size of margin to remove
%   - dims (array) : the dimensions on which to remove the margins
%
% Output
%   - x2 (numeric) : the array with removed margin
%
% Usage
%   x2 = remove_margin(x, 1, [2,3]) 
%       will remove 1 elements at begining and end of array along dimension
%       and 3.

function x2 = remove_margin(x, n, dims)
    [N,M,P] = size(x);
    x2 = x;
    if (any(dims == 1))
        x2 = x2(1+n:N-n,:,:);
    end
    if (any(dims == 2))
        x2 = x2(:,1+n:M-n,:);
    end
    if (any(dims == 3))
        x2 = x2(:,:,1+n:P-n);
    end
end