function z_conv_filter = sub_conv_1d_along_third_dim_simple(zf, filter, ds)
	if (isstruct(filter))
		filter = filter.coefft{1};
	end
	filter_rs = repmat(reshape(filter,[1,1,numel(filter)]),...
		[size(zf,1),size(zf,2),1]);
	z_conv_filter = ifft(zf.* filter_rs,[],3);
	if (ds>0) % optimization
		z_conv_filter = 2^(ds/2)*z_conv_filter(:,:,1:2^ds:end);
	end
end

