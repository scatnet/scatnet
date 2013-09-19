% renorm_sibling_3d_same_scale : renormalize scattering 3d
% Usage
%   Sx_renorm = renorm_sibling_3d_same_scale(Sx, op)
%
% Input
%   Sx (cell) : the output of scat (for 3d wavelet_modulus)
%   op (function_handle) : to apply to siblings 3d matrix (L1 or L2 norm)
%   
% Output
%   Sxrenorm (cell) : the renormalized 3d scattering
%
% Description
%   renorm_sibling_3d_same_scale will apply op to all the sibling 3d 
%   matrix and use the result as denominator for renormalization. 
%   This is a different renormalization strategy than renorm_sibling_3d.
%   Here the siblings of a node p are the nodes with the same ancestor
%   AND same final scale
%
function [Sx_renorm, sibling] = renorm_sibling_3d_same_scale(Sx, op)

for m = 1:numel(Sx)
    sibling{m} = @(p)(sibling_for_path_and_order(p, m));
    Sx_renorm{m} = renorm_sibling_layer(Sx{m}, op, sibling{m});
end

    % an auxilary function that computes
    % the sibling of path p for order m
    function sib = sibling_for_path_and_order(p, m)
       P = numel(Sx{m}.signal);
       mask = ones(1,P) == ones(1,P);
       for k = 1:m-1
          mask = mask & (Sx{m}.meta.j(k,:) == Sx{m}.meta.j(k,p));
          mask = mask & (Sx{m}.meta.q(k,:) == Sx{m}.meta.q(k,p));
       end
       sib = find(mask);
    end

end