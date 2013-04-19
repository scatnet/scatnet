function [U_phi, U_psi] = wavelet_layer_2d(U, filters, options)

calculate_psi = (nargout>=2); % do not compute any convolution
% with psi if the user does get U_psi

if ~isfield(U.meta,'theta')
  U.meta.theta = zeros(size(U.meta.j,1),0);
end

p2 = 1;
for p = 1:numel(U.signal)
  x = U.signal{p};
  if (numel(U.meta.j)>0)
    j = U.meta.j(p,end);
  else
    j = -1E20;
  end
  
  % compute mask for progressive paths
  options.psi_mask = calculate_psi & ...
    (filters.psi.meta.j' > j + filters.meta.v);
  
  % compute waelet transform
  [x_phi, x_psi] = wavelet_2d(x, filters, options);
  
  % copy signal and meta for phi
  U_phi.signal{p} = x_phi;
  U_phi.meta.j(p,:) = [U.meta.j(p,:), filters.phi.meta.J];
  U_phi.meta.theta(p,:) = U.meta.theta(p,:);
  
  % copy signal and meta for psi
  for p_psi = find(options.psi_mask)
    U_psi.signal{p2} = x_psi{p_psi};
    U_psi.meta.j(p2,:) = [U.meta.j(p,:),...
      filters.psi.meta.j(p_psi)];
    U_psi.meta.theta(p2,:) = [U.meta.theta(p,:),...
      filters.psi.meta.theta(p_psi)];
    p2 = p2 +1;
  end
  
end


