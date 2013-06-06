% Reproduction of the Figure 3.1 of in the paper:
% "Group Invariant Scattering", S. Mallat, 
% Comm. in Pure and Applied Mathematics, Dec. 2012, Wiley



N = 8*1024; %signal size, power of two
%Jmax = log2(N); %Maximum number of scales
%x = zeros(1,N);
x(1:N) = exp(-((1:N)-N/2).^2/(2 .* (1024/128).^2)) .* (4 .* ((1:N)-N/2).^2/(2 .* (1024/128).^2).^2 - 2 /(2 .* (1024/128).^2));
x = x ./sum(abs(x));
x=x';


fparam1.J = 6;
fparam1.filter_type = {'spline_1d'};
fparam1.spline_order=3;
fparam1.Q = 1;

fparam2.J = 7;
fparam2.filter_type = {'spline_1d'};
fparam2.spline_order=3;
fparam2.Q = 1;

fparam3.J = 8;
fparam3.filter_type = {'spline_1d'};
fparam3.spline_order=3;
fparam.Q = 1;

options = struct();

Wop1 = wavelet_factory_1d(N, fparam1,options,6);
Wop2 = wavelet_factory_1d(N, fparam2,options,7);
Wop3 = wavelet_factory_1d(N, fparam3,options,8);

nScatt1 = diracnorm_scat(x, Wop1);
nScatt2 = diracnorm_scat(x, Wop2);
nScatt3 = diracnorm_scat(x, Wop3);
 
 P = 2*N;
 y = zeros(1,P);
 y(1:P) = (1:P);

%  
figure(1);
hold off;
% Plot in color at 3 scales 2^J
subplot(2,2,2), plot_diracnorm_scat(y,nScatt1);
subplot(2,2,3), plot_diracnorm_scat(y,nScatt2);
subplot(2,2,4), plot_diracnorm_scat(y,nScatt3);

xf = abs(fft(x));


% Plot of the Fourier transform modulus of the signal
subplot(2,2,1), plot(y(1:N/2),xf(1:N/2));
hold off;

fprintf('Caption: Upper left: Fourier modulus of a Gaussian second derivative\n as a function of the frequency omega. \n Upper-right, lower-left, lower-right: piecewise constant graphs of the normalized scatteringd\n  transform SJ f(q(omega)) where the path q is parameterized by the frequency omega. \n The color speci?es the length of each path q: \n 0 is yellow, 1 red, 2 green, 3 blue, 4 violet. \n The frequency resolution 2J increases from upper-rigth to lower-left and lower-right.\n');

