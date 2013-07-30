clear;
meta1.j = [1,2,3,4];

meta2.j = [1,2,3,4,5,6;1,2,3,4,5,6];
meta2.theta = [1,2,3,4,5,6];
[fn, nfn1, nfn2] = merge_fieldnames(meta1, meta2);
