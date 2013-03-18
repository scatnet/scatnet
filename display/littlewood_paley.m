function energy = littlewood_paley(filters)

Rtot = size(filters.psi,2);

for res=1:Rtot
  W=filters.psi{res};
  Phi=filters.phi{res};
  
  J=size(W);
  [N,M] = size(Phi);
  
  energy{res}=zeros(N,M);
  for j=1:J(2)
    if ~isempty(W{j})
      O=size(W{j});
      for o=1:O(2)
        %energy = energy + circshift(abs(W{j}{o}),floor([N/2 M/2])).^2;
        energy{res} = energy{res} + abs(W{j}{o}).^2;
      end
    end
  end
  energy{res} = energy{res} + abs(Phi).^2;
  
  energym = rot90(energy{res},2);
  energym = circshift(energym,[1 1]);
  energy{res} = 0.5*(energy{res}+energym);
  
end


