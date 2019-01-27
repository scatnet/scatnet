% SCATTERGRAM_LAYER Formats a 1D layer as an image
%
% Usage
%    img = SCATTERGRAM_LAYER(X, j)
%
% Input
%    X (struct): A scattering layer, typically obtained from SCAT.
%    j (integer array): A scale prefix specifying which coefficients to
%       extract. If empty, all coefficients are obtained (default empty).
%
% Output
%    img (numeric): A 2D array of scattering coefficients, indexed by scale and
%       time.
%
% Description
%    This function is called by SCATTERGRAM, layer by layer, in order to
%    provide a time-frequency visualisation of scattering coefficients.
%
% See also
%    SCATTERGRAM  

function img = scattergram_layer(X, j)
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
