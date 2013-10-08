function db_std = standardize(db, epsilon)
    
    % Compute the standard deviation of each line of the matice db.features
    % and divide all the coefficients of this line by that value. At the end
    % each line has a variance of one.
    if (nargin<2)
        epsilon = 1e-6;
    end
    db_std = db;
    feat_mean = mean(db.features,2);
    feat_std = std(db.features,0,2);
    db_std.features = bsxfun(@rdivide, bsxfun(@minus,db.features,feat_mean), feat_std+epsilon);
end