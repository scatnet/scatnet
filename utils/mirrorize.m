function out=mirrorize(in,marg)
if isvector(in)
if mod(length(in),2)
out=[in(marg+1:-1:1);in;in(end-1:-1:end-marg)];
else
out=[in(marg+1:-1:2);in;in(end-1:-1:end-marg)];
end
return;
end
in=[in(marg(1)+1:-1:2,:);in;in(end-1:-1:end-marg(1),:)];
out=[in(:,marg(2)+1:-1:2),in,in(:,end-1:-1:end-marg(2))];

