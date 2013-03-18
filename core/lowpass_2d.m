function out = lowpass_2d(x,filters,downsampler,options)
options.null = 1;
preserve_l2_norm = getoptions(options,'preserve_l2_norm',1);
J = numel(filters.psi{1});
% lowpass filter
ax = ifft2( fft2(x) .* filters.phi{1} );
% downsampling
ds = downsampler(J);
out.sig{1} = downsampling_2d(ax, ds, preserve_l2_norm);
% store meta
out.meta = 'no meta for first layer';
end