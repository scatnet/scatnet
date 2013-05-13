N = 2^20;
%N = 16;

% define filter
f = exp(-([0:2*N-1].'-N/2).^2/(2*(N/16)^2));

% define signal x and symmetrized version xt(ilde)
x = randn(N,1);
xt = [x; x(end:-1:1)];

% precalculate indices & complex exponentials
[~,ind,w] = fast_dct(randn(N,1));
ang1 = exp(2*pi*1i/(4*N)*[0:2*N-1]');
ang2 = exp(2*pi*1i/(2*N)*([0:N-1].'+1/2));

tic;
xc = fast_dct(x,ind,w);

% WSWA
% reweight & symmetrize to get spectrum of xtilde
xcs = [xc; 0; -xc(end:-1:2)].*[sqrt(2); 1*ones(2*N-1,1)]*sqrt(2*N);

% no need to have phase right now, can multiply it in later
%xcs = xcs.*ang1;

% filter symmetrized spectrum & extract even/odd indices
ytf = xcs.*f;
zf = ytf(1:2:end)+1i*ytf(2:2:end);

% bypass symmetrization. faster? not really
%zf = zeros(N,1);
%zf(1:N/2) = xc(1:2:N-1).*f(1:2:N-1)+1i*xc(2:2:N).*f(2:2:N);
%zf(N/2+1) = -1i*xc(N).*f(N+2);
%xf(N/2+2:N) = -xc(N-1:-2:3).*f(N+3:2:2*N-1)-1i*xc(N-2:-2:2).*f(N+4:2:2*N);
%zf(1) = (zf(1)-real(zf(1)))+real(zf(1))*sqrt(2);
%zf = zf*sqrt(2*N);

% now we multiply in the phase for both "real" and "imaginary" parts
zf = zf.*ang1(1:2:end);
z = ifft(zf);
% extract symmetric/antisymmetric parts and calculate IFFT for even-numbered
% and odd-numbered parts of zf
zs = 0.5*(z+z(end:-1:1));
za = 0.5*(z-z(end:-1:1));
if 0
	y1 = (real(zs)+1i*imag(za));
	y2 = (imag(zs)-1i*real(za));
	y2 = ang2.*y2;
	y = 0.5*(y1+y2);
else
	% faster if we do it one sweep:
	y = 0.5*((real(zs)+1i*imag(za)+ang2.*(imag(zs)-1i*real(za))));
end
toc;

tic;
xtf = fft(xt);
yt2f = xtf.*f;
yt2 = ifft(yt2f);
toc;

norm(xtf-xcs.*ang1)
norm(y-yt2(1:end/2))
