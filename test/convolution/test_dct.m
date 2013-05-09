phi = [8,4,1,0];
x = [1,4,3,6];

% W symetrization and add a single 0 in the middle
phi =  [phi,0,phi(end:-1:2)];
% H symetrization
x = [x, x(end:-1:1)];

% because phi is W-sym, phif is real and pair
phif = fft2(phi);
%
bar(phif)
%%
xf = fft2(x);
subplot(211);
bar(real(xf));
subplot(212);
bar(imag(xf));


%%

x  = rand(1, 1024);
x2 = x + 1i * rand(1, 1024);
tic;
for i = 1:nb_iter
	fft(x);
end
toc;
tic;
for i = 1:nb_iter
	fft(x2);
end
toc;


%% fast_dct two times faster than matlab
x = rand(1,1024);
nb_iter = 100;

[tmp,ind,W] = fast_dct(x');
xp = x';
tic;
for i = 1:nb_iter
	dct_matlab_x = dct(x);
end
toc;
tic;
for i = 1:nb_iter
	dct_fast = fast_dct(x',ind,W)';
end
toc;