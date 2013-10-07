function x_conv_y = conv_sub_2d(xf, filter, ds, offset)
    if (nargin <4)
       offset = [0,0]; 
    end
    if isnumeric(filter)
        x_conv_y = ifft2( ...
            sum(extract_block(xf .* filter, [2^ds, 2^ds]), 3)) / 2^ds;
    elseif isstruct(filter)
        if (strcmp(filter.type,'fourier_multires'))
            res = log2(size(filter.coefft{1},1)/size(xf,1));
            x_conv_y = conv_sub_2d(xf, filter.coefft{res+1}, ds);
        elseif (strcmp(filter.type,'spatial_support'))
            x_conv_y = conv2(xf, filter.coefft, 'same');
            x_conv_y = 2^ds * x_conv_y(1+offset(1):2^ds:end, 1+offset(2):2^ds:end);
        else
            error('Unsupported filter type!');
        end
    end
end