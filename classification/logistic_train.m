% SVM_TRAIN Train a logistic regression classifier
%
% Usage
%    model = LOGISTIC_TRAIN(db, train_set, options);
%
% Input
%    db (struct): The database containing the feature vectors.
%    train_set (int): The object indices of the training instances.
%    opt (struct): The training options:
%          opt.max_iter (int): The number of iterations of the Newton-Raphson
%             algorithm to go through before finishing (default 100).
%
% Output
%    model (struct): The logistic regression model.
%
% Description
%    Trains a logistic regression model by maximizing its likelihood on the
%    given training data using the Newton-Raphson optimization algorithm.
%
% See also
%    LOGISTIC_TEST, CLASSIF_ERR, CLASSIF_RECOG

function model = logistic_train(db, train_set, opt)
	if nargin < 3 || isempty(opt)
		opt = struct();
	end

	opt = fill_struct(opt, ...
		'max_iter', 100);

	% Extract feature vectors (x) and class labels (y) from database.
	x = db.features(:,train_set);
	y = [db.src.objects(train_set).class];

	% Calculation below relies on instances indexed over first dimension.
	x = x';
	y = y(:);

	% Add ones in order to incorporate a constant bias.
	x = [ones(size(x, 1), 1) x];

	% Set constants:
	% P - dimensionality,
	% N - number of instances, and
	% K - number of classes.
	P = size(x, 2);
	N = size(x, 1);
	K = max(y);

	% Start with beta at zero. This normally works.
	beta = zeros(P, K-1);

	% Rearrange y from a labels vector to a delta matrix.
	y = bsxfun(@eq, y, 1:(K-1));

	for iter = 1:opt.max_iter
		% Get the responses.
		r = x*beta;

		% Form probabilities.
		p = exp(r);
		p = bsxfun(@times, p, 1./(1+sum(p, 2)));

		% Calculate gradient.
		grad = x'*(y-p);

		% If gradient goes below a threshold, we're done.
		% TODO: Something more clever here that is not dependent on scale.
		if norm(grad(:)) < 1e-5
			break;
		end

		% Calculate the Hessian.
		hess = zeros([P (K-1) P (K-1)]);
		for k = 1:(K-1)
			for l = 1:k
				w = -p(:,k).*p(:,l);
				if k == l
					% TODO: Something more clever than adding 1e-6 here.
					% What happens is that as the probabilities of a certain
					% class goes to zero for a given instance, it starts
					% creating instability. Ideally, we'd deactivate these
					% instances for that particular class and avoid them.
					w = w+p(:,k)+1e-6;
				end
				hess(:,k,:,l) = x'*bsxfun(@times, w, x);
				hess(:,l,:,k) = hess(:,k,:,l);
			end
		end
		hess = reshape(hess, (K-1)*P*ones(1, 2));

		% Perform one step of Newton-Raphson.
		beta = beta + reshape(hess\grad(:), [P (K-1)]);
	end

	model.beta = beta;
end

