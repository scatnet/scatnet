function [Wout,Phiout,Phioutbis]=dualwavelets(W,Phi,LP)
	%for jr=1:Jres
	%filters.psi=W;
	%filters.phi=Phi;
	%LP=littlewood_paley_ISCV(filters);
	J=size(W,2);
	L=size(W{end},2);
	eps=1e-12;
	tight=0;

	Wout = W;
	Phiout = Phi;

	for j=1:J
		if ~isempty(W{j})
			for l=1:L
				if tight
					% if frame is tight, LP = 1 for all omega, so we only need to conjugate
					Wout{j}{l}=conj(W{j}{l});
				else
					% if frame is not tight, we need to divide by LP so that
					% sum W_j*Wd_j = sum W_j*conj(W_j)/LP = LP/LP = 1
					% but this can be dangerous is LP becomes very small, so only
					% do this on the support of W_j
					supp=(abs(W{j}{l})>eps);
					Wout{j}{l} = supp.*(conj(W{j}{l})./(LP));
				end
			end
		end
	end
	eps = 2e-2;
	supp=(abs(Phi)>eps);
	Phiout=supp.*((Phi)./(LP));
	if tight
		Phiout=Phi;
		Phioutbis=supp.*min(8,1./Phi);
		Ic=find(supp==0);
		Phioutbis(Ic)=0;
	end
end


