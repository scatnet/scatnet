function [db2, U] = pca_cut(db, ncut)
	db2 = db;
	[U,S,V] = svd(db.features, 'econ');
	
	db2.features = U(:,1:ncut)'*db.features;
end

