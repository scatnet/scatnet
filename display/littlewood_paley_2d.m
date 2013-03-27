function energy = littlewood_paley_2d(filters)
% function energy = littlewood_paley(filters)
%
% computes the energy of filters at every scales
% 
% input : 
% - filters : <filter structure>
%
% output : 
% - energy : <1xmax_res cell> 
%   - energy{res+1} contains the littlewood paley of all filters
%     at resolution res


energy = {};
for p = 1:numel(filters.psi.filter)
  filter_coefft = filters.psi.filter{p}.coefft;
  for res = 0:numel(filter_coefft)-1
    x = filter_coefft{res+1};
    if numel(energy)<res+1
      energy{res+1} = abs(x.^2);
    else
      energy{res+1} = energy{res+1} + abs(x.^2);
    end
  end
end

for res = 0:numel(energy)-1
  energy{res+1} = 0.5*(energy{res+1} + circshift(rot90(energy{res+1},2), [1, 1]));
end

filter_coefft = filters.phi.filter.coefft;
for res = 0:numel(filter_coefft)-1
  x = filter_coefft{res+1};
  if numel(energy)<res+1
    energy{res+1} = abs(x.^2);
  else
    energy{res+1} = energy{res+1} + abs(x.^2);
  end
  energy{res+1} = energy{res+1};
end

end
