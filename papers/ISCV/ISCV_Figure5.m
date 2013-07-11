%%%%%script to generate figure 5 from the paper 'Invariant Scattering Convolution Networks'
%%%%%feb 2012%%%%%%%
%%%%%%Joan Bruna and Stephane Mallat$$$$$$$$$


%%%%%This figure shows two textures with the same power spectrum
%%%%%but different scattering representation. The second texture
%%%%% is a Gaussian process with the power spectrum estimated from 
%%%%%% the first texture.


close all;

Nim=256;
foptions.J=7;
foptions.L=8;
soptions.M=2;
[Wop,filters]=wavelet_factory_2d([256 256], foptions, soptions);

dirac=zeros(Nim);
dirac(1)=1;
dirac=fftshift(dirac);
[scdirac]=scat(dirac,Wop);


if 1

tempo = double(imread('D107.gif'));
r=1;
sizeb=Nim;
for tx=1:2
for ty=1:2
slice = (tempo(1+sizeb*(tx-1):sizeb*tx,1+sizeb*(ty-1):sizeb*ty));
%normalize to zero mean and unit variance
slice = slice - mean(slice(:));
slice = slice / norm(slice(:));
texture{r} = slice;
r=r+1;
end
end


f=texture{1};

T=size(texture,2);
T=min(T,6);
Tbis=T;
Tequ=16;

%estimate the power spectrum over the different realisations of the 
%texture
PS1=zeros(Nim);
SC1=[];
for t=1:T
texturec{t}=crop(texture{t},Nim,128);
texturec{t}=texturec{t}-mean(texturec{t}(:));
texturec{t}=texturec{t}/norm(texturec{t}(:));
PS1 = PS1 + abs(fft2(texturec{t}).^2);
t
end
PS1 = PS1 / T;

%power spectrum equalisation
SC3=[];
PS3=zeros(Nim);
eqfilter= sqrt(PS1);
for t=1:Tbis
	[sc]=scat((texturec{t}),Wop);
	met = recover_meta(sc,scdirac);
	SC1 = [SC1; met.ave];
end
for t=1:Tequ
	%equalized texture
	temp = ifft2(fft2(randn(Nim)).*eqfilter);
	temp=temp-mean(temp(:));
	temp=temp/norm(temp(:));
	PS3 = PS3 + abs(fft2(temp).^2);
	[sc]=scat(temp,Wop);
	met = recover_meta(sc,scdirac);
	SC3=[SC3; met.ave];
end

PS3 = PS3 / Tequ;
if Tbis>1
SC1r = SC1(1,:);
SC1 = mean(SC1);
end
if Tequ >1
SC3var = var(SC3,1);
SC3 = mean(SC3);
end

geq=(ifft2(fft2(randn(Nim)).*eqfilter));

end

%compute scattering displays
copts.renorm_process=0;
copts.l2_renorm=1;
[SCA1]=scat_display(sc,scdirac,copts,SC1);
[SCA3]=scat_display(sc,scdirac,copts,SC3);


%compute distances

ord1=find(met.order==2);
difer=SC1(ord1)-SC3(ord1);
ratio1=sum(difer.^2)/(sum(SC3var(ord1)))

ord2=find(met.order==3);
difer=SC1(ord2)-SC3(ord2);
ratio2=sum(difer.^2)/(sum(SC3var(ord2)))

att1=1.1;
att2=1;

%display results
normvalues(1)=att1*max(max(SCA1{1}(:)),max(SCA3{1}(:)));
normvalues(2)=att2*max(max(SCA1{2}(:)),max(SCA3{2}(:)));
show_two_spectra_dlux_ps(f,SCA1,PS1,.5,normvalues);
show_two_spectra_dlux_ps(geq,SCA3,PS3,.5,normvalues);

