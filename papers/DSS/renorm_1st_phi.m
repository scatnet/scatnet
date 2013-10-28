function S = renorm_1st_phi(S,U,Wop,epsilon)
	U0p = U{1};
	U0p.signal{1} = abs(U0p.signal{1});
	S1 = Wop{2}(U0p);
	S1 = S1.signal{1};
	sub_multiplier = 2^(S{2}.meta.resolution(1)/2);
	S{2}.signal = cellfun(@(x)(x./(S1+epsilon*sub_multiplier)),S{2}.signal,'UniformOutput',0);
end
