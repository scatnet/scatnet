function Sx = scat_mask(filename, Wop)
	
	Sx = scat(imreadBW(filename), Wop);
	%%
	filename_mask = strrep(filename, 'image', 'mask');	
	mask = imreadBW(filename_mask);
	Wop0{1} = Wop{1};
	mask_avg = scat(mask, Wop0);
	mask_avg = mask_avg{1}.signal{1};
	
	%%
	for m = 1:numel(Sx)
		for p = 1:numel(Sx{m}.signal)
			Sx{m}.signal{p} = Sx{m}.signal{p} .* mask_avg / sum(mask_avg(:));
		end
	end
	
end
