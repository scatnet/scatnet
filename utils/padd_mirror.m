function out=padd_mirror(in,marg)
in=[in(marg(1)+1:-1:2,:);in;in(end-1:-1:end-marg(1),:)];
out=[in(:,marg(2)+1:-1:2),in,in(:,end-1:-1:end-marg(2))];

