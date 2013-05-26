function circle = draw_circle(size_in, center, radius, sigma_radius)
	n = size_in(1);
	m = size_in(2);
	[x,y] = meshgrid(1:m,1:n);
	distance = sqrt((x-center(1)).^2 + (y-center(2)).^2);
	circle = exp( - (distance - radius).^2/(2*sigma_radius^2));
end