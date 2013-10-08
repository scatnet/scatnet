function db=standardize(db,epsilon)

% Compute the standard deviation of each line of the matice db.features
% and divide all the coefficients of this line by that value. At the end
% each line has a variance of one.

if nargin <2
    epsilon=2^(-20)  % ~ 1e-6
    
end

db_sigma=std(db.features,[],2);
db.features=db.features./(repmat(db_sigma,1,size(db.features,2))+epsilon);

ebd
