% This function returns the set of three tables to be used for the
% the display of scalograms.

function scattergram(U,S1,layerNb,j1,eps1,eps2,eps3)
	imgU1 = scat_img(U{layerNb},zeros(0,1),eps1);
	imgS1 = scat_img(S1{layerNb},zeros(0,1),eps2);
	
	S1 = renorm_scat(S1);

	imgS2_j1 = scat_img(S1{layerNb+1},j1,eps3);

	subplot(3,1,1);imagesc(imgU1);
	subplot(3,1,2);imagesc(imgS1); 
	subplot(3,1,3);imagesc(imgS2_j1);
end

function img = scat_img(X,j,epsilon)
	nbTimePt = max(cellfun(@(x)(size(x,1)), X.signal));
	
	max_jm = max(X.meta.j(end,:)+1);
	
	img = ones(max_jm, nbTimePt)*log(epsilon);
	
	ind = find(all(bsxfun(@eq,X.meta.j(1:end-1,:),j),1));
	
	signal = cellfun(@(x)(interp(x,nbTimePt/size(x,1))), ...
		X.signal(ind),'UniformOutput',false);
	
	img(X.meta.j(end,ind)+1,:) = log(abs([signal{:}].')+epsilon);
end