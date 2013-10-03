function x_conv_y = conv_sub_2d(xf, filter, ds)
    if isnumeric(filter)
        x_conv_y = ifft2( ...
            sum(extract_block(xf .* filter, [2^ds, 2^ds]), 3)) / 2^ds;
    elseif isstruct(filter)
        if (strcmp(filter.type,'fourier_multires'))
            res = log2(size(filter.coefft{1},1)/size(xf,1));
            x_conv_y = conv_sub_2d(xf, filter.coefft{res+1}, ds);
        elseif (strcmp(filter.type,'spatial_support'))
            x_conv_y = conv2(x_paded, filter.coefft, 'same');
            %       filt = filter.coefft;
            %		P = floor(size(filt,1)/2);
            %		x_paded = pad_mirror_2d_twosided(xf, [P, P]);
            %		x_conv_psi = conv2(x_paded, filt, 'same');
            %		x_conv_y = 2^ds * x_conv_psi(1+P:2^ds:end-P, 1+P:2^ds:end-P);
        else
            error('Unsupported filter type!');
        end
    end
end