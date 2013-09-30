function x_pad = pad_mirror_2d_twosided(x, margins)
    %%
    if (~isnumeric(margins) || numel(margins)<2)
        error('margins for pading must be a 2x1 matrix');
    end
    %%
    if (sum(margins>=0 & (mod(margins,1) == 0)) ~=2)
        error('margins for pading must contain positive integers');
    end
    %%
    [n,m] = size(x);
    if (n == 1)
        x = repmat(x, [2*margins(1)+1, 1]);
        n = margins(1);
    else
        while (n <= margins(1)) % full mirror copy
            x = [x(n:-1:2,:); x; x(n-1:-1:1,:)];
            margins(1) = margins(1)-(n-1);
            n = n + 2*(n-1);
        end
        x = [x(margins(1)+1:-1:2,:); x; x(end-1:-1:end-margins(1),:)];
    end
    
    
    if (m == 1)
        x = repmat(x, [1, 2*margins(2)+1]);
        m = margins(2);
    else
        while (m <= margins(2)) % full mirror copy
            x = [x(:,m:-1:2), x, x(:,m-1:-1:1)];
            margins(2) = margins(2)-(m-1);
            m = m + 2*(m-1);
        end
        x = [x(:,margins(2)+1:-1:2), x, x(:,end-1:-1:end-margins(2))];
    end
    
    x_pad = x;
    
end
