What's new in ScatNet v0.2 :
* More efficient wavelet transforms with the cascade algorithm : see
core/wavelet_factory_2d_pyramid.m
* Frequency transposition invariance : see core/scat_freq.m
* Roto-translation invariance : see core/wavelet_factory_3d_pyramid.m
* Inverse scattering transform for 1D : see reconstruction/
* Selesnick wavelets of compact support : see
filters/selesnick_filter_bank_1d.
* Improved display : see display/
* New utility functions for classification : see scatutils/
* A comprehensive documentation PDF file : see doc/
* 15 demos : see demo/
* Standard headers for all functions
* The MATLAB Signal Processing Toolbox is no longer required


ScatNet v0.2
------------

ScatNet is a MATLAB library for scattering networks.

See our homepage of the project for documentation, tutorials, and bibliography

http://www.di.ens.fr/data/software/scatnet/

Contact
-------

For any enquiry, please write to the brand new e-mail address of our team :
scatnet[AT]di[DOT]ens[DOT]fr
where [AT] and [DOT] must be replaced by the characters @ and . respectively.

Install ScatNet
---------------

- launch `addpath_scatnet` from matlab shell

[optional] : add the following two lines to your startup.m file
so that matlab does the addpath automatically when it starts: 


    addpath /path/to/scatnet;
    addpath_scatnet;

Quickstarts
-----------

Use ScatNet with audio signals:
http://www.di.ens.fr/data/software/scatnet/quickstart-audio/

Use ScatNet with images:
http://www.di.ens.fr/data/software/scatnet/quickstart-image/

Team
-------

Developers : Laurent Sifre, Joakim Anden, Edouard Oyallon, Michel Kapoko, Vincent Lostanlen.

Beta-testers : Irene Waldspurger, Guy Wolf, Matthew Hirn.

Many thanks to : Stephane Mallat, our team leader ; Ivan Selesnick (NYU), of which the filters/selesnick/ package appears courtesy ; Joan Bruna (NYU) for his help.
