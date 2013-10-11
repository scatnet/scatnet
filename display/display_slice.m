% DISPLAY_SLICE Display a scattering transform slice
%
% Usage
%    [sc1, sc2] = DISPLAY_SLICE(S, t, scale, options)
%
% Input
%    S (cell): A scattering transform.
%    t (int): The time index for which coefficients are to be displayed.
%    scale (int, optional): The j-prefix of the coefficients to be displayed
%       (default []).
%    options (struct, optional): Different options for the display. Currently 
%       unused.
%
% Output
%    sc1 (numeric): The coefficients satisfying j = [scale j_m].
%    sc2 (numeric): The coefficients satisfying j = [scale j_m j_(m+1)].
%
% Description
%    The function displays scattering coefficients of order m and m+1, where
%    m = length(scale)-1, whose prefix is given by scale. For the coefficients
%    of order m, there only exists one degree of freedom, the last scale j_m,
%    so these are displayed in a vertical image to the left. The coefficients
%    of order m+1 exhibit two degrees of freedom, j_m and j_(m+1), and so is
%    plotted as a two-dimensional image to the right, with j_m running along
%    the same axis as the mth-order coefficients (vertically) and j_m
%    running along the horizontal axis. Note that scales run from top to bot-
%    om and right to left so that frequencies run from bottom to top and
%    left to right.
%
%    The most typical usage leaves scale equal to the empty prefix, giving a
%    display of first-order coefficients to the left and second-order coef-
%    ficients to the right.
%
% See also 
%    SCATTERGRAM

function [sc1, sc2] = display_slice(S,t,scale,options)
	if nargin < 2
		t = [];
	end
	
	if nargin < 3
		scale = [];
	end
	
	if nargin < 4
		options = struct();
	end
	
	if isempty(t)
		t = 1:size(S{1}.signal{1},2);
	end
	
	m0 = length(scale);
	
	% Extract the coefficients that start with scale 'scale'
	if m0 == 0
		mask1 = true(size(S{m0+2}.signal));
		mask2 = true(size(S{m0+3}.signal));
	else
		mask1 = all(bsxfun(@eq,S{m0+2}.meta.j(1:m0,:),scale),1);
		mask2 = all(bsxfun(@eq,S{m0+3}.meta.j(1:m0,:),scale),1);
	end
	
	% Get min and max scales to make sure images line up
	min_scale1 = min(S{m0+2}.meta.j(m0+1,mask1));
	min_scale2 = min(S{m0+3}.meta.j(m0+2,mask2));
	max_scale1 = max(S{m0+2}.meta.j(m0+1,mask1));
	max_scale2 = max(S{m0+3}.meta.j(m0+2,mask2));
	
	sc1 = [S{m0+2}.signal{:}].';
	sc2 = [S{m0+3}.signal{:}].';
	
	sc1 = mean(sc1(mask1,t),2);
	sc2 = mean(sc2(mask2,t),2);
	
	clim = [min([sc1(:); sc2(:)]), max([sc1(:); sc2(:)])];
	
	subplot(1,8,1);
	imagesc(sc1,clim);
	set(gca,'XTick',[]);
	set(gca,'YTick',[]);
	set(gca,'YDir','reverse');
	ylabel(sprintf('\\omega_%d',m0+1));
	title(sprintf('m=%d',m0+1));
	
	sc2_matrix = -Inf*ones(max_scale1-min_scale1+1,max_scale2-min_scale2+1);
	matrix_ind = sub2ind(size(sc2_matrix), ...
		S{m0+3}.meta.j(m0+1,mask2)-min_scale1+1, ...
		S{m0+3}.meta.j(m0+2,mask2)-min_scale2+1);
	sc2_matrix(matrix_ind) = sc2;
	subplot(1,8,2:8);
	imagesc(sc2_matrix,clim);
	set(gca,'XTick',[]);
	set(gca,'YTick',[]);
	set(gca,'YDir','reverse');
	set(gca,'XDir','reverse');
	xlabel(sprintf('\\omega_%d',m0+2));
	title(sprintf('m=%d',m0+2));
	
	sc2 = sc2_matrix;
end