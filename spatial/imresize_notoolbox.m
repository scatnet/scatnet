function out = imresize_notoolbox(in,size_out)
% laurent sifre - 7 nov 2012
% do the same thing as imresize but without the image toolbox
% in = lena;
% in = in(:,1:400);
% size_out = [1024,1024];
% in(end,end) = 1;
%%
[n,m] = size(in);
N = size_out(1);
M = size_out(2);
[x,y] = meshgrid(1:m,1:n);
[X,Y] = meshgrid(1:M,1:N);
xi = 1 + (m-1)*(X-1)/(M-1);
yi = 1 + (n-1)*(Y-1)/(N-1);
out = interp2(x,y,in,xi,yi,'linear');