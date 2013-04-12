function display_multifractal(S,t0)
	clrs = {'r','g','b','c','k','m'};
	
	S1 = [S{2}.signal{:}].';
	S2 = [S{3}.signal{:}].';
	
	subplot(121);
	plot(S1(:,t0));
	title('m=1');
	xlabel('j1');
	
	j1s = unique(S{3}.meta.scale(:,1)).';
	subplot(122);
	hold on
	for j1 = j1s
		plot(S2(S{3}.meta.scale(:,1)==j1,t0), ...
			clrs{mod(j1,length(clrs))+1});
	end
	hold off
	title('m=2');
	xlabel('j2-j1');
end