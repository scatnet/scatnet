function energy = energize(S, U)
% function energy = energize(S, U)
%
% compute the sum of the energy of all scattering layers

energy = 0;

if (exist('U', 'var'))
  energy = energize(S) + energize(U);
else
  
  if (iscell(S))
    for m = 1:numel(S)
      energy = energy+energize(S{m});
    end
  else
    
    for p = 1:numel(S.sig)
      sig = S.sig{p};
      energy = energy + sum(abs(sig(:)).^2);
    end
    
  end
  
end
end

