% image_scat_layer_order
function big_img = image_scat_layer_order(S, var_x, var_y, renorm)

        margin = 3;
	margin_inter = 20;
	big_img = [];
	
	
	% compute the range of each variable
	for n_var_x = 1:numel(var_x)
		cur_var_name = var_x{n_var_x}.name;
		cur_var_index = var_x{n_var_x}.index;
		string_var = sprintf('S.meta.%s(%d,:)', cur_var_name, cur_var_index);
		cur_var = eval(string_var);
		var_x{n_var_x}.min = min(cur_var);
		var_x{n_var_x}.max = max(cur_var);
		begin_pos_x(n_var_x) = var_x{n_var_x}.min;
		end_pos_x(n_var_x) = var_x{n_var_x}.max;
	end
	for n_var_y = 1:numel(var_y)
		cur_var_name = var_y{n_var_y}.name;
		cur_var_index = var_y{n_var_y}.index;
		string_var = sprintf('S.meta.%s(%d,:)', cur_var_name, cur_var_index);
		cur_var = eval(string_var);
		var_y{n_var_y}.min = min(cur_var);
		var_y{n_var_y}.max = max(cur_var);
		begin_pos_y(n_var_y) = var_y{n_var_y}.min;
		end_pos_y(n_var_y) = var_y{n_var_y}.max;
	end
        
	pos_y = begin_pos_y; pos_y(end) = pos_y(end)-1 ;
	offset_y = 0;
	
	while (norm(pos_y-end_pos_y)~=0)
                pos_x = begin_pos_x;
                pos_x(end) = pos_x(end)-1 ;
		offset_x = 0;
		% incr
		pos_y(end) = pos_y(end)+1;
		% update
		while (sum(pos_y>end_pos_y)>0)
			ind = find(pos_y>end_pos_y);
			pos_y(ind) = begin_pos_y(ind);
			pos_y(ind-1) = pos_y(ind-1)+1;
			if (new_write_y)
				offset_y = offset_y + margin_inter;
				new_write_y=0;
			end
		end
		
		new_write_x = 0;
		while (norm(pos_x-end_pos_x)~=0)
			
			% incr
			pos_x(end) = pos_x(end)+1;
			% update
			while (sum(pos_x>end_pos_x)>0)
				ind = find(pos_x>end_pos_x);
				pos_x(ind) = begin_pos_x(ind);
				pos_x(ind-1) = pos_x(ind-1)+1;
				if (new_write_x)
					offset_x = offset_x + margin_inter;
					new_write_x = 0;
				end
                        end
			
			% construct query
			query = 'find(' ;
			for n_var_x = 1:numel(var_x)
				cur_var_name = var_x{n_var_x}.name;
				cur_var_index = var_x{n_var_x}.index;
				query = sprintf('%s S.meta.%s(%d,:)==%d &',...
					query,cur_var_name, ...
                                                cur_var_index, ...
                                                pos_x(n_var_x)) ;
                        end
			for n_var_y = 1:numel(var_y)
				cur_var_name = var_y{n_var_y}.name;
				cur_var_index = var_y{n_var_y}.index;
				if (n_var_y < numel(var_y))
					query = sprintf('%s S.meta.%s(%d,:)==%d &',...
						query,cur_var_name, cur_var_index, pos_y(n_var_y));
				else
					query = sprintf('%s S.meta.%s(%d,:)==%d );',...
						query,cur_var_name, cur_var_index, pos_y(n_var_y));
                                end
                        end
			
			% find corresponding path and draw on big image
			ind = eval(query);
			if (numel(ind)>0)
				new_write_x = 1;
				new_write_y = 1;
				img = S.signal{ind};
				if (renorm)
					img = (img-min(img(:)))/(max(img(:))-min(img(:)));
				end
				[ncur, mcur] = size(img);
				big_img(offset_y + (1:ncur), offset_x + (1:mcur)) = img;
				offset_x = offset_x + mcur + margin;
                       end

			
		end
		if (new_write_y)
			offset_y = offset_y + size(img,1) + margin;
		end
	end
	imagesc(big_img);
end


