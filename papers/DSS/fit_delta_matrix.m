function projs = fit_delta_matrix(x, theta, borders)
	ns = [-theta:theta]';
	
	recenter = eye(2*theta+1)-[zeros(theta,1); 1; zeros(theta,1)]*ones(1,2*theta+1);
	
	proj = [[zeros(theta,1); 1; zeros(theta,1)] recenter*[ns/sum(ns.^2) ns.^2/sum(ns.^4)]];
	
	projs_cell = arrayfun(@(n)(circshift([proj; zeros(size(x,2)-2*theta-1,3)],n)),[0:size(x,2)-2*theta-1],'UniformOutput',0);
	
	if borders
		for k = theta:-1:1
			projs_cell = [[[zeros(k-1,1);1;zeros(size(x,2)-k,1)] projs_cell{1}(:,2:end)] projs_cell];
			projs_cell = [projs_cell [[zeros(size(x,2)-k,1);1;zeros(k-1,1)] projs_cell{end}(:,2:end)]];
		end
	end
	
	projs = [projs_cell{:}];
end
