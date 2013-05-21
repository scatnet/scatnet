
meta = S{3}.meta;

var_y{1}.name = 'j';
var_y{1}.index = 1;
var_y{2}.name = 'j';
var_y{2}.index = 2;

var_x{1}.name = 'k2';
var_x{1}.index = 1;
var_x{2}.name = 'theta2';
var_x{2}.index = 1;

big_img = [];
offset_x = 0;
offset_y = 0;


% evaluate range of each variable
for n_var_x = 1:numel(var_x)
	cur_var_name = var_x{n_var_x}.name;
	cur_var_index = var_x{n_var_x}.index;
	string_var = sprintf('meta.%s(%d,:)', cur_var_name, cur_var_index);
	cur_var = eval(string_var);
	var_x{n_var_x}.min = min(cur_var);
	var_x{n_var_x}.max = max(cur_var);
	begin_pos_x(n_var_x) = var_x{n_var_x}.min;
	end_pos_x(n_var_x) = var_x{n_var_x}.max;
end
for n_var_y = 1:numel(var_y)
	cur_var_name = var_y{n_var_y}.name;
	cur_var_index = var_y{n_var_y}.index;
	string_var = sprintf('meta.%s(%d,:)', cur_var_name, cur_var_index);
	cur_var = eval(string_var);
	var_y{n_var_y}.min = min(cur_var);
	var_y{n_var_y}.max = max(cur_var);
	begin_pos_y(n_var_y) = var_y{n_var_y}.min;
	end_pos_y(n_var_y) = var_y{n_var_y}.max;
end

pos_y = begin_pos_y;
while (norm(pos_y-end_pos_y)~=0)
	pos_x = begin_pos_x;
	while (norm(pos_x-end_pos_x)~=0)
		% show cur pos
		[pos_y, pos_x];
		% construc query
		query = 'find(' ;
		for n_var_x = 1:numel(var_x)
			cur_var_name = var_x{n_var_x}.name;
			cur_var_index = var_x{n_var_x}.index;
			query = sprintf('%s meta.%s(%d,:)==%d &',...
				query,cur_var_name, cur_var_index, pos_x(n_var_x));
		end
		for n_var_y = 1:numel(var_y)
			cur_var_name = var_y{n_var_y}.name;
			cur_var_index = var_y{n_var_y}.index;
			if (n_var_y < numel(var_y))
			query = sprintf('%s meta.%s(%d,:)==%d &',...
				query,cur_var_name, cur_var_index, pos_y(n_var_y));
			else
				query = sprintf('%s meta.%s(%d,:)==%d );',...
				query,cur_var_name, cur_var_index, pos_y(n_var_y));
			end
		end
		query;
		ind = eval(query);
		if (numel(ind)>0)
			query
			ind
		end
		
		% incr
		pos_x(end) = pos_x(end)+1;
		% update
		while (sum(pos_x>end_pos_x)>0)
			ind = find(pos_x>end_pos_x);
			pos_x(ind) = 0;
			pos_x(ind-1) = pos_x(ind-1)+1;
		end
	end
	% incr
	pos_y(end) = pos_y(end)+1;
	% update
	while (sum(pos_y>end_pos_y)>0)
		ind = find(pos_y>end_pos_y);
		pos_y(ind) = 0;
		pos_y(ind-1) = pos_y(ind-1)+1;
	end
end


% find the path corresponding to the current position
for n_var_y = 1:numel(var_y)
	% loop over the current variable
	%eval('meta.',var_y{
	
end
