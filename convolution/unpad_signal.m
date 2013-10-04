% UNPAD_SIGNAL unpad a signal
%
function x = unpad_signal(x, res, target_sz, center)
	if nargin < 4
		center = 0;
	end
	
	padded_sz = size(x);
	
	if padded_sz(2) == 1
		padded_sz = padded_sz(1);
	end
	
	offset = 0.*target_sz;

	if center
		offset = (padded_sz.*2.^res-target_sz)/2;
	end

	offset_ds = floor(offset./2.^res);
	target_sz_ds = floor(target_sz./2.^res);

	switch length(target_sz)
	case 1
		x = x(offset_ds + (1:target_sz_ds),:,:);
	case 2
		x = x(offset_ds(1) + (1:target_sz_ds(1)), ...
		offset_ds(2) + (1:target_sz_ds(2)), :);
	end
end
