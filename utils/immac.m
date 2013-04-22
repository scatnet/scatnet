function [] = immac(x)
	
	imwriteBW(x, 'tmp.png');
	system('open tmp.png');
	
end