
%%%%%script to generate figure 1 of Invariant Scattering Convolution Networks
%%%%%feb 2012%%%%%%%
%%%%%%Joan Bruna and Stephane Mallat$$$$$$$$$


%%%%%This figure shows the Morlet Wavelet used throughout the numerical
%%%%%experiments of the paper%%%%%%%%

N=256;
%options.wavelet_family='morlet';
%options=configure_wavelet_options(options);
%filters=options.filter_bank_name([N N], options);
foptions.J=2;
foptions.L=6;
soptions.M=2;
[Wop,filters]=wavelet_factory_2d([N N], foptions, soptions);

R=8;

Nc=55;

figure
imagesc(flipud(crop(real(fftshift(ifft2(filters.psi.filter{R}.coefft{1}))),Nc,N/2)))
colormap gray
axis square
set(gca,'YTick',[])
set(gca,'XTick',[])

figure
imagesc(flipud(crop(imag(fftshift(ifft2(filters.psi.filter{R}.coefft{1}))),Nc,N/2)))
colormap gray
axis square
set(gca,'YTick',[])
set(gca,'XTick',[])


figure
imagesc(add_circular_mask(flipud(abs(fftshift(filters.psi.filter{R}.coefft{1}))),0.98,1))
%imagesc((flipud(abs(fftshift(filters.psi{1}{2}{2})))))
cc=colormap(gray);
colormap(1-cc)
axis square
axis off
set(gca,'YTick',[])
set(gca,'XTick',[])

