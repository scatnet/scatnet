function x_pad = pad_mirror_2d_twosided(x, marg)
    %%
    if (~isnumeric(marg) || numel(marg)<2)
        error('margin for padding should be a 2x1 matrix');
    end
    [n,m] = size(x);
    if (n == 1)
        x = repmat(x, [marg(1) 1]);
        n = marg(1);
    else
        while (n <= marg(1)) % full mirror copy
            x = [x(n:-1:2,:); x; x(n-1:-1:1,:)];
            marg(1) = marg(1)-(n-1);
            n = n + 2*(n-1);
        end
        x = [x(marg(1)+1:-1:2,:); x; x(end-1:-1:end-marg(1),:)];
    end
    
    
    if (m == 1)
        x = repmat(x, [2 marg(2)]);
        m = marg(2);
    else
        while (m <= marg(2)) % full mirror copy
            x = [x(:,m:-1:2), x, x(:,m-1:-1:1)];
            marg(2) = marg(2)-(m-1);
            m = m + 2*(m-1);
        end
        x_pad = [x(:,marg(2)+1:-1:2), x, x(:,end-1:-1:end-marg(2))];
    end
    
    
end
