function out = wavelet_modulus_2d(x, filters, downsampler, options)
% function out = wavelet_modulus_2d(x, filters, downsampler, options)
%
% apply wavelet transform and complex modulus to an image 
%
% inputs :
% - x           : <NxM double>  input image
% - filters     : <1x1 struct> filter bank typically obtained with
%   gabor_filter_bank_2d.m
% - downsampler : <function_handle> that return the log2 of the downsampling step
%   as a function of the scale 
% - options     : [optional] <1x1 struct> that may contain :
%   - preserve_l2_norm : [optional] <1x1 bool> wether the downsampling
%     should preserves the L2 norm of the signal.
%
% output :
% - out : <1x1 struct> containing fields :
%   - sig{p}        : the image of the p-th path of the wavelet-modulus transform
%   - meta.j(p)     : the sequence of j (log-a of scale) corresponding to this path
%   - meta.theta(p) : the sequence of theta (orientation) corresponding to this path
%   - meta.res(p)   : the sequence of log2 of resolution corresponding to this path
%     
%

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