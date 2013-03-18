function out = wavelet_modulus_2d_layer(previous_layer, filters, downsampler, next_bands, options)
options.null = 1;
preserve_l2_norm = getoptions(options,'preserve_l2_norm',1);
L = numel(filters.psi{1}{1});
nextp = 1;
for p = 1:numel(previous_layer.sig)
  % retrieve current signal and meta data
  x     = previous_layer.sig{p};
  res   = previous_layer.meta.res(p, :);
  j     = previous_layer.meta.j(p, :);
  theta = previous_layer.meta.theta(p, :);
  lastj    = j(end);
  lastres  = res(end);
  
  nb = next_bands(lastj);
  if (numel(next_bands)>0) % otherwise no need to compute the fft of x
    xf = fft2(x);
    for nextj = nb;
      for nexttheta = 1:L
        % wavelet modulus
        ux = abs(ifft2( xf .* filters.psi{lastres+1}{nextj+1}{nexttheta} ) );
        % downsampling
        ds = downsampler(nextj,lastres);
        out.sig{nextp} = downsampling_2d(ux, ds, preserve_l2_norm);
        % store meta
        out.meta.j(nextp, :) = [j, nextj];
        out.meta.theta(nextp, :) = [theta, nexttheta];
        out.meta.res(nextp, :) = [res, lastres + ds];
        nextp = nextp + 1;
      end
    end
  end
end
if (~exist('out','var'))
  out.sig = {};
end
end
