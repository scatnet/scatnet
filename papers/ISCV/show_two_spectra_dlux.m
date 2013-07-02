function show_two_spectra_dlux(test,outsplit, nosquare, normvalue)
%this function displays an input image, its fourier modulus and its scattering coefficients
%test=input image
%outsplit=scattering coefficients display (obtained from fulldisplay2d)
%nosquare=gamma coefficient for the display
%normvalue=renormalisation value for the image contrast. 

%%2011 Joan Bruna

if nargin < 4
	nosquare=.5;
	normvalue(1) = max(outsplit{1}(:));
	normvalue(2) = max(outsplit{2}(:));
end

cc=colormap(gray);
invgray=1-cc;

invgray=colormap(jet);

figure
imagesc(test);colormap gray;%axis off;
axis square;
set(gca,'XTick',[])
set(gca,'YTick',[])

cropfactor2=0.75;
cropfactor=0.95;
rad=0.98;

figure
spectr=abs(imresize(fftshift(abs(fft2(test)).^nosquare),4));
imagesc(add_circular_mask(crop(spectr.^nosquare,round(cropfactor2*size(spectr,1)),round(size(spectr,1)/2)),rad,1));%colormap(invgray);
axis square;
axis off;

figure
image(add_circular_mask(crop(64*outsplit{1}/normvalue(1),round(cropfactor*size(outsplit{1},1)),round(size(outsplit{1},1)/2)),rad));%colormap(invgray);
axis square;
axis off;

figure
image(add_circular_mask(crop(64*outsplit{2}/normvalue(2),round(cropfactor*size(outsplit{2},1)),round(size(outsplit{2},1)/2)),rad));%colormap(invgray);
axis square;
axis off;

end


