% SCATTERGRAM Displays temporal evolution of scattering coefficients
%
% Usage
%    img = SCATTERGRAM(X{m+1}, [j_1 j_2 ... j_(m-1)]);
%
%    img = SCATTERGRAM(X{m1+1}, [j_1 j_2 ... j_(m1-1)], ...
%                      X{m2+1}, [j_1 j_2 ... j_(m2-1)]);
%
% Input
%    X (struct): Scattering layer. Output S or U from SCAT.
%
% Output
%    img (cell): Cell array of the images output given by the coefficients and
%       prefixes.
%
% Description
%    Given a scattering layer of order m and a prefix of length (m-1), the 
%    function constructs a image by varying the mth scale and time, creating
%    a time-frequency display. The scattering layer can be either a scattering
%    output S or a wavelet modulus output U.
%
%    To construct multiple displays, multiple pairs of scattering layer and
%    prefix can be given as input. The images generated are output as a cell
%    array of tables in img.
%
% See also 
%    DISPLAY_SLICE

function img = scattergram(varargin)
	ndisp = nargin/2;
	for n = 1:ndisp
		img{n} = scat_img(varargin{(n-1)*2+1},varargin{(n-1)*2+2});
		subplot(ndisp,1,n);
		imagesc(img{n});
    end
    colormap gray; % avoids default jet colormap
end

function img = scat_img(X,j)
	if all(size(j)==[0 0])
		j = zeros(0,1);
	end
	
	nbTimePt = max(cellfun(@(x)(size(x,1)), X.signal));
	
	max_jm = max(X.meta.j(end,:)+1);
	
	img = -Inf*ones(max_jm, nbTimePt);

	ind = find(all(bsxfun(@eq,X.meta.j(1:end-1,:),j),1));
	
	signal = cellfun(@(x)(interpft(x,nbTimePt)), ...
		X.signal(ind),'UniformOutput',false);
	
	img(X.meta.j(end,ind)+1,:) = [signal{:}].';
end
