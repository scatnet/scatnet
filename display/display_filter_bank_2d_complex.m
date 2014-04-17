% DISPLAY_FILTER_BANK_2D_COMPLEX Return a color image that
%     contains all the filters displaid in color. The hue corresponds
%     to complex phase while the saturation corresponds to complex
%     modulus.
%
% Usage
%	big_img = DISPLAY_FILTER_BANK_2D_COMPLEX(filters, ncrop, margin)
%
% Input
%    filters (cell of struct): 2d filter bank (from 
%       morlet_filter_bank_2d.m,
%       morlet_filter_bank_2d_pyramid.m,
%       or obtained from wavelet_factory_[2d, 2d_pyramid, 3d, 3d_pyramid].m
%    ncrop (numeric): cropping size, for 'fourier_multires' filters.
%    margin (numeric): number of grey pixels between the filters.
%
% Output
%    big_img (numeric): displayed filter bank.
%
% Description
%    Return the complex values of a filter bank in color and returns it.
%
% See also
%    DISPLAY_FILTER_BANK_2D, IMAGE_COMPLEX_CELL

function big_img = display_filter_bank_2d_complex(filters, ncrop, margin)
    % Compute a cell of spatial representation of filters.
    if isfield(filters, 'psi')
        % Fourier filters.
        for k = 1:numel(filters.psi.filter)
            filters_cell{k} = display_filter_2d(...
                filters.psi.filter{k}, 'r', ncrop);
        end
    else
        % Pyramid filters.
        for k = 1:numel(filters.g.filter)
            filters_cell{k} = display_filter_2d(...
                filters.g.filter{k}, 'r', ncrop);
        end
    end
    % Compute an image from the cell.
    ncols = filters.meta.L;
    big_img = image_complex_cell(filters_cell, ncols, margin);
end


