function [out,partial] = wavelet_modulus_3d(previous_layer, filters, filters_rotation, ...
  downsampler, downsampler_rotation , ...
  next_bands, options )
% second layer 3d wavelet transform

preserve_l2_norm = getoptions(options,'preserve_l2_norm',1);


L = numel(filters.psi{1}{1});
J = numel(filters.psi{1});
J_rot = numel(filters_rotation.psi);
% spatial filtering
p2 = 1;
for p = 1:numel(previous_layer.sig)
  res = previous_layer.meta.res(p, :);
  j = previous_layer.meta.j(p, :);
  theta = previous_layer.meta.theta(p, :);
  lastj = j(end);
  lastres = res(end);
  
  xf = fft2(previous_layer.sig{p});
  
  % high pass spatial
  nb = next_bands(lastj);
  for nextj = nb
    for nexttheta = 1:L
      % spatial filtering
      wx =  ifft2( xf .* filters.psi{lastres+1}{nextj+1}{nexttheta} ) ;
      % spatial downsampling
      ds = downsampler(nextj, lastres);
      partial.sig{p2} = downsampling_2d(wx, ds, preserve_l2_norm);
      % store meta
      partial.meta.j(p2,:) = [j, nextj];
      partial.meta.theta(p2,:) = [theta, nexttheta];
      partial.meta.res(p2,:) = [res, lastres + ds];
      p2 = p2 + 1;
    end
  end
  
  % low pass spatial
  % filter
  wx = ifft2( xf .* filters.phi{lastres+1} );
  % sptatial downsampling
  ds = downsampler(J,lastres);
  % store meta
  partial.sig{p2} = downsampling_2d(wx, ds, preserve_l2_norm);
  partial.meta.j(p2,:) = [j, J];
  partial.meta.theta(p2,:) = [theta, -1];
  partial.meta.res(p2,:) = [res, lastres + ds];
  p2 = p2 + 1;
end

% compute 3d orbits
p3 = 1;
not_yet_in_an_orbit = ones(size(partial.meta.j,1),1);
for p2 = 1:numel(partial.sig)
  if (not_yet_in_an_orbit(p2))
    res = partial.meta.res(p2,:);
    j = partial.meta.j(p2,:);
    theta = partial.meta.theta(p2,:);
    
    % compute rotation orbits
    orbit = zeros([size(partial.sig{p2}),2*L]);
    if theta(2) == -1 % spatial low pass do not have varying theta2
      for theta_offset = 1:2*L
        theta1_mod0L = 1 + mod(theta(1) + theta_offset -1, L);
        p2_offset = find(partial.meta.j(:,1) == j(1) & ...
          partial.meta.j(:,2) == j(2) & ...
          partial.meta.theta(:,1) == theta1_mod0L);
        not_yet_in_an_orbit(p2_offset) = 0;
        orbit(:,:,theta_offset) = partial.sig{p2_offset};
      end
    else
      for theta_offset = 1:2*L
        theta1_mod0L = 1 + mod(theta(1) + theta_offset -1, L);
        theta2_mod02L = 1 + mod(theta(2) + theta_offset -1, 2*L);
        theta2_mod0L = 1 + mod(theta(2) + theta_offset -1, L);
        p2_offset = find(partial.meta.j(:,1) == j(1) & ...
          partial.meta.j(:,2) == j(2) & ...
          partial.meta.theta(:,1) == theta1_mod0L & ...
          partial.meta.theta(:,2) == theta2_mod0L);
        not_yet_in_an_orbit(p2_offset) = 0;
        if (theta2_mod02L <= L)
          orbit(:, :, theta_offset) = partial.sig{p2_offset};
        else % complex conjugate simulate filters with opposite direction for angle >= pi
          orbit(:, :, theta_offset) = conj(partial.sig{p2_offset});
        end
      end
    end
    
    % compute 1d fft along orbits (direction 3)
    orbitf = fft(orbit, [], 3);
    
    % high pass rotation
    % filter with rotation filters and take modulus
    for j_rot = 0:numel(filters_rotation.psi) - 1
      % format the rotation filter in a 3d matrix
      filt_rot = repmat(reshape(filters_rotation.psi{j_rot+1} ,[1,1,2*L]), ...
        [size(orbitf,1),size(orbitf,2),1]);
      ux = abs(ifft(  orbitf .* filt_rot, [], 3 ));
      % subsample
      ds = downsampler_rotation(j_rot);
      for theta1_downsampled = 1:2^ds:2*L
        % store signal
        out.sig{p3} = ux(:,:,theta1_downsampled);
        % store meta
        out.meta.j(p3,:) = j;
        out.meta.j_rot(p3,:) = j_rot;
        out.meta.theta1_downsampled(p3,:) = theta1_downsampled;
        out.meta.theta2(p3,:) = theta(2);
        out.meta.res(p3,:) = res;
        out.meta.res_rot(p3,:) = ds;
        p3 = p3 + 1;
      end
    end
    
    % low pass rotation (for high pass spatial only :
    % phi * phi_rot is a joint low pass
    % and U should only have high pass filters)
    if (theta(2) ~= -1)
      filt_rot = repmat(reshape(filters_rotation.phi ,[1,1,2*L]), ...
        [size(orbitf,1),size(orbitf,2),1]);
      ux = abs(ifft(  orbitf .* filt_rot, [], 3 ));
      % subsample
      ds = downsampler_rotation(J_rot);
      for theta1_downsampled = 1:2^ds:2*L
        % store signal
        out.sig{p3} = ux(:,:,theta1_downsampled);
        % store meta
        out.meta.j(p3,:) = j;
        out.meta.j_rot(p3,:) = J_rot;
        out.meta.theta1_downsampled(p3,:) = theta1_downsampled;
        out.meta.theta2(p3,:) = theta(2);
        out.meta.res(p3,:) = res;
        out.meta.res_rot(p3,:) = ds;
        p3 = p3 + 1;
      end
    end
  end
end