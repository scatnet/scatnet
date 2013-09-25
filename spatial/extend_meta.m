function meta = extend_meta(p, meta, meta1, p1, meta2, p2, fn, nfn1, nfn2)
	for i = 1:numel(fn)
		for i1 = 1:nfn1(i)
			eval(['meta.', fn{i}, '(i1, p) = meta1.', fn{i}, '(i1, p1);']);
		end
		for i2 = 1:nfn2(i)
			eval(['meta.', fn{i}, '(i2+ nfn1(i), p) = meta2.', fn{i}, '(i2, p2);']);
		end
	end
end
