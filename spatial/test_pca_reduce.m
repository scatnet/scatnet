
db2.features = log(db.features(:,:));
cut = 200;
[db2,u] = pca_cut(db2,cut); 
