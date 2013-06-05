% This function returns the set of three tables to be used for the
% the display of scalograms.

function scattergram(S1,U,j1)
	imgU1 = scat_img(U{2},zeros(0,1));
	imgS1 = scat_img(S1{2},zeros(0,1));
	
	imgS2_j1 = scat_img(S1{3},j1);

	subplot(3,1,1);imagesc(imgU1);
	subplot(3,1,2);imagesc(imgS1); 
	subplot(3,1,3);imagesc(imgS2_j1);
end

function img = scat_img(X,j)
	nbTimePt = max(cellfun(@(x)(size(x,1)), X.signal));
	
	max_jm = max(X.meta.j(end,:)+1);
	
	%img = ones(max_jm, nbTimePt)*log(epsilon);
	img = -Inf*ones(max_jm, nbTimePt);

	ind = find(all(bsxfun(@eq,X.meta.j(1:end-1,:),j),1));
	
	signal = cellfun(@(x)(interp(x,nbTimePt/size(x,1))), ...
		X.signal(ind),'UniformOutput',false);
	
	%img(X.meta.j(end,ind)+1,:) = log(abs([signal{:}].')+epsilon);
	img(X.meta.j(end,ind)+1,:) = [signal{:}].';
end
