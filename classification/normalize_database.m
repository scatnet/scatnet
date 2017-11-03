% NORMALIZE_DATABASE Normalize each feature vector in a database
%
% Usage
%    db = normalize_database(db);
%
% Input
%    db (struct): The database object whose feature are to be normalized.
%
% Ouput
%    db (struct): The same database object, but with each feature vector
%       normalized so that it is of mean zero and unit variance.

function db = normalize_database(db)
	db.features = bsxfun(@minus, db.features, mean(db.features, 1));
	db.features = bsxfun(@times, db.features, 1./std(db.features, [], 1));
end
