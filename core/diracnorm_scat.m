function nScatt = diracnorm_scat(x,cascade)
	% Calculation of a normalized scattering representation
	% nScatt is an array of size 2N which stores a
	% piecewise constant signal giving
	% the 2^J normalized values || SJ [p]f||/||SJ[p] delta||
	% over intervals of lengths proportional to ||SJ[p] delta||^2 .
	% Normalized scattering transforms are defined in the paper
	% "Group Invariant Scattering", S. Mallat, http://arxiv.org/abs/1101.2286
	
	N=size(x,1); % N must be an integer multiplied by a very high power of 2
	%Compute the scattering transform of the signal x and output it in a table
	Sx=scat(x,cascade);
	
	%Prepare the dirac signal
	dirac = zeros(N,1);
	dirac(N/2) = 1;
	%Compute its scattering transform and output it in the form of a table
	tic
	Sdirac=scat(dirac, cascade);
	%%
	fprintf('scat time\n');
	toc
	[Scatt order2]=reorder_scat(Sx);
	tic
	%%
	nSdirac=reorder_scat(Sdirac);
	
	%%
	fprintf('reordering time\n');
	
	toc
	lsig=2*N/2^(length(Sx{2}.signal));
	
	
	for k=0:lsig:2*N-lsig
		
		normd=norm(nSdirac(k+1:k+lsig));
		normx=norm(Scatt(k+1:k+lsig))/normd;
		
		% the order is coded in the smallest digits of normx
		normx = 10^(-6) * floor(normx * 10^(6));
		Scatt(k+1:k+lsig) = normx + order2(k+1)* 10^(-7);
		
		nSdirac(k+1:k+lsig)=normd^2;
		
	end
	
	C=sum(nSdirac)/lsig;
	
	p=0;
	for k=1:lsig:2*N
		step=nSdirac(k) * 2 * N/C;
		
		nScatt(floor(p+1):round(p+step))=Scatt(k);
		p=p+step;
	end
	
	
	
end


