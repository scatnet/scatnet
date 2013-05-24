function [] = immac(x,i)
	if (nargin<2)
		i = 1;
	end
	filename = sprintf('tmp_%d.png',i);
	
	imwriteBW(x, filename);
	system(['open ',filename]);
	
end