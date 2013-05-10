% Reproduction of the Figure 4.1 of in the paper:
% "Group Invariant Scattering", S. Mallat,
% Comm. in Pure and Applied Mathematics, Dec. 2012, Wiley
% Decay of the variance of the scattering estimator as the scale 2^J increases
% for a Gaussian white noise and a Gaussian Moving Average process.

N = 1024; %signal size, power of two
Jmax = log2(N); %Maximum number of scales

%Choice of the wavelet
fparam.filter_type = {'spline_1d'};
fparam.spline_order=3;
% Scale 2^J selected to display the scattering representation
fparam.Q = 1;

%options
options = struct();
%cascade

% Examples of signals
R = 40; %Number of realizations of each process
A1 = zeros(R,2*N,Jmax+1); % Scattering transform of all realizatons
A2 = zeros(R,2*N,Jmax+1); % Scattering transform of all realizatons
C = 2 * N;
D = Jmax+1;
T = 8;

% Loop on all realizations
for k=1:R
    
    % Scattering of a moving average of a Gaussian white noise over T points
    f3 = randn(1,C*T);
    f1=zeros(1,N);
    for p=1:N
        f1(p) = sum(f3(p:p+T));
    end
    f1 = f1 - mean(f1);
    f1 = f1 /sqrt(sum(f1.^2));
    f1=f1';
    
    Scat1=multi_J_Scatter(f1,fparam,options,Jmax);
    
    Scat1=Scat1';
    A1(k,1:C,1:(D)) = Scat1(:,:);
    
    %Gaussian white noise
    f2 = randn(1,N);
    f2 = f2 - mean(f2);
    f2 = f2 /sqrt(sum(f2.^2));
    f2=f2';
    Scat2=multi_J_Scatter(f2,fparam,options,Jmax);
    Scat2=Scat2';
    
    A2(k,1:C,1:D) = Scat2(:,:);
end

% Variance of the scattering of a moving average as a function of scale
var1 = zeros(D,1);
% Variance of the Scattering of a Gaussian white noise as a function of scale
var2 = zeros(D,1);

for m=1:D
    for n=1:C
        v = var(A1(:,n,m));
        var1(m) = var1(m) + v;
        v = var(A2(:,n,m));
        var2(m) = var2(m) + v;
    end
end

hold off;
plot(log2(var1));
hold on;
plot(log2(var2));
hold off;

fprintf('Decay of log2 E(||SJ X - bar S X)||^2) where bar SX is the expected scattering, \n as a function of J for a Gaussian white noise X (bottom line)\n and a moving average Gaussian process (top line) \n along freTuency-decreasing paths.\n');









