% UNPAD_SIGNAL unpad a signal
%
function x = unpad_signal(x, res, target_sz, offset)
	
    offset_ds = floor(offset/2^res);
    target_sz_ds = 1 + floor((target_sz-1)/2^res) - offset_ds;
    
    switch length(target_sz)
        case 1
            x = x(offset_ds + (1:target_sz_ds),:,:);
        case 2
            x = x(offset_ds(1) + (1:target_sz_ds(1)), ...
                offset_ds(2) + (1:target_sz_ds(2)), :);
    end
end
