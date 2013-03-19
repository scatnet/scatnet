function out = lowpass_3d_layer(previous_layer, filters, downsampler,options)
if (isfield(previous_layer.meta,'theta1_downsampled'))
  previous_layer_order = 2;
  rotation_spatial_separable = getoptions(options,'rotation_spatial_separable',0);
else
  previous_layer_order = 1;
end
preserve_l2_norm = getoptions(options,'preserve_l2_norm',1);
no_final_spatial_lowpass = getoptions(options,'no_final_spatial_lowpass',0);

J = numel(filters.psi{1});

% compute orbits
p2 = 1;
not_yet_in_an_orbit = ones(numel(previous_layer.sig),1);
for p = 1:numel(previous_layer.sig)
  if (not_yet_in_an_orbit(p))
    
    % find the orbit :
    j = previous_layer.meta.j(p,:);
    res = previous_layer.meta.res(p,:);
    lastres = res(end);
    switch previous_layer_order
      case 1
        orbit =  find(previous_layer.meta.j(:,1) == j(1)) ;
        not_yet_in_an_orbit(orbit) = 0;
      case 2
        j_rot = previous_layer.meta.j_rot(p,:);
        if rotation_spatial_separable
          orbit =  find(previous_layer.meta.j(:,1) == j(1) & ...
            previous_layer.meta.j(:,2) == j(2) & ...
            previous_layer.meta.j_rot(:,1) == j_rot(1) );
          not_yet_in_an_orbit(orbit) = 0;
        else
          theta2 = previous_layer.meta.theta2(p,1) ;
          orbit =  find(previous_layer.meta.j(:,1) == j(1) & ...
            previous_layer.meta.j(:,2) == j(2) & ...
            previous_layer.meta.j_rot(:,1) == j_rot(1) & ...
            previous_layer.meta.theta2(:,1) == theta2);
          not_yet_in_an_orbit(orbit) = 0;
        end
    end
    
    % average over the orbits :
    tmp = zeros(size(previous_layer.sig{p}));
    for p_orbit = orbit'
      tmp = tmp + previous_layer.sig{p_orbit};
    end
    
    if (~no_final_spatial_lowpass)
      % spatial lowpass filtering :
      tmp = ifft2( fft2(tmp) .* filters.phi{lastres+1} ) ;
      % downsample
      ds = downsampler(J,lastres);
      tmp = downsampling_2d(tmp,ds,preserve_l2_norm);
    else
      ds = 0;
    end
    out.sig{p2} = tmp;
    
    % store meta
    out.meta.j(p2,:) = j;
    switch previous_layer_order
      case 1
      case 2
        out.meta.j_rot(p2,:) = j_rot;
        if rotation_spatial_separable
        else
          out.meta.theta2(p2,:) = theta2;
        end
    end
    out.meta.res(p2,:) = [res, lastres + ds];
    p2 = p2 + 1;
  end
end