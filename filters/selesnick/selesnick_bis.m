function outf= selesnick_bis(sizein, options)

J=getoptions(options,'J',10);

% get filters
[Faf, Fsf] = FSfarras;
[af, sf] = dualfilt1;


sizebis=sizein;
sizebis(1)=2^(floor(log2(sizein(1))));

padn=(sizein(1)-sizebis(1))/2;

x = zeros(sizebis);  % zero signal
% Compute dual-tree complex DWT of zero signal
w = dualtree(x, J, Faf, af); 

for j=1:J+1

L=length(w{j}{1});
% Set a single (real) coefficient to 1
w{j}{1}(round(L/2)) = 1;
% Compute the inverse transform 
y1 = idualtree(w, J, Fsf, sf);
w{j}{1}(round(L/2)) = 0;

% Set a single (imaginary) coefficient to 1
w{j}{2}(round(L/2)) = 1;
% Compute the inverse transform 
y2 = idualtree(w, J, Fsf, sf);
w{j}{2}(round(L/2)) = 0;

aux = padarray(y1 + 1i*y2,padn);
aux = 2^(-j/2)* fftshift(aux);
if j <= J
    outf.psi{1}{j}{1} = fft(aux);
else
    outf.phi = fft(aux);
end

end


