% scatter_meta : Scatter two different meta field of scattering
%
% Usage :
%	scatter_meta(S{3}, 'j', 1, 'j', 2) will draw a scatter plot
%		where each point corresponds to a scattering path, the x axis
%		corresponds to j1, the y axis corresponds to j2
function scatter_meta(meta, field_name_1, id1, field_name_2, id2)
	
	vec2plot=eval(['meta.',field_name_1]);
	vec2plot = vec2plot(id1,:);
	
	vec2plot2=eval(['meta.',field_name_2]);
	vec2plot2 = vec2plot2(id2,:);
	
	scatter(vec2plot,vec2plot2);
	
	
	xlabel([field_name_1,int2str(id1)]);
	ylabel([field_name_2,int2str(id2)]);
end

