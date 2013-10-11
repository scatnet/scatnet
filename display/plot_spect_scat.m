% PlotSpectScat(x,nScatt)
% Color plot of the scattering power spectrum
% x gives the horizontal axis
% nScatt is the normalized scattering tranform which is piecewise constant
% The color on each interval depends upon the path length:
% 0 is yellow, 1 is red, 2 is green 3 is blue, 4 is magenta

function plot_spect_scat(x,nScatt)
	%function PlotSpectScat(x,Scat,J)
	
	N = size(nScatt,2);
	color(1) = 'y';
	color(2) = 'r';
	color(3) = 'g';
	color(4) = 'b';
	color(5) = 'm';
	color(6) = 'k';
	color(7:99) = 'k';
	n=1;
	while(n<N)
		X(1) = x(n);
		Y(1) = nScatt(n);
		m = (round(10^(7) * Y(1) - 10 * floor(Y(1) * 10^(6))))+1;
		y = Y(1);
		while ((y == Y(1)) && (n < N))
			n = n+1;
			y = nScatt(n);
		end
		X(2) = x(n-1);
		Y(2) = Y(1);
		plot(X,Y.^2,color(m));
		hold on;
		X(1) = X(2);
		Y(1) = y;
		if(Y(1) > Y(2))
			m = (round(10^(7) * y - 10 * floor(Y(1) * 10^(6))))+1;
		end
		plot(X,Y.^2,color(m));
		
	end
	hold off;
end