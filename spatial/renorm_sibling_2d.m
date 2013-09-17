

function [Sxrenorm, sibling] = renorm_sibling_2d(Sx, op)

for m = 1:numel(Sx)
    sibling{m} = @(p)(sibling_for_path_and_order(p, m));
    Sxrenorm{m} = renorm_sibling_layer(Sx{m}, op, sibling{m});
end

    % an auxilary function that computes
    % the sibling of path p for order m
    function sib = sibling_for_path_and_order(p, m)
       P = numel(Sx{m}.signal);
       mask = ones(1,P) == ones(1,P);
       for k = 1:m-2
          mask = mask & (Sx{m}.meta.j(k,:) == Sx{m}.meta.j(k,p));
          mask = mask & (Sx{m}.meta.theta(k,:) == Sx{m}.meta.theta(k,p));
       end
       sib = find(mask);
    end

end