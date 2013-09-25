% remove_margin
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