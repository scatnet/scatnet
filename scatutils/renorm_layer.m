function U = renorm_layer(U, h, K, method)
	for p = 1:numel(U.signal)
		if (numel(size(U.signal{p}))==3)
			for th = 1:size(U.signal{p},3)
				U.signal{p}(:,:,th) = renorm_signal(U.signal{p}(:,:,th), h, K, method);
			end
		else
			U.signal{p} = renorm_signal(U.signal{p}, h, K, method);
		end
	end
end
