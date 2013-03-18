function out = display_filter_spatial_all(filters, n, renorm)
% function out = display_filter_spatial_all(filters, n, renorm)
% display all the fine-resolution filters of the filter bank
%
% input : 
% - filters : <1x1 struct> filter bank typically obtained with
%       gabor_filter_bank_2d.m
% - n : <1x1 int> [optional] the cropping size
% - renorm : <1x1 bool> [optional] renorm all filters for better readability
%
% output : 
% - out : <NxM struct> with all the filters display

if (~exist('n','var'))
  n =32;
end
if (~exist('renorm','var'))
  renorm = 1;
end

N = 2*n+1;
out = zeros(N*(numel(filters.psi{1})), (2*N+1)*numel(filters.psi{1}{1}));
for i = 1:numel(filters.psi{1})
  for j = 1:numel(filters.psi{1}{1})
    ff = display_filter_spatial(filters.psi{1}{i}{j}, n);
    M = max(abs(ff(:)));
    if (renorm == 0)
      M = 1;
    end
    out((1:N)+ (i-1)*N, (1:N) + (j-1)*N) = real(ff)/M;
    out((1:N)+ (i-1)*N, (1:N) + (j-1+numel(filters.psi{1}{1}))*N) = imag(ff)/M;
  end
end
ff = (display_filter_spatial(filters.phi{1}, n));
M = max(abs(ff(:)));
if (renorm == 0)
  M = 1;
end
out((1:N), (1:N)+ (2*numel(filters.psi{1}{1}))*N) = real(ff)/M;
out((1:N)+N ,(1:N)+ (2*numel(filters.psi{1}{1}))*N) = imag(ff)/M;
imagesc(out);
end