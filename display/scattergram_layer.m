%SCATTERGRAM_LAYER Formats a one-dimensional layer as an image
% Usages
%   img = scattergram_layer(X,[])
%
%   img = scattergram_layer(X,j)
%
% Input
%    X (struct): a scattering representation layer
%    j (integer array): a vector of scale indexes 
%
% Output
%    img (numeric): a two-dimensional array of scattering coefficients,
%    indexed by scale and time
%
% Description
%    This function is called by SCATTERGRAM, layer by layer, in order to
%    provide a time-frequency visualisation of scattering coefficients.
%
% See also
%   SCATTERGRAM  
    

function img = scattergram_layer(X,j)
	if all(size(j)==[0 0])
		j = zeros(0,1);
	end
	
	nbTimePt = max(cellfun(@(x)(size(x,1)), X.signal));
	
	max_jm = max(X.meta.j(end,:)+1);
	
	img = -Inf*ones(max_jm, nbTimePt);

	ind = find(all(bsxfun(@eq,X.meta.j(1:end-1,:),j),1));
	
	signal = cellfun( ...
		@(x)(real(interpft(x,nbTimePt).*sqrt(size(x,1)/nbTimePt))), ...
		X.signal(ind),'UniformOutput',false);
	
	img(X.meta.j(end,ind)+1,:) = [signal{:}].';
end