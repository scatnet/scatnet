function x2 = remove_margin(x, n)
    [N,M,P] = size(x);
    x2 = x(1+n:N-n,1+n:M-n,1:P);
end