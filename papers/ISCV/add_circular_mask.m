function out=add_circular_mask(in,th,norm)
if nargin < 3
norm=0;
end

	thickness=4;
	[N,M]=size(in);
	[ix,iy]=meshgrid([-N/2+1/2:N/2-1/2],[-N/2+1/2:N/2-1/2]);
	rad=ix.^2+iy.^2;
	mask=max(0,thickness-abs(sqrt(rad)-(th*N/2)));
	outermask=(rad < (th*N/2)^2);
	if norm==0
	out=in.*outermask+min(0,min(in(:)))*(1-outermask);
	mask=mask*(max(64,0*max(out(:)))/max(mask(:)));
	else
	out=in.*outermask+min(in(:))*(1-outermask);
	mask=mask*((max(out(:)))/max(mask(:)));
	end
	tope=max(out(:));
	%out=min(tope,out+mask);
	out=(mask/tope).*mask+(1-mask/tope).*out;


if 0
	cjet=colormap(gray);
	cjet=1-cjet;
	inr=in(:);
	if norm==1
	inr=(inr-min(inr))*(55/(max(inr)-min(inr)));
	end
	tempo=cjet(max(1,min(64,round(inr))),:);
	out=reshape(tempo,N,M,3);
	mtempo(:,:,1)=outermask;
	mtempo(:,:,2)=outermask;
	mtempo(:,:,3)=outermask;
	out=out.*mtempo+ (1-mtempo);
end


end

