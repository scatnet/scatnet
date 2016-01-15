% LOGISTIC_TEST Calculate labels from a logistic regression model
%
% Usage
%    [labels, p] = LOGISTIC_TEST(db, model, test_set);
%
% Input
%    db (struct): The database containing the feature vectors.
%    model (struct): The logistic regression model obtained from
%       logistic_train.
%    test_set (int): The object indices of the testing instances.
%
% Output
%    labels (int): The assigned labels.
%    p (numeric): The calculated probabilities according to the model.
%
% See also
%    LOGISTIC_TRAIN, CLASSIF_ERR, CLASSIF_RECOG

function [labels, p] = logistic_test(db, model, test_set)
	% Extract feature vectors from database.
	x = db.features(:,test_set);

	% Calculation below relies on instances indexed over first dimension.
	x = x';

	% Set constants:
	% N - number of instances, and
	% K - number of classes.
	N = size(x, 1);
	K = size(model.beta, 2)+1;

	% Add ones in order to incorporate a constant bias.
	x = [ones(size(x, 1), 1) x];

	% Get the responses.
	r = x*model.beta;

	% Form probabilities.
	p = exp(r);
	p = bsxfun(@times, p, 1./(1+sum(p, 2)));
	p = [p 1-sum(p, 2)];

	% Labels are obtained by maximum likelihood.
	[~, labels] = max(p, [], 2);

	% Transform back into instances indexed along second dimension.
	labels = labels';
	p = p';
end

