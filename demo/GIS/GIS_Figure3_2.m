% Reproduction of the Figure 3.2 of in the paper:
% "Group Invariant Scattering", S. Mallat, 
% Comm. in Pure and Applied Mathematics, Dec. 2012, Wiley
%
% Fourier transforms and scattering transforms of 4 different signals.


N = 8*1024; %signal size, power of two
Jmax = log2(N); %Maximum number of scales

%Choice of the wavelet
fparam.filter_type = {'spline_1d'};
fparam.spline_order=3;

% Scale 2^J selected to display the scattering representation
fparam.J = Jmax-1;
fparam.Q = 1;
options = struct();
cascade = wavelet_factory_1d(N, fparam,options, fparam.J);


% Examples of signals

%Indicator function of an interval
f1 = zeros(1,N);
R = 20;
  f1(N/2-R:N/2+R) = 1;
f1 = f1 ./sum(abs(f1));
f1=f1';
% Scattering transform
% tic
 Scat1 = diracNormScatt(f1,cascade);
% toc
P = length(Scat1);
y = zeros(1,P);
y(1:P) = (1:P);
y = 10 * y* 2 * pi/(P);

P = 8*R+1;
w = zeros(1,R);
w(1:P) = (1:P);
w = (w-1)*8/(P)-4;

figure(1);
hold off;
subplot(4,3,1), plot(w,f1(N/2-4*R:N/2+4*R)); 
%subplot(4,3,3), plotnormScatt(y,Scat1, Sdirac1, order1); %Scattered representation at the scale 2^J
subplot(4,3,3), plot(y,Scat1); %Scattered representation at the scale 2^J

% Modulus of the Fourier transform
A1 = abs(fft(f1));
P = N/2;
z = zeros(1,P);
z(1:P) = (1:P);
z =10 *  z* 2 * pi/(P);

subplot(4,3,2), plot(z,A1(1:N/2));
%plot(Scat1(:,J-1),'g'); 
hold off;
 

P = 16*R+1;
w = zeros(1,P);
w(1:P) = (1:P);
%w = w* 50(P);
w = (w-1)*8/(P)-4;

%First Gabor function
f1 = zeros(1,N);
R = 20;
  f1(1:N) = exp(-((1:N)-N/2).^2/(2 * (1024/32).^2)) .* cos(pi * (1:N)*0.90/3);
f1 = f1 ./sum(abs(f1));
f1=f1';
Scat1 = diracNormScatt(f1,cascade);
P = length(Scat1);
y = zeros(1,P);
y(1:P) = (1:P);
y = 10 * y* 2 * pi/(P);

hold off;
subplot(4,3,4), plot(w,f1(N/2-8*R:N/2+8*R)); 
subplot(4,3,6), plot(y,Scat1); %Scattered representation at the scale 2^J
A1 = abs(fft(f1));
P = N/2;
z = zeros(1,P);
z(1:P) = (1:P);
z = 10 * z* 2 * pi/(P);

subplot(4,3,5), plot(z,A1(1:N/2));
%plot(Scat1(:,J-1),'g'); 
hold off;


%Dilated Gabor Function
f2 = zeros(1,N);
R = 20;
  f2(1:N) = exp(-(1.1).^2*((1:N)-N/2).^2/(2 * (1024/32).^2)) .* cos(pi * (1:N)*1.1*0.9/3);
f2 = f2 ./sum(abs(f2));
f2=f2';
subplot(4,3,7), plot(w,f2(N/2-8*R:N/2+8*R)); 
Scat2 = diracNormScatt(f2,cascade);
%Scat2 = NormScatter(f2,wavelet_name,Jmax,'White');
%Scat = Scatter(f2,wavelet_name,Jmax,'White');
%figure(2);
hold off;
subplot(4,3,9),plot(y,Scat2); %Scattered representation at the scale 2^J
A2 = abs(fft(f2));
P = N/2;
z(1:P) = (1:P);
z = 10 * z* 2 * pi/(P);

subplot(4,3,8), plot(z,A2(1:N/2));
hold on;
%plot(Scat2(:,J-1),'g'); 
hold off;

%sum of a Gabor function and of a dilated Gabor function
f4 = zeros(1,N);
R = 20;
  f4(1:N) = exp(-((1:N)-N/2).^2/(2 * (1024/16).^2)) .* cos(pi * (1:N)*0.95/3) + exp(-((1:N)-N/2).^2/(2 * (1024/16).^2)) .* cos(pi * (1:N)*1/3*1.05) ;
f4 = f4 ./sum(abs(f4));

f4=f4';
Scat4 = diracNormScatt(f4,cascade);
P = length(Scat4);
y = zeros(1,P);
y(1:P) = (1:P);
y = 10 * y* 2 * pi/(P);

hold off;
subplot(4,3,10), plot(w,f4(N/2-8*R:N/2+8*R)); 
subplot(4,3,12), plot(y,Scat4); %Scattered representation at the scale 2^J
A4 = abs(fft(f4));
P = N/2;
z = zeros(1,P);
z(1:P) = (1:P);
z = 10 * z* 2 * pi/(P);

subplot(4,3,11), plot(z,A4(1:N/2));
%plot(Scat4(:,J-1),'g'); 
hold off;

fprintf('Left graphs: each row gives an example of function fi(x). \n Middle graphs: modulus of the Fourier transform of each fi \n as a function of the freRuency omega.\n Right graphs: normalized scattering transforms Sfi(R(omega))\n as a function of the freRuency omega.\n');









