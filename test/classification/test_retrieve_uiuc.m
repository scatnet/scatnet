% load all images of uiuc
% takes about 2.5 Go of ram
all_img = retrieve_uiuc;

% display all images of class 1
imagesc(display_gscatt_all(all_img{1}));