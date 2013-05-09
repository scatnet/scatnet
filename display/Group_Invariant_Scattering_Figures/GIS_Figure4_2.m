% Reproduction of the Figure 4.2 of in the paper:
% "Group Invariant Scattering", S. Mallat, 
% Comm. in Pure and Applied Mathematics, Dec. 2012, Wiley
% Calculation the scattering transform of a Gaussain white noise and of
% a Bernouilli process.


N = 8*1024; %signal size, power of two
Jmax = log2(N); %Maximum number of scales

%Choice of the wavelet
fparam.filter_type = {'spline_1d'};
fparam.spline_order=3;
% Scale 2^J selected to display the scattering representation
fparam.J = Jmax-1;
fparam.Q = 1;

%options
options = struct();
%cascade

cascade = cascade_factory_1d(N, fparam,options, fparam.J);

%Random Bernouilli signal with probability of occurrence of p
p = 0.01;
P = floor(p*N);
f1 = zeros(1,N);
posit = ceil(N.*rand(P,1)); % positions of the 1 with probability p
f1(posit) = 1;
f1 = f1 - mean(f1);
f1 = f1 /sqrt(var(f1));
f1=f1';
Scat1 = diracNormScatt(f1,cascade);
P = length(Scat1);
y = zeros(1,P);
y(1:P) = (1:P);
% y = 3.14 * y /(P);
y = y /(P);


P = N;
z = zeros(1,P);
z(1:P) = (1:P);
z = 1000 * z/(P);

figure(1);
hold off;
subplot(2,2,2), plotSpectScatt(y,Scat1); %Scattered representation at the scale 2^J
subplot(2,2,1), plot(z,f1); %Plot the scattering power spectrum
hold off;


%Gaussian white noise
f2 = randn(1,N);
f2=f2';
%f2 = f2 - mean(f2);
%f2 = sqrt(N) * f2 /sqrt(sum(f2.^2));
%Scat2 = NormScatter(f2,wavelet_name,Jmax);
Scat2 = diracNormScatt(f2,cascade);
hold off;
subplot(2,2,4),plotSpectScatt(y,Scat2); 
subplot(2,2,3), plot(z,f2); %Scattered representation at the scale 2^J
hold on;
hold off;

fprintf('Upper left: Realization of a Bernoulli process X1(x).\n Lower left: Realization of a Gaussian white noise X1(x).\n Upper and lower right: Scattering power spectrum PX(q(omega))\n where the path p is parameterized by the frequency omega.\n The values of PX(q) are displayed in red, green, blue, and violet\n for paths of lengths 1,2, 3, and 4, respectively.\n');





