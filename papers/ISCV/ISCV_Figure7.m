%%%%%script to generate figure 7 from the paper 'Invariant Scattering Convolution Networks'
%%%%%feb 2012%%%%%%%
%%%%%%Joan Bruna and Stephane Mallat$$$$$$$$$


%%%%%This figure displays the scattering coefficients of
%%%%%% a digit taken from the MNIST dataset.

d=4;
Nim=32;
copts.renorm_process=0;
copts.l2_renorm=1;
foptions.J=3;
foptions.L=8;
soptions.M=2;
soptions.oversampling = 0;
[Wop,filters]=wavelet_factory_2d([Nim Nim], foptions, soptions);

dirac=zeros(Nim);
dirac(1)=1;
dirac=fftshift(dirac);
[scdirac]=scat(dirac,Wop);

tr=retrieve_mnist_data(5,5);
im=tr{d}{1}';

%compute scattering coefficients
[sc_digit]=scat(im,Wop);

sc=format_scat(sc_digit);
S=size(sc);


%construct the grid with the scattering displays

drawing1=[];
drawing2=[];
for s1=1:S(2)
	row1=[];
	row2=[];
	for s2=1:S(3)
		tempo=scat_display(sc_digit,scdirac,copts,sc(:,s1,s2));
		row1=[row1 tempo{1}];
		row2=[row2 tempo{2}];
	end
	drawing1=[drawing1 ; row1];
	drawing2=[drawing2 ; row2];
end

[N,M]=size(drawing1);

digit_bg=imresize(im,[N M]);
digit_bg=min(255,max(0,digit_bg));

atten=0.0;

fact1=atten* max(drawing1(:)) / max(digit_bg(:));
fact2=atten* max(drawing2(:)) / max(digit_bg(:));

gg=colormap(gray);
invgg=1-gg;
figure
imagesc(drawing1)
set(gca,'XTick',[]);
set(gca,'YTick',[]);
axis square

figure
imagesc(drawing2)
set(gca,'XTick',[]);
set(gca,'YTick',[]);
axis square

figure
imagesc(digit_bg);
colormap(invgg);
set(gca,'XTick',[]);
set(gca,'YTick',[]);
axis square



