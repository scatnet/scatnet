%%%%%script to generate figure 9 from the paper 'Invariant Scattering Convolution Networks'
%%%%%feb 2012%%%%%%%
%%%%%%Joan Bruna and Stephane Mallat$$$$$$$$$


%%%%%This figure displays the scattering coefficients of
%%%%%% a texture realisation taken from the Curet dataset.

close all;
clear options;

Nim=128;%TODO waiting for filters to be appliccable for non-dyadic sizes
copts.renorm_process=0;
copts.l2_renorm=1;
foptions.J=7;
foptions.L=8;
soptions.M=2;
[Wop,filters]=wavelet_factory_2d([Nim Nim], foptions, soptions);

dirac=zeros(Nim);
dirac(1)=1;
dirac=fftshift(dirac);
[scdirac]=scat(dirac,Wop);

im = double(imread('28-011.png'));
im=im(1:Nim,1:Nim);
im=im-mean(im(:));
im=im-norm(im(:));

[sc_cur]=scat(im,Wop);
met = recover_meta(sc_cur,scdirac);

cur_disp=scat_display(sc_cur, scdirac,copts, met.ave);

gg=colormap(gray);
invgg=1-gg;

figure
imagesc(im);
colormap(invgg);
set(gca,'XTick',[]);
set(gca,'YTick',[]);
axis square

figure
imagesc(cur_disp{1})
%colormap(invgg);
set(gca,'XTick',[]);
set(gca,'YTick',[]);
axis square


figure
imagesc(cur_disp{2});
%colormap(invgg);
set(gca,'XTick',[]);
set(gca,'YTick',[]);
axis square



