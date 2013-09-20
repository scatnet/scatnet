function yms = fun_multiscale (fun, x, scale_fac, nb_scale)
    xms = scale_ds(x, scale_fac, nb_scale);
    for i = 1:nb_scale
       yms{i} = fun(xms{i}); 
    end
end