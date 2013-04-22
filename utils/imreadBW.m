% function [f] = imreadBW (filename)
% This function reads any image, convert it in black and white and rescale
% it to range 0..1
function f = imreadBW (filename)
	
	fcol= imread(filename);
	
	%do it only if the image is in color
	if numel(size(fcol))==3
		fcold=double(fcol);
		if (size(size(fcol),2)==3)
			f=1/255*(0.3*fcold(:,:,1) + 0.59*fcold(:,:,2) + 0.11*fcold(:,:,3));
		end
		if (size(size(fcol),2)==2)
			f=fcold;
		end
	else
		f=double(fcol)/255;
	end
	
end