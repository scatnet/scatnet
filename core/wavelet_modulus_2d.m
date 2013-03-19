function out = wavelet_modulus_2d(x, filters, downsampler, options)
% function out = wavelet_modulus_2d(x, filters, downsampler, options)
%
% apply wavelet transform and complex modulus to an image 
%
% inputs :
% - x  : <NxM double> : input image
% - filters : <1x1 struct> : contains the following fields
%   - psi : <nested cell> : filters.psi{res+1}{j+1}{th} contains
%       the fourier transform of high pass filter at resolution res, 
%       scale a^j and orientation index th
%   - phi : <nested cell> : filters.phi{res+1} contains
%       the fourier transform of low pass filter at resolution res
%       and scale a^J
% - downsampler : <function_handle> returns the log2 of the downsampling step
%   as a function of the j (log-a of scale)
% - options     : [optional] <1x1 struct> : may contain :
%   - preserve_l2_norm : [optional] <1x1 bool> wether the downsampling
%     should preserves the L2 norm of the signal.
%
% output :
% - out : <1x1 struct> contains the following fields :
%   - sig{p}        : the image of the p-th path of the wavelet-modulus transform
%   - meta.j(p)     : the sequence of j (log-a of scale) corresponding to this path
%   - meta.theta(p) : the sequence of theta (orientation) corresponding to this path
%   - meta.res(p)   : the sequence of log2 of resolution corresponding to this path

options.null = 1;
preserve_l2_norm = getoptions(options, 'preserve_l2_norm', 1);

J = numel(filters.psi{1});
L = numel(filters.psi{1}{1});
p = 1;
xf = fft2(x);
for j = 0:J-1
  for theta = 1:L
    % wavelet modulus
    ux = abs(ifft2(xf .* filters.psi{1}{j+1}{theta}));
    % downsampling
    ds = downsampler(j) ;
    out.sig{p} = downsampling_2d(ux, ds, preserve_l2_norm);
    % store meta
    out.meta.j(p,1) = j;
    out.meta.theta(p,1) = theta;
    out.meta.res(p,1) = ds;
    p = p+1;
  end
end
end