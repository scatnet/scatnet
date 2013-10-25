% SVM_CALC_KERNEL Precalculate SVM kernel
%
% Usage
%    database = SVM_CALC_KERNEL(database, kernel_type, kernel_format, ... 
%       kernel_set)
%
% Input
%    database (struct): The database containing the feature vectors.
%    kernel_type (char): The type of kernel: 'linear', or 'gaussian' (default 
%       'gaussian')
%    kernel_format (char): The format in which to store the kernel: 'square', or 
%       'triangle'. The latter only takes half the space (default 'square').
%    kernel_set (int): The set of indices for which the kernel is computed. 
%       Note that only these are used for training and testing, so if a subset
%       of the full database is chosen, performance might degrade. To manually
%       recalculate the kernel during testing, the full_test_kernel option can
%       be set and passed to svm_train (default 1:size(db.features,2)).
%
% Output
%    database (struct): The input database, with a kernel field added contain-
%       ing the precalculated kernel.
%
% See also
%    SVM_TRAIN

function db = svm_calc_kernel(db, kernel_type, kernel_format, kernel_set)
	% Set default options.
	if nargin < 4
		kernel_set = 1:size(db.features,2);
	end

	if nargin < 3
		kernel_format = 'square';
	end
	
	if nargin < 2
		kernel_type = 'gaussian';
	end

	% To reduce memory requirements, the kernel is computed in blocks of fixed
	% size. A smaller value for block_size gives less memory usage, but at a 
	% potential increase in computational speed.
	block_size = 8192;

	vector_ct = length(kernel_set);
	
	if strcmp(kernel_format,'square')
		% K is a matrix of size vector_ct+1 rows and vector_ct columns, with the
		% first row containing the index of the vector and the remaining rows
		% containing the kernel values.
		K = zeros(vector_ct+1,vector_ct,class(db.features));
	else
		% K is a packed version of the 'square' kernel described above, taking advan-
		% tage of the symmetry in the kernel value section of the matrix, excluding
		% the vector indices row. The matrix is stored in column-major form.
		K = zeros(vector_ct*(vector_ct+3)/2,1,class(db.features));
	end
	
	if strcmp(kernel_type,'gaussian')
		% If we're calculating a Gaussian kernel, we can save time by precalculating
		% all the square norms.
		norm1 = sum(abs(db.features(:,kernel_set)).^2,1);
	end
	
	r = 1;
	while r < vector_ct
		% Calculate the current block of vectors. These are decomposed over all vec-
		% tors to yield a sub-matrix of size vector_ct rows and block_size columns.
		% Note that since MATLAB stores matrices in column-major format, it is faster
		% to fill up the matrix this way.
		ind = r:min(r+block_size-1,vector_ct);
		
		% Calculate the whole sub-kernel before worrying about storage.
		if strcmp(kernel_type,'linear')
			% Linear kernel - just calculate the scalar products.
			Kr = db.features(:,kernel_set).'*db.features(:,kernel_set(ind));
		elseif strcmp(kernel_type,'gaussian')
			% Gaussian kernel - calculate the scalar products, multiply by -2 and add
			% the square norms.
			Kr = -2*db.features(:,kernel_set).'*db.features(:,kernel_set(ind));
			Kr = bsxfun(@plus,norm1.',Kr);
			Kr = bsxfun(@plus,norm1(ind),Kr);
		end

		if strcmp(kernel_format,'square')
			% Square kernel - just store it in the appropriate columns.
			K(2:end,ind) = Kr;
		elseif strcmp(kernel_format,'triangle')
			for k = 1:length(ind)
				% For each of the column vectors, store part of it in the triangle.
				% The packing scheme specifies that the (r,c)th element, for r >= 0,
				% c >= 0 and r <= c+1, is found at index c*(c+3)/2+r.

				% To avoid rounding errors...
				ind_k = int64(ind(k));
				
				% Store vector index.
				K((ind_k-1)*(ind_k-1+3)/2+1) = ind_k;

				% Store kernel values. Some sort of _colonobj nonsense means we need to 
				% split up and define rng outside of K().
				rng = (ind_k-1)*(ind_k-1+3)/2+2:ind_k*(ind_k+3)/2;
				K(rng) = Kr(1:int32(ind_k),k);
			end
		end	
		r = r+length(ind);
	end

	% NOTE: This must be done after to avoid initializing K too early...
	if strcmp(kernel_format,'square')
		% Fill in the vector indices.
		K(1,:) = 1:vector_ct;
	end
	
	kernel.kernel_type = kernel_type;
	kernel.kernel_format = kernel_format;
	kernel.kernel_set = kernel_set;
	kernel.K = K;
	
	db.kernel = kernel;
end
