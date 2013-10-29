function [out,l1norms,l1orig,l1eq]=equalize_first_order_scattering(f,g,psi,phi,lp)
	%this function equalizes the process g such that
	%it has the same first order scattering coefficients as f

	J=size(psi,2);
	L=size(psi{end},2);

	options.null=1;
	% calculate dual wavelets
	[dpsi,dphi]=dualwavelets(psi,phi,lp{1});


	% calculate wavelet transform of original (f) and current (g)
	[FW,FPhi]=wavelet_fwd(f,psi,phi,options);
	[GW,GPhi]=wavelet_fwd(g,psi,phi,options);

	% average wavelet modulus coefficients to get the expected scattering
	for j=1:J
		for l=1:L
			l1norms(j,l)=sum(abs(FW{j}{l}(:)));
			l1orig(j,l)=sum(abs(GW{j}{l}(:)));
		end
	end

	% l1 norm of original process, never used
	l1f=sum(abs(f(:)));

	niters=64;

	for n=1:niters
		% equalize GW
		GW = equalize(GW,l1norms,J,L);
		% reproducing kernel
		[GW,GPhi,out]=wavelet_rk(GW,GPhi,psi,phi,dpsi,dphi,options);
		n

	% how close did we end up?
	for j=1:J
		for l=1:L
			l1eq(j,l)=sum(abs(GW{j}{l}(:)));
		end
	end
		fprintf('%d  %f \n', n, norm(l1eq(:)-l1norms(:))/norm(l1norms(:)))
	end

end

function Wout=equalize(W,l1norms,J,L)
	tol=1e-10;
	for j=1:J
		for l=1:L
			% what is current expected scattering
			temp=sum(abs(W{j}{l}(:)));
			% don't equalize if too small (unstable)
			if temp>tol
				Wout{j}{l}=(l1norms(j,l)/temp)*W{j}{l};
			else
				Wout{j}{l}=W{j}{l};
			end
		end
	end
end


function [FW,FPhi]=wavelet_fwd(in,W,Phi,options)
	if sum(size(in)>1) == 2
		fourier = @fft2;
		ifourier = @ifft2;
	else
		fourier = @fft;
		ifourier = @ifft;
	end

	% calculate FFT of input
	in=fourier(in);

	J=size(W,2);
	L=size(W{end},2);

	FW = {};
	FPhi = {};

	for j=1:J
		if isempty(W{j})
			continue;
		end
		for l=1:L
			% for each scale/orientation, filter
			FW{j}{l}=ifourier(in.*W{j}{l});
		end
	end
	
	% lowpass filter
	FPhi=ifourier(in.*Phi);
end

function reconstr=wavelet_inv(FW,FPhi,Wd,Phid,options)
	options.null=0;

	J=size(Wd,2);
	L=size(Wd{1},2);
	[N,M]=size(Wd{1}{1});
	reconstr=zeros(N,M);
	Jinit=getoptions(options,'Jinit',1);		% only inverse starting from scale Jinit

	if 1
		for j=Jinit:J
			if ~isempty(FW{j})
				for l=1:L
					% for each scale/orientation, apply the dual filter to the wavelet coefficient
					reconstr=reconstr+ifft2(fft2(FW{j}{l}).*Wd{j}{l});
				end
			end
		end
	end
	
	% apply the dual filter to the lowpass coefficient
	reconstr = reconstr + ifft2(fft2(FPhi).*Phid);
	reconstr = real(reconstr);
end

function [FWout,FPhiout,reconstr]=wavelet_rk(FW,FPhi,W,Phi,Wd,Phid,options)

	reconstr=wavelet_inv(FW,FPhi,Wd,Phid,options);
	[FWout,FPhiout]=wavelet_fwd(reconstr,W,Phi,options);
end




