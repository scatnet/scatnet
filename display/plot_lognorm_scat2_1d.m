% plot_lognorm_scat2_1d: Plots the log normalized 2nd order scattering
% coefficients for 1d signals.
% Usage
%    plot_lognorm_scat2_1d(S)
% Input
%    S: The log normalized scattering coefficients.
% Output
%    N/A
% Description
%   Plots the second order log normalized scattering coefficients as a
%   function of j2-j1 (where 2^(-j1) is the first frequency, 2^(-j2) is the
%   second frequency) for various values of j1.

function plot_lognorm_scat2_1d(S)

% Settings

% The lower limit of j2-j1
lowlimit = -2;

% Stop plotting j2-j1 at the max-earlystop
earlystop = 2;

% The values of j1 go up to max-earlyend
earlyend = 1;

%% Initialize

% Adjust settings as needed
earlyend = max(earlyend,earlystop);

% Second order coefficients
S2 = S{3};

% Number of frequencies minus one
maxj1 = max(S2.meta.j(1,:));

% Colormap
C = jet(maxj1-earlyend+1);

% Legend
leg = cell(maxj1-earlyend+1,1);

%% Loop through values of j1 and plot in terms of j2-j1

figure,hold on;
for j1=0:(maxj1-earlyend)
    indj1 = find(S2.meta.j(1,:)==j1);
    j2 = S2.meta.j(2,indj1);
    
    S2j1j2 = S2.signal(indj1);
    S2j1j2 = cat(2,S2j1j2{:});
    S2j1j2 = S2j1j2(1,:);
    
    [j2,indj2] = sort(j2,'ascend');
    S2j1j2 = S2j1j2(indj2);
    
    j2minj1 = j2-j1;
    indj2j1 = j2minj1 >= lowlimit;
    indj2j1((end-earlystop+1):end) = false;
    
    plot(j2minj1(indj2j1),S2j1j2(indj2j1),'Color',C(j1+1,:));
    leg{j1+1} = sprintf('%d',j1);
end
legend(leg);
hold off;

end