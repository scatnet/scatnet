% merge_fieldnames
% precompute merge field names to reduce overhead
% and boilerplate code during the copying of meta data
%
% input : two meta structure
%
% output :
%	fn : the merged fieldnames of the two meta structure
%	nfn1 : the number of rows per field in fn for meta1
%	nfn2 : the number of rows per field in fn for meta2
function [fn, nfn1, nfn2] =  merge_fieldnames(meta1, meta2)
	fn1 = fieldnames(meta1);
	fn2 = fieldnames(meta2);
	for i1 = 1:numel(fn1)
		eval(['tmp.', fn1{i1}, '=1']);
	end
	for i2 = 1:numel(fn2)
		eval(['tmp.', fn2{i2}, '=1']);
	end
	fn = fieldnames(tmp);
	for i = 1:numel(fn)
		if (isfield(meta1, fn{i}))
			nfn1(i) = size(eval(['meta1.', fn{i}]), 1);
		else
			nfn1(i) = 0;
		end
		if (isfield(meta2, fn{2}))
			nfn2(i) = size(eval(['meta2.', fn{i}]), 1);
		else
			nfn2(i) = 0;
		end
	end
end