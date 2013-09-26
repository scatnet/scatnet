% remove_margin : remove margins along specified dimensions
% 
% Input 
%   - x (numeric) : the array (up to 3d) for which to remove the margin
%   - margins (margins) : the margins 
%
% Output
%   - x2 (numeric) : the array with removed margin
%
% Usage
%   x2 = remove_margin(x, [0,0,1,1,1,1]) 
%       will remove 1 elements at begining and end of array along
%       dimension 2 and 3.

function x2 = remove_margin(x, margins)
    [N,M,P] = size(x);
    x2 = x;
    
    x2 = x2(1+margins(1):N-margins(2),:,:);
    x2 = x2(:,1+margins(3):M-margins(4),:);
    x2 = x2(:,:,1+margins(5):P-margins(6));
    
end
