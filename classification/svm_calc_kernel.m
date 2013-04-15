function db = svm_calc_kernel(db,kernel_type,kernel_format,kernel_set)
	if nargin < 4
		kernel_set = 1:size(db.features,2);
	end

	if nargin < 3
		kernel_format = 'square';
	end
	
	if nargin < 2
		kernel_type = 'gaussian';
	end
	
	block_size = 8192;

	vector_ct = length(kernel_set);
	
	if strcmp(kernel_format,'square')
		K = zeros(vector_ct+1,vector_ct,class(db.features));
	else
		K = zeros(vector_ct*(vector_ct+3)/2,1,class(db.features));
	end
	
	if strcmp(kernel_type,'gaussian')
		norm1 = sum(abs(db.features(:,kernel_set)).^2,1);
	end
	
	r = 1;
	while r < vector_ct
		ind = r:min(r+block_size-1,vector_ct);
		if strcmp(kernel_type,'linear')
			Kr = db.features(:,kernel_set).'*db.features(:,kernel_set(ind));
		elseif strcmp(kernel_type,'gaussian')
			Kr = -2*db.features(:,kernel_set).'*db.features(:,kernel_set(ind));
			Kr = bsxfun(@plus,norm1.',Kr);
			Kr = bsxfun(@plus,norm1(ind),Kr);
		end
		if strcmp(kernel_format,'square')
			K(2:end,ind) = Kr;
		elseif strcmp(kernel_format,'triangle')
			for k = 1:length(ind)
				ind_k = int64(ind(k));
				% some sort of _colonobj nonsense means we need to split up
				rng = (ind_k-1)*(ind_k-1+3)/2+2:ind_k*(ind_k+3)/2;
				K((ind_k-1)*(ind_k-1+3)/2+1) = ind_k;
				K(rng) = Kr(1:int32(ind_k),k);
			end
		end	
		r = r+length(ind);
	end

	% NOTE: This must be done after to avoid initializing K too early...
	if strcmp(kernel_format,'square')
		K(1,:) = 1:vector_ct;
	end
	
	kernel.kernel_type = kernel_type;
	kernel.kernel_format = kernel_format;
	kernel.kernel_set = kernel_set;
	kernel.K = K;
	
	db.kernel = kernel;
end
