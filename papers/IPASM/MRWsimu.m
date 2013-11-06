% Simulates a log-normal multifractal random walk
% Returns a vector X_n[tau] - X_n[0], ... , X_n[N*tau]-X_n[(N-1) tau]
% where X_n goes to a log-normal MRW with intermittency coefficient lambda^2 and integral scale T when n is large.
% The parameter n is such that n>=16 should yield a good approximation.
% Note that the algorithm uses vectors of total size 2*N*n.
%
% References :
% [1] Modelisation de series financieres a l'aide de processus invariants d'echelle (2006)
%	 Kozhemyak, A. These de doctorat.
%	 Section 3.

function [X,X0] = MRWsimu(N, noise, lambda2 , T, n,tau)
    if nargin < 2
	lambda2=0.02;
	T=N;
	n = 16;
	tau = 1;
	noise = 1;
    end 
    if nargin < 3
        T =   N;
	lambda2=0.02;
	n = 16;
	tau = 1;
    end
    if nargin < 4
        n = 16;
    end
    if nargin < 5
        tau = 1;
        n = 16;
    end
    
	if noise==1
    covar = lambda2*[log(T*n/tau)+1 log(T*n/tau)-log(1:floor(T*n/tau))];
	X = gaussprocess(covar, N*n) - lambda2*(log(T*n/tau)+1);
	X0 = exp(X);
	X = exp(X).*randn(1,N*n)*sqrt(1/n);
	X = sum(reshape(X,n,N),1) ;
	X0 = sum(reshape(X0,n,N),1) ;
	else
    	covar = lambda2*[log(T*n/tau)+1 log(T*n/tau)-log(1:floor(T*n/tau))];
	X = gaussprocess(covar, N*n) - .5*lambda2*(log(T*n/tau)+1);
	X = exp(X);
	X = sum(reshape(X,n,N),1) ;
	end
end
