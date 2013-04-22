function []  = imwriteBW(x,filename)
	m = min(x(:));
	M = max(x(:));
	
	
	xn =  (x-m)/(M-m);
	imwrite(xn,filename);
end