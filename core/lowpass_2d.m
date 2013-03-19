function out = lowpass_2d(x, filters, downsampler, options)
% function out = lowpass_2d(x, filters, downsampler, options)
%
% apply spatial averaging to an image
%
% inputs :
% - x : <NxM double> : input image
% - filters : <1x1 struct> : contains the following fields
%   - psi : <nested cell> : filters.psi{res+1}{j+1}{th} contains
%       the fourier transform of high pass filter at resolution res, 
%       scale a^j and orientation index th
%   - phi : <nested cell> : filters.phi{res+1} contains
%       the fourier transform of low pass filter at resolution res
%       and scale a^J
% - downsampler : <function_handle> : returns the log2 of the downsampling step
%   as a function of the j (log-a of scale)
% - options     : [optional] <1x1 struct> : may contain :
%   - preserve_l2_norm [optional] <1x1 bool> wether the downsampling
%     should preserves the L2 norm of the signal.
%
% output :
% - out : <1x1 struct> : contains the following fields :
%   - sig{1} : <?x? double> the spatialy averaged image

options.null = 1;
preserve_l2_norm = getoptions(options,'preserve_l2_norm',1);
J = numel(filters.psi{1});
% lowpass filter
ax = ifft2(fft2(x) .* filters.phi{1});
% downsampling
ds = downsampler(J);
out.sig{1} = downsampling_2d(ax, ds, preserve_l2_norm);
% store meta
out.meta = 'no meta for first layer';
end