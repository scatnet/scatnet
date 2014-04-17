function x_border = add_grey_border(x, margin)
    switch numel(size(x))
        case 2
            sz = size(x);
            x_border  = ones(sz + 2 * margin) * (223.0/255.0);
            x_border(...
                margin + (1:sz(1)), ...
                margin + (1:sz(2)) ) = x;
        case 3
            sz = size(x);
            sz_margin = size(x);
            sz_margin(1:2) = sz_margin(1:2) + 2 * margin;
            x_border  = ones(sz_margin) * (223.0/255.0);
            x_border(...
                margin + (1:sz(1)), ...
                margin + (1:sz(2)), ...
                1:sz(3)) = x;
        otherwise
            error('Input is not a 2d or 3d matrix');
    end
end