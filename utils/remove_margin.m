% REMOVE_MARGIN Remove margins along specified dimensions
%
% Usage
%    y = REMOVE_MARGIN(x, margins)
% 
% Input 
%    x (numeric): The array (up to 3D) for which to remove the margin.
%    margins (int): The margins.
%
% Output
%    y (numeric): The array with removed margin.
%
% Example
%    y = remove_margin(x, [0,0,1,1,1,1]) 
%
%    This will remove 1 element at begining and end of array along dimensions 2
%    and 3.

function x2 = remove_margin(x, margins)
    [N,M,P] = size(x);
    x2 = x;

    x2 = x2(1+margins(1):N-margins(2),:,:);
    x2 = x2(:,1+margins(3):M-margins(4),:);
    x2 = x2(:,:,1+margins(5):P-margins(6));
end
