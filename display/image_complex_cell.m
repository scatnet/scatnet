% IMAGE_COMPLEX_CELL Return a color image that
%     contains all the filters displaid in color. The hue corresponds
%     to complex phase while the saturation corresponds to complex
%     modulus.
%
% Usage
%	big_img = IMAGE_COMPLEX_CELL(filters, n)
%
% Input
%    wx (cell of complex 2d matrices): the signals to be displayed
%    ncols (numeric): the number of signals per rows
%    margin (numeric): the number of grey pixels between signals
%
% Output
%    big_img (numeric): a color image of all signals layed out on a grid.
%
% Description
%    Return the complex values of a filter bank in color and returns it.
%
% See also
%    DISPLAY_FILTER_BANK_2D_COMPLEX, IMAGE_COMPLEX_CELL


function big_img = image_complex_cell(wx, ncols, margin)
    
    % Compute sizes.
    rows = margin;
    max_cols = 0;
    cols = margin;
    for k = 0 : numel(wx)-1
        [N, M] = size(wx{k+1});
        cols = cols + M + margin;
        max_cols = max(cols, max_cols);
        if (mod(k+1, ncols) == 0)
            rows = rows + N + margin;
            cols = margin;
        end 
    end
    
    % Fill in big image.
    big_img = ones(rows, max_cols, 3) * (223.0/255.0);
    rows = margin;
    cols = margin;
    for k = 0 : numel(wx)-1
        [N, M] = size(wx{k+1});
        big_img(rows + (1:N), cols + (1:M), :) = image_complex(wx{k+1});
        if (mod(k+1, ncols) == 0)
            rows = rows + N + margin;
            cols = margin;
        else
            cols = cols + M + margin;
        end
        max_cols = max(cols, max_cols);
    end
    
end
