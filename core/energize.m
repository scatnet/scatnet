function energy = energize(U)
% function energy = ernergize(U)
%
% compute the sum of the energy of all layers


energy = 0;

if (iscell(U))
  for m = 1:numel(U)
    energy = energize(U{m});
  end
end

for p = 1:numel(U.sig)
  sig = U.sig{p};
  energy = energy + sum(abs(sig(:)).^2);
end

end

