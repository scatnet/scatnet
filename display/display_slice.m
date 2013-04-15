function display_scatt_slice(S,t,scale,options)
	if nargin < 2
		t = [];
	end
	
	if nargin < 3
		scale = [];
	end
	
	if nargin < 4
		options = struct();
	end
	
	if isempty(t)
		t = 1:size(S{1}.signal{1},2);
	end
	
	m0 = length(scale);
	
	% Extract the coefficients that start with scale 'scale'
	if m0 == 0
		mask1 = true(size(S{m0+2}.signal));
		mask2 = true(size(S{m0+3}.signal));
	else
		mask1 = all(bsxfun(@eq,S{m0+2}.meta.scale(:,1:m0),scale),2);
		mask2 = all(bsxfun(@eq,S{m0+3}.meta.scale(:,1:m0),scale),2);
	end
	
	% Get min and max scales to make sure images line up
	min_scale1 = min(S{m0+2}.meta.scale(mask1,m0+1));
	min_scale2 = min(S{m0+3}.meta.scale(mask2,m0+2));
	max_scale1 = max(S{m0+2}.meta.scale(mask1,m0+1));
	max_scale2 = max(S{m0+3}.meta.scale(mask2,m0+2));
	
	sc1 = [S{m0+2}.signal{:}].';
	sc2 = [S{m0+3}.signal{:}].';
	
	sc1 = mean(sc1(mask1,:),2);
	sc2 = mean(sc2(mask2,:),2);
	
	clim = [min([sc1(:); sc2(:)]), max([sc1(:); sc2(:)])];
	
	subplot(1,8,1);
	imagesc(sc1,clim);
	set(gca,'XTick',[]);
	set(gca,'YTick',[]);
	set(gca,'YDir','reverse');
	ylabel(sprintf('\\omega_%d',m0+1));
	title(sprintf('m=%d',m0+1));
	
	sc2_matrix = -Inf*ones(max_scale1-min_scale1+1,max_scale2-min_scale2+1);
	matrix_ind = sub2ind(size(sc2_matrix), ...
		S{m0+3}.meta.scale(mask2,m0+1)-min_scale1+1, ...
		S{m0+3}.meta.scale(mask2,m0+2)-min_scale2+1);
	sc2_matrix(matrix_ind) = sc2;
	subplot(1,8,2:8);
	imagesc(sc2_matrix,clim);
	set(gca,'XTick',[]);
	set(gca,'YTick',[]);
	set(gca,'YDir','reverse');
	set(gca,'XDir','reverse');
	xlabel(sprintf('\\omega_%d',m0+2));
	title(sprintf('m=%d',m0+2));
end