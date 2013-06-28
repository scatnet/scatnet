% This function returns the set of three tables to be used for the
% the display of scalograms.

function img = scattergram(varargin)
	ndisp = nargin/2;
	for n = 1:ndisp
		img{n} = scat_img(varargin{(n-1)*2+1},varargin{(n-1)*2+2});
		subplot(ndisp,1,n);
		imagesc(img{n});
	end
end

function img = scat_img(X,j)
	if all(size(j)==[0 0])
		j = zeros(0,1);
	end
	
	nbTimePt = max(cellfun(@(x)(size(x,1)), X.signal));
	
	max_jm = max(X.meta.j(end,:)+1);
	
	%img = ones(max_jm, nbTimePt)*log(epsilon);
	img = -Inf*ones(max_jm, nbTimePt);

	ind = find(all(bsxfun(@eq,X.meta.j(1:end-1,:),j),1));
	

    signal = cellfun(@(x)(interpft(x,nbTimePt)), ...
        X.signal(ind),'UniformOutput',false);

	
	%img(X.meta.j(end,ind)+1,:) = log(abs([signal{:}].')+epsilon);
	img(X.meta.j(end,ind)+1,:) = [signal{:}].';
end
