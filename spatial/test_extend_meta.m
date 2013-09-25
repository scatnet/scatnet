clear;
meta1.j = [1,2,3,4];

meta2.j = [1,2,3,4,5,6;1,2,3,4,5,6];
meta2.theta = [1,2,3,4,5,6];
[fn, nfn1, nfn2] = merge_fieldnames(meta1, meta2);


p1 = 1;
p2 = 2;
p = 1;
meta= struct();

tic;
for i = 1:100

meta = extend_meta(p, meta, meta1, p1, meta2, p2, fn, nfn1, nfn2);

end
toc;
