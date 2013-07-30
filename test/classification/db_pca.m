function db_out = db_pca(db, d)
	
	db_out = db;
	[U,S,V] = svd(db.features, 'econ');
	Ucut = U(:, 1:d);
	P = Ucut';
	db_out.features = P * db.features;
	
end